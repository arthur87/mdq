# frozen_string_literal: true

require 'mdq'
require 'active_record'

# Mdq
module Mdq
  # DDB
  class DDB
    def initializ; end

    def get(sql)
      ActiveRecord::Schema.verbose = false
      InitialSchema.migrate(:up)

      android_discover
      apple_discover

      if sql
        begin
          ActiveRecord::Base.connection.execute(sql)
        rescue StandardError
          warn 'SQL Syntax Error.'
          exit
        end
      else
        Device.all
      end
    end

    private

    def android_discover
      # Androidデバイス一覧を取得する
      output, = adb_command('devices -l')
      return if output.nil?

      output.split("\n").each_with_index do |line, index|
        next if index.zero?

        columns = line.split

        serial_number = columns[0]
        authorized = line.index('unauthorized').nil?

        if authorized
          model, = adb_command('shell getprop ro.product.model', serial_number)
          build_version, = adb_command('shell getprop ro.build.version.release', serial_number)
          build_id, = adb_command('shell getprop ro.build.id', serial_number)
          name, = adb_command('shell settings get global device_name', serial_number)

          model = model.strip
          build_version = build_version.strip
          build_id = build_id.strip
          name = name.strip
          total_capacity = 0
          free_capacity = 0

          # バッテリー
          lines1, = adb_command('shell dumpsys battery', serial_number)
          if (match = lines1.match(/level: (\d*)/))
            battery_level = match[1].to_i
          end

          # ストレージ
          lines2, = adb_command('shell df', serial_number)
          lines2.split("\n").each_with_index do |line2, index2|
            next if index2.zero?

            columns = line2.split
            unless columns[5].index('/data').nil?
              total_capacity = columns[1]
              free_capacity = columns[3]
            end
          end

          Device.create({
                          serial_number: serial_number,
                          name: name,
                          authorized: true,
                          model: model,
                          build_version: build_version,
                          build_id: build_id,
                          battery_level: battery_level,
                          total_capacity: total_capacity,
                          free_capacity: free_capacity,
                          platform: 'Android'
                        })
        else
          Device.create({
                          serial_number: serial_number,
                          authorized: false,
                          platform: 'Android'
                        })
        end
      end
    end

    def adb_command(arg, serial_number = nil)
      command = if serial_number.nil?
                  "adb #{arg}"
                else
                  "adb -s #{serial_number} #{arg}"
                end

      begin
        Open3.capture3(command)
      rescue StandardError
        nil
      end
    end

    def apple_discover
      file = [Dir.home, '.mdq.json'].join(File::Separator)

      begin
        Open3.capture3("xcrun devicectl list devices -v -j #{file}")
      rescue StandardError
        return
      end

      return unless File.exist?(file)

      File.open(file, 'r') do |f|
        result = JSON.parse(f.read)
        result['result']['devices'].each do |device|
          Device.create({
                          serial_number: device['hardwareProperties']['serialNumber'],
                          name: device['deviceProperties']['name'],
                          authorized: true,
                          platform: device['hardwareProperties']['platform'],
                          marketing_name: device['hardwareProperties']['marketingName'],
                          model: device['hardwareProperties']['productType'],
                          build_version: device['deviceProperties']['osVersionNumber'],
                          build_id: device['deviceProperties']['osBuildUpdate']
                        })
        end

        File.delete(file)
      end
    end
  end
end

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ':memory:'
)

# スキーマの設定
class InitialSchema < ActiveRecord::Migration[5.1]
  def self.up
    create_table :devices do |t|
      t.string :serial_number
      t.string :name
      t.boolean :authorized
      t.string :platform
      t.string :marketing_name
      t.string :model
      t.string :build_version
      t.string :build_id
      t.integer :battery_level
      t.integer :total_capacity
      t.integer :free_capacity
    end
  end

  def self.down
    drop_table :devices
  end
end

class Device < ActiveRecord::Base
end

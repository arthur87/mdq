# frozen_string_literal: true

require 'mdq'
require 'active_record'
require 'fileutils'

# Mdq
module Mdq
  # DDB
  class DDB
    def initializ; end

    # 接続中のデバイスを取得する
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

    # 指定したソフトウェアのインストール状況を表示する
    def show_version(name, command)
      output, = Open3.capture3(command)
      puts "# #{name} installed."
      puts output
    rescue StandardError
      puts "# #{name} is not installed."
    end

    # Androidデバイスのスクリーンショットを撮る
    def device_screencap(output, udid, _is_android)
      FileUtils.mkdir_p(output)
      file = "/sdcard/#{udid}.png"
      adb_command("shell screencap -p #{file}", udid)
      adb_command("pull #{file} #{output}", udid)
      adb_command("adb shell rm #{file}")
    end

    def app_install(input, udid, is_android)
      if is_android
        adb_command("install #{input}", udid)
      else
        apple_command("device install app #{input}", udid)
      end
    end

    def app_uninstall(input, udid, is_android)
      if is_android
        adb_command("uninstall #{input}", udid)
      else
        apple_command("device uninstall app #{input}", udid)
      end
    end

    private

    # Androidデバイス一覧を取得する
    def android_discover
      output, = adb_command('devices -l')
      return if output.nil?

      output.split("\n").each_with_index do |line, index|
        next if index.zero?

        columns = line.split

        udid = columns[0]
        authorized = line.index('unauthorized').nil?

        if authorized
          model = adb_command('shell getprop ro.product.model', udid)
          build_version = adb_command('shell getprop ro.build.version.release', udid)
          build_id = adb_command('shell getprop ro.build.id', udid)
          name = adb_command('shell settings get global device_name', udid)
          battery_level = nil
          total_capacity = nil
          free_capacity = nil

          # バッテリー
          lines1, = adb_command('shell dumpsys battery', udid)
          if (match = lines1.match(/level: (\d*)/))
            battery_level = match[1].to_i
          end

          # ストレージ
          lines2, = adb_command('shell df', udid)
          lines2.split("\n").each_with_index do |line2, index2|
            next if index2.zero?

            columns = line2.split
            unless columns[5].index('/data').nil?
              total_capacity = columns[1]
              free_capacity = columns[3]
            end
          end

          Device.create({
                          udid: udid,
                          serial_number: udid,
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
                          udid: udid,
                          serial_number: udid,
                          authorized: false,
                          platform: 'Android'
                        })
        end
      end
    end

    # ADBコマンド
    def adb_command(arg, udid = nil)
      command = if udid.nil?
                  "adb #{arg}"
                else
                  "adb -s #{udid} #{arg}"
                end

      begin
        output, = Open3.capture3(command)
        output.strip
      rescue StandardError
        nil
      end
    end

    # devicectlコマンド
    def apple_command(arg, udid = nil)
      command = if udid.nil?
                  "xcrun devicectl #{arg}"
                else
                  "xcrun devicectl #{arg} --device #{udid}"
                end

      begin
        output, = Open3.capture3(command)
        output.strip
      rescue StandardError
        nil
      end
    end

    # Appleデバイス一覧を取得する
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
                          udid: device['hardwareProperties']['udid'],
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
      t.string :udid
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

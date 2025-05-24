# frozen_string_literal: true

require 'mdq'
require 'active_record'
require 'fileutils'

# Mdq
module Mdq
  # Discovery
  class Discovery
    def initialize; end

    def android_discoverable?
      adb_command('version').present?
    end

    def apple_discoverable?
      apple_command('--version').present?
    end

    private

    # ADBコマンド
    def adb_command(arg, udid = nil)
      command = if udid.nil?
                  "adb #{arg}"
                else
                  "adb -s #{udid} #{arg}"
                end

      begin
        Open3.capture3(command)
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
        Open3.capture3(command)
      rescue StandardError
        nil
      end
    end

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
          model, = adb_command('shell getprop ro.product.model', udid)
          build_version, = adb_command('shell getprop ro.build.version.release', udid)
          build_id, = adb_command('shell getprop ro.build.id', udid)
          name, = adb_command('shell settings get global device_name', udid)
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
                          name: name.strip,
                          authorized: true,
                          model: model.strip,
                          build_version: build_version.strip,
                          build_id: build_id.strip,
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

    # Appleデバイス一覧を取得する
    def apple_discover
      file = [Dir.home, '.mdq'].join(File::Separator)
      result = apple_command("list devices -v -j #{file}")

      return unless File.exist?(file)

      File.open(file, 'r') do |f|
        result = JSON.parse(f.read)
        result['result']['devices'].each do |device|
          udid = device['hardwareProperties']['udid']
          Device.create({
                          udid: udid,
                          serial_number: device['hardwareProperties']['serialNumber'],
                          name: device['deviceProperties']['name'],
                          authorized: true,
                          platform: device['hardwareProperties']['platform'],
                          marketing_name: device['hardwareProperties']['marketingName'],
                          model: device['hardwareProperties']['productType'],
                          build_version: device['deviceProperties']['osVersionNumber'],
                          build_id: device['deviceProperties']['osBuildUpdate'],
                          total_capacity: device['hardwareProperties']['internalStorageCapacity']
                        })
        end

        File.delete(file)
      end
    end

    # Androidのアプリを取得する
    def android_apps(udid)
      apps, = adb_command('shell pm list packages', udid)
      apps.split("\n").each do |line3|
        App.create({
                     udid: udid,
                     package_name: line3.gsub('package:', '')
                   })
      end
    end

    # Appleデバイスのアプリを取得する
    def apple_apps(udid)
      file = [Dir.home, '.mdq-apps'].join(File::Separator)
      apple_command("device info apps -j #{file}", udid)
      File.open(file, 'r') do |f|
        result = JSON.parse(f.read)
        begin
          result['result']['apps'].each do |app|
            App.create({
                         udid: udid,
                         package_name: app['bundleIdentifier'],
                         name: app['name'],
                         version: app['version']
                       })
          end
        rescue StandardError
          # none
        end
      end
      File.delete(file)
    end

    def reset
      Device.destroy_all
      App.destroy_all
      ActiveRecord::Base.connection.execute("delete from sqlite_sequence where name='devices'")
      ActiveRecord::Base.connection.execute("delete from sqlite_sequence where name='apps'")
    end
  end
end

ActiveRecord::Schema.verbose = false
ActiveRecord::Migration.verbose = false

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ':memory:'
)

ActiveRecord::Migration.create_table :devices do |t|
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

ActiveRecord::Migration.create_table :apps do |t|
  t.string :udid
  t.string :name
  t.string :package_name
  t.string :version
end

# Device
class Device < ActiveRecord::Base
  def android?
    platform == 'Android'
  end
end

# App
class App < ActiveRecord::Base
end

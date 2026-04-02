# frozen_string_literal: true

require 'mdq'
require 'active_record'
require 'fileutils'

# Mdq
module Mdq
  # DB
  class DB < Discovery
    # デバイスとアプリの取得
    def get(is_android: true, is_apple: true, is_apps: true)
      reset
      # デバイスの発見
      android_discover if is_android
      apple_discover if is_apple

      return unless is_apps

      Device.all.each do |model|
        # インストール済みAppの取得
        if model.android?
          android_apps(model.udid)
        else
          apple_apps(model.udid)
        end
      end
    end

    # クエリの実行
    def query(sql)
      ActiveRecord::Base.connection.execute(sql)
    rescue StandardError
      []
    end

    # Androidデバイスのスクリーンショットを撮る
    def device_screencap(output, udid)
      device = Device.find_by(udid: udid)
      if device.nil? || !device.android?
        warn 'Device not found or not an Android device.'
        return
      end

      FileUtils.mkdir_p(output)
      file = "#{udid}-#{Time.now.strftime('%y%m%d-%H%M%S')}.png"
      full_path = "/sdcard/#{file}"
      adb_command("shell screencap -p #{full_path}", udid)
      adb_command("pull #{full_path} #{output}", udid)
      adb_command("shell rm #{full_path}", udid)
    end

    # Appをインストールする
    def app_install(input, udid, is_replace)
      device = Device.find_by(udid: udid)
      if device.nil?
        warn 'Device not found.'
        return
      end

      if device.android?
        if is_replace
          output, error = adb_command("install -r #{input}", udid)
        else
          output, error = adb_command("install #{input}", udid)
        end
      else
        output, error = apple_command("device install app #{input}", udid)
      end

      puts output unless output.empty?
      warn error unless error.empty?
    end

    # Appをアンインストールする
    def app_uninstall(input, udid)
      device = Device.find_by(udid: udid)
      if device.nil?
        warn 'Device not found.'
        return
      end

      if device.android?
        output, error = adb_command("uninstall #{input}", udid)
      else
        output, error = apple_command("device uninstall app #{input}", udid)
      end

      puts output unless output.empty?
      warn error unless error.empty?
    end
  end
end

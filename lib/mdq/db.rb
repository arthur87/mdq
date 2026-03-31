# frozen_string_literal: true

require 'mdq'
require 'active_record'
require 'fileutils'

# Mdq
module Mdq
  # DB
  class DB < Discovery
    # クエリの実行
    def get(sql)
      reset
      # デバイスの発見
      android_discover
      apple_discover

      if sql
        Device.all.each do |model|
          # インストール済みAppの取得
          if model.android?
            android_apps(model.udid)
          else
            apple_apps(model.udid)
          end
        end

        begin
          ActiveRecord::Base.connection.execute(sql)
        rescue StandardError => e
          { result: e }
        end
      else
        Device.all
      end
    end

    # Androidデバイスのスクリーンショットを撮る
    def device_screencap(output, udid, is_android)
      return unless is_android

      FileUtils.mkdir_p(output)
      file = "#{udid}_#{Time.now.to_i}.png"
      full_path = "/sdcard/#{file}"
      adb_command("shell screencap -p #{full_path}", udid)
      adb_command("pull #{full_path} #{output}", udid)
      adb_command("shell rm #{full_path}", udid)

      { command: 'cap', udid: udid, result: "#{output}/#{file}" }
    end

    # Appをインストールする
    def app_install(input, udid, is_android, is_replace)
      if is_android && input.end_with?('.apk')
        if is_replace
          output, = adb_command("install -r #{input}", udid)
        else
          output, = adb_command("install #{input}", udid)
        end
      elsif !is_android && input.end_with?('.ipa')
        output, = apple_command("device install app #{input}", udid)
      else
        output = 'Invalid file format. Please provide an .apk file for Android or an .ipa file for iOS.'
      end

      { command: 'install', udid: udid, result: output }
    end

    # Appをアンインストールする
    def app_uninstall(input, udid, is_android)
      if is_android
        output, = adb_command("uninstall #{input}", udid)
      else
        output, = apple_command("device uninstall app #{input}", udid)
      end

      { command: 'uninstall', udid: udid, result: output }
    end
  end
end

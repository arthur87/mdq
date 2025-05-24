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
        rescue StandardError
          warn 'SQL Syntax Error.'
          exit
        end
      else
        Device.all
      end
    end

    # Androidデバイスのスクリーンショットを撮る
    def device_screencap(output, udid, is_android)
      return unless is_android

      FileUtils.mkdir_p(output)
      file = "/sdcard/#{udid}.png"
      adb_command("shell screencap -p #{file}", udid)
      adb_command("pull #{file} #{output}", udid)
      adb_command("adb shell rm #{file}")

      puts "# Screenshot of #{udid} to #{output}"
    end

    # Appをインストールする
    def app_install(input, udid, is_android)
      output, = adb_command("install #{input}", udid) if is_android && input.end_with?('.apk')
      output, = apple_command("device install app #{input}", udid) if !is_android && input.end_with?('.ipa')

      return unless output

      puts "# Install #{input} to #{udid}"
      puts output
    end

    # Appをアンインストールする
    def app_uninstall(input, udid, is_android)
      if is_android
        output, = adb_command("uninstall #{input}", udid)
      else
        output, = apple_command("device uninstall app #{input}", udid)
      end

      return unless output

      puts "# Uninstall #{input} from #{udid}"
      puts output
    end
  end
end

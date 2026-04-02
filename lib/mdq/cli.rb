# frozen_string_literal: true

require 'mdq'
require 'thor'

module Mdq
  # entry point
  class CLI < Thor
    class << self
      def exit_on_failure?
        true
      end
    end

    desc 'version', 'Show Version'
    def version
      puts(Mdq::VERSION)
    end

    desc 'check', 'Check the software installation status'
    def check
      db = Mdq::DB.new
      puts "adb is installed: #{db.android_discoverable?}"
      puts "Xcode is installed: #{db.apple_discoverable?}"
    end

    desc 'devices', 'Show mobile devices'
    method_option :android, desc: 'Show Android devices', default: true,
                            type: :boolean
    method_option :apple, desc: 'Show Apple devices', default: true,
                          type: :boolean
    def devices
      db = Mdq::DB.new
      db.get(is_android: options[:android], is_apple: options[:apple], is_apps: false)
      puts(JSON.pretty_generate(Device.all.as_json))
    end

    desc 'apps', 'Show mobile apps'
    method_option :android, desc: 'Show Android devices', default: true,
                            type: :boolean
    method_option :apple, desc: 'Show Apple devices', default: true,
                          type: :boolean
    def apps
      db = Mdq::DB.new
      db.get(is_android: options[:android], is_apple: options[:apple])
      puts(JSON.pretty_generate(App.all.as_json))
    end

    desc 'list', 'Show mobile devices or apps'
    method_option :query, desc: 'SQL to filter devices or apps', aliases: '-q', required: true
    def list
      db = Mdq::DB.new
      db.get
      result = db.query(options['query'])
      puts(JSON.pretty_generate(result.as_json))
    end

    desc 'cap', 'Path to save screenshots(Android only)'
    method_option :udid, desc: 'Specify the device UDID', aliases: '-u', required: true
    method_option :output, desc: 'Save to file', aliases: '-o', required: true
    def cap
      db = Mdq::DB.new
      db.get(is_apps: false)
      db.device_screencap(options[:output], options[:udid])
    end

    desc 'install', 'Installing the app(apk, apex, ipa)'
    method_option :udid, desc: 'Specify the device UDID', aliases: '-u', required: true
    method_option :input, desc: 'Path to the app file', aliases: '-i', required: true
    method_option :replace, desc: 'Replace the app if it is already installed', aliases: '-r', default: false,
                            type: :boolean
    def install
      db = Mdq::DB.new
      db.get(is_apps: false)
      db.app_install(options[:input], options[:udid], options[:replace])
    end

    desc 'uninstall', 'Uninstalling the app'
    method_option :udid, desc: 'Specify the device UDID', aliases: '-u', required: true
    method_option :input, desc: 'Path to the app', aliases: '-i', required: true
    def uninstall
      db = Mdq::DB.new
      db.get(is_apps: false)
      db.app_uninstall(options[:input], options[:udid])
    end
  end
end

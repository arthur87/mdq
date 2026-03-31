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
    def devices
      db = Mdq::DB.new
      models = db.get(false)
      puts(JSON.pretty_generate(models.as_json))
    end

    desc 'apps', 'Show mobile apps'
    def apps
      db = Mdq::DB.new
      models = db.get('SELECT * FROM apps')
      puts(JSON.pretty_generate(models.as_json))
    end

    desc 'list', 'Show mobile devices or apps'
    method_option :query, desc: 'SQL to filter devices or apps', aliases: '-q'
    def list
      db = Mdq::DB.new
      models = db.get(options['query'])
      puts(JSON.pretty_generate(models.as_json))
    end

    desc 'cap', 'Path to save screenshots(Android only)'
    method_option :query, desc: 'SQL to filter devices', aliases: '-q'
    method_option :output, desc: 'Save to file', aliases: '-o'
    def cap
      db = Mdq::DB.new
      models = db.get(options['query'])

      models.each do |device|
        ob.add(db.device_screencap(options[:output], device.udid, device.android?))
      end

      ob.print
    end

    desc 'install', 'Installing the app(apk, ipa)'
    method_option :query, desc: 'SQL to filter devices', aliases: '-q'
    method_option :input, desc: 'Path to the app file', aliases: '-i', required: true
    method_option :replace, desc: 'Replace the app if it is already installed', aliases: '-r', default: false,
                            type: :boolean
    def install
      unless File.exist?(options[:input])
        puts 'Invalid file format. Please provide an .apk or .ipa file.'
        return
      end

      ob = Mdq::OutputBuilder.new
      db = Mdq::DB.new
      models = db.get(options['query'])

      models.each do |device|
        ob.add(db.app_install(options[:input], device.udid, device.android?, options[:replace]))
      end

      ob.print
    end

    desc 'uninstall', 'Uninstalling the app(apk, ipa)'
    method_option :query, desc: 'SQL to filter devices', aliases: '-q'
    method_option :input, desc: 'Path to the app file', aliases: '-i', required: true
    def uninstall
      ob = Mdq::OutputBuilder.new
      db = Mdq::DB.new
      models = db.get(options['query'])

      models.each do |device|
        ob.add(db.app_uninstall(options[:input], device.udid, device.android?))
      end

      ob.print
    end
  end
end

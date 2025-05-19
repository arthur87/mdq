# frozen_string_literal: true

require 'mdq'

# Mdq
module Mdq
  # List
  class List
    def initialize(options)
      ddb = Mdq::DDB.new
      devices = ddb.get(options['query'])

      output = JSON.pretty_generate(devices.as_json)
      puts output
      if options['output']
        File.open(options['output'], 'w') do |f|
          f.write(output)
        end
      end

      devices.each do |device|
        model = Device.find_by(udid: device.udid)
        udid = model.udid
        is_android = model.platform == 'Android'

        ddb.device_screencap(options[:cap], udid, is_android) if options[:cap]
        ddb.app_install(options[:install], udid, is_android) if options[:install]
        ddb.app_uninstall(options[:uninstall], udid, is_android) if options[:uninstall]
      rescue StandardError
        # none
      end
    end
  end
end

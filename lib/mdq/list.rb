# frozen_string_literal: true

require 'mdq'

# Mdq
module Mdq
  # List
  class List
    def initialize(options)
      db = Mdq::DB.new

      query = options['query']
      models = db.get(query)

      output = JSON.pretty_generate(models.as_json)
      puts output
      if options['output']
        File.open(options['output'], 'w') do |f|
          f.write(output)
        end
      end

      ob = Mdq::OutputBuilder.new

      models.each do |device|
        model = Device.find_by(udid: device.udid)
        udid = model.udid
        is_android = model.android?

        ob.add(db.device_screencap(options[:cap], udid, is_android)) if options[:cap]
        ob.add(db.app_install(options[:install], udid, is_android)) if options[:install]
        ob.add(db.app_uninstall(options[:uninstall], udid, is_android)) if options[:uninstall]
      rescue StandardError
        # none
      end

      ob.print
    end
  end
end

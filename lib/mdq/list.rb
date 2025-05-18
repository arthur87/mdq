# frozen_string_literal: true

require 'mdq'

# Mdq
module Mdq
  # List
  class List
    def initialize(options)
      ddb = Mdq::DDB.new
      devices = ddb.get(options['query'])
      puts JSON.pretty_generate(devices.as_json)

      return unless options[:cap]

      devices.each do |device|
        ddb.android_screencap(options[:cap], device.udid)
      rescue StandardError # rubocop:disable Lint/SuppressedException
      end
    end
  end
end

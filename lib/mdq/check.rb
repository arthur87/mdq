# frozen_string_literal: true

require 'mdq'

# Mdq
module Mdq
  # Check
  class Check
    def initialize
      ob = Mdq::OutputBuilder.new

      db = Mdq::DB.new
      ob.add(show_message('adb', db.android_discoverable?))
      ob.add(show_message('Xcode', db.apple_discoverable?))

      ob.print
    end

    private

    def show_message(name, discoverable)
      if discoverable
        { result: "#{name} is installed." }
      else
        { result: "#{name} is not installed." }
      end
    end
  end
end

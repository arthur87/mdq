# frozen_string_literal: true

require 'mdq'

# Mdq
module Mdq
  # Check
  class Check
    def initialize
      db = Mdq::DB.new
      show_message('adb', db.android_discoverable?)
      show_message('Xcode', db.apple_discoverable?)
    end

    private

    def show_message(name, discoverable)
      if discoverable
        puts "# #{name} is installed."
      else
        puts "# #{name} is not installed."
      end
    end
  end
end

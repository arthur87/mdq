# frozen_string_literal: true

require 'mdq'

# Mdq
module Mdq
  # Check
  class Check
    def initialize
      show_version('adb', 'adb version')
      show_version('Xcode', 'xcrun devicectl --version')
    end

    private

    def show_version(name, command)
      output, = Open3.capture3(command)
      puts "# #{name} installed."
      puts output
    rescue StandardError
      puts "# #{name} is not installed."
    end
  end
end

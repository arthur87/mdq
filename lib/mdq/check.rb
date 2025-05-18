# frozen_string_literal: true

require 'mdq'

# Mdq
module Mdq
  # Check
  class Check
    def initialize
      ddb = Mdq::DDB.new
      ddb.show_version('adb', 'adb version')
      ddb.show_version('Xcode', 'xcrun devicectl --version')
    end
  end
end

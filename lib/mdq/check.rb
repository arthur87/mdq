# frozen_string_literal: true

require 'mdq'

# Mdq
module Mdq
  # Check
  class Check
    def initialize
      db = Mdq::DB.new
      db.show_version('adb', 'adb version')
      db.show_version('Xcode', 'xcrun devicectl --version')
    end
  end
end

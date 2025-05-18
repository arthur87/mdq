# frozen_string_literal: true

require 'mdq'

# Mdq
module Mdq
  # List
  class List
    def initialize(options)
      ddb = Mdq::DDB.new

      puts JSON.pretty_generate(ddb.get(options['q']).as_json)
    end
  end
end

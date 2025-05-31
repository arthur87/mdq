# frozen_string_literal: true

require 'mdq'

# Mdq
module Mdq
  # OutputBuilder
  class OutputBuilder
    def initialize
      @result = []
    end

    def clear
      @result = []
    end

    def add(new_result)
      @result << new_result
    end

    def print
      return if @result == []

      puts JSON.pretty_generate(@result.as_json)
    end
  end
end

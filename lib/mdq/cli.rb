# frozen_string_literal: true

require 'mdq'
require 'thor'

module Mdq
  # entry point
  class CLI < Thor
    class << self
      def exit_on_failure?
        true
      end
    end

    desc 'version', 'Show Version'
    def version
      puts(Mdq::VERSION)
    end

    desc 'check', 'Check the software installation status'
    def check
      Mdq::Check.new
    end

    desc 'list', 'Show mobile devices'
    method_option :query, desc: 'Query', aliases: '-q'
    def list
      Mdq::List.new(options)
    end
  end
end

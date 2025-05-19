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
    method_option :output, desc: 'Save the results as a JSON file', aliases: '-o'
    method_option :query, desc: 'SQL to filter devices', aliases: '-q'
    method_option :cap, desc: 'Path to save screenshots(Android only)'
    method_option :install, desc: 'Installing the app'
    method_option :uninstall, desc: 'Uninstalling the app'
    def list
      Mdq::List.new(options)
    end
  end
end

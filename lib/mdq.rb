# frozen_string_literal: true

require_relative 'mdq/version'
require 'mdq/cli'
require 'mdq/discovery'
require 'mdq/db'
require 'mdq/output_builder'

require 'open3'
require 'active_record'
require 'json'

module Mdq
  class Error < StandardError; end
  # Your code goes here...
end

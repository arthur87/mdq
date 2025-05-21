# frozen_string_literal: true

require_relative 'mdq/version'
require 'mdq/cli'
require 'mdq/check'
require 'mdq/list'
require 'mdq/discovery'
require 'mdq/db'

require 'open3'
require 'active_record'
require 'json'

module Mdq
  class Error < StandardError; end
  # Your code goes here...
end

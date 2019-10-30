# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'

require 'api_blocks/version'
require 'active_support/concern'
require 'active_support/dependencies/autoload'

# ApiBlocks provides simple and consistent rails api extensions.
module ApiBlocks
  extend ActiveSupport::Autoload

  autoload :Controller
  autoload :Responder
  autoload :Interactor
  autoload :Doorkeeper
end

require 'api_blocks/railtie' if defined?(Rails)

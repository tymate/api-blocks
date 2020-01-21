# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'

require 'dry/configurable'

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

  extend Dry::Configurable

  setting :blueprinter do
    setting :use_batch_loader, false
  end
end

require 'api_blocks/railtie' if defined?(Rails)

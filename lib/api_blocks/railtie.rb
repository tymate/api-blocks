# frozen_string_literal: true

require "problem_details-rails"

# ApiBlocks::Railtie implements the Rails integration for ApiBlocks.
#
# @private
#
class ApiBlocks::Railtie < Rails::Railtie
  initializer 'api_blocks.doorkeeper' do
    next unless defined?(Doorkeeper)

    Doorkeeper::Orm::ActiveRecord.initialize_models!

    ActiveSupport.on_load(:active_record) do
      # do not load the Doorkeeper::Application extensions if migrations have
      # not been setup.
      has_reset_password_uri = Doorkeeper::Application.columns.find do |col|
        col.name == 'reset_password_uri'
      end

      next unless has_reset_password_uri

      Doorkeeper::Application.include(
        ApiBlocks::Doorkeeper::Passwords::Application
      )
    end

    ActiveSupport.on_load(:active_record) do
      # do not load the Doorkeeper::Application extensions if migrations have
      # not been setup.
      invitation_uri = Doorkeeper::Application.columns.find do |col|
        col.name == 'invitation_uri'
      end

      next unless invitation_uri

      Doorkeeper::Application.include(
        ApiBlocks::Doorkeeper::Invitations::Application
      )
    end
  end

  generators do
    require_relative 'doorkeeper/passwords/migration_generator'
    require_relative 'doorkeeper/invitations/migration_generator'
  end
end

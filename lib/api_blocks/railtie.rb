# frozen_string_literal: true

# ApiBlocks::Railtie implements the Rails integration for ApiBlocks.
#
# @private
#
class ApiBlocks::Railtie < Rails::Railtie
  config.after_initialize  do
    next unless defined?(Doorkeeper)

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
  end

  generators do
    require_relative 'doorkeeper/passwords/migration_generator'
  end
end

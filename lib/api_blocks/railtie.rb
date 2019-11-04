# frozen_string_literal: true

require "problem_details-rails"

# ApiBlocks::Railtie implements the Rails integration for ApiBlocks.
#
# @private
#
class ApiBlocks::Railtie < Rails::Railtie
  generators do
    require_relative 'doorkeeper/passwords/migration_generator'
    require_relative 'doorkeeper/invitations/migration_generator'
  end
end

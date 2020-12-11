# frozen_string_literal: true

require 'problem_details-rails'

# ApiBlocks::Railtie implements the Rails integration for ApiBlocks.
#
# @private
#
module ApiBlocks
  class Railtie < Rails::Railtie
    generators do
      require_relative 'doorkeeper/passwords/migration_generator'
      require_relative 'doorkeeper/invitations/migration_generator'
    end

    initializer 'blueprinter.batch_loader_integration' do |app|
      app.config.after_initialize do
        next unless ApiBlocks.config.blueprinter.use_batch_loader

        require_relative 'blueprinter/association_extractor'
      end
    end
  end
end

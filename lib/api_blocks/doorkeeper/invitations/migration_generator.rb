# frozen_string_literal: true

require 'rails/generators'
require 'rails/generators/active_record'

# ApiBlocks::Doorkeeper::Invitations::MigrationGenerator implements the Rails
# generator for doorkeeper invitations api migrations.
#
# @private
#
module ApiBlocks
  module Doorkeeper
    module Invitations
      class MigrationGenerator < ::Rails::Generators::Base
        include ::Rails::Generators::Migration

        source_root File.expand_path('templates', __dir__)
        desc 'Installs doorkeeper invitations api migrations'

        def install
          migration_template(
            'migration.rb.erb',
            'db/migrate/add_invitation_uri_to_doorkeeper_applications.rb',
            migration_version: migration_version
          )
        end

        def self.next_migration_number(dirname)
          ActiveRecord::Generators::Base.next_migration_number(dirname)
        end

        private

        def migration_version
          "[#{ActiveRecord::VERSION::MAJOR}.#{ActiveRecord::VERSION::MINOR}]"
        end
      end
    end
  end
end

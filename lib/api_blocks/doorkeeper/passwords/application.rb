# frozen_string_literal: true

# ApiBlocks::Doorkeeper::Passwords::Application adds `reset_password_uri`
# validation to `Doorkeeper::Application`.
#
# This module is automatically included on rails application startup if the
# passwords migrations have been ran.
#
# @private
#
module ApiBlocks::Doorkeeper::Passwords::Application
  extend ActiveSupport::Concern

  included do
    validates :reset_password_uri, "doorkeeper/redirect_uri": true
  end
end

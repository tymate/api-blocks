# frozen_string_literal: true

# ApiBlocks::Doorkeeper::Invitations::Application adds `invitation_uri`
# validation to `Doorkeeper::Application`.
#
# This module is automatically included on rails application startup if the
# invitations migrations have been ran.
#
# @private
#
module ApiBlocks
  module Doorkeeper
    module Invitations
      module Application
        extend ActiveSupport::Concern

        included do
          validates :invitation_uri, "doorkeeper/redirect_uri": true
        end
      end
    end
  end
end

# frozen_string_literal: true

# ApiBlocks::Doorkeeper::Invitations implements an API invitation workflow.
module ApiBlocks
  module Doorkeeper
    module Invitations
      extend ActiveSupport::Autoload

      autoload :Controller
      autoload :Application
    end
  end
end

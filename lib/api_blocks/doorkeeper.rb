# frozen_string_literal: true

# ApiBlocks::Doorkeeper implements API extensions for doorkeeper.
module ApiBlocks
  module Doorkeeper
    extend ActiveSupport::Autoload

    autoload :Passwords
    autoload :Invitations
  end
end

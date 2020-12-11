# frozen_string_literal: true

# ApiBlocks::Doorkeeper::Passwords implements an API reset password workflow.
module ApiBlocks
  module Doorkeeper
    module Passwords
      extend ActiveSupport::Autoload

      autoload :Controller
      autoload :User
      autoload :Application
    end
  end
end

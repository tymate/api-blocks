# frozen_string_literal: true

# ApiBlocks::Doorkeeper::Passwords::User overrides some methods from devise
# recoverable module to add the dorkeeper application to the mailer.
#
# @example
#   # app/models/user.rb
#   class User < ApplicationRecord
#     include ApiBlocks::Doorkeeper::Passwords::User
#   end
#
module ApiBlocks
  module Doorkeeper
    module Passwords
      module User
        extend ActiveSupport::Concern

        included do
          # Resets reset password token and send reset password instructions by email.
          # Returns the token sent in the e-mail.
          def send_reset_password_instructions(application = nil)
            token = set_reset_password_token
            send_reset_password_instructions_notification(token, application)

            token
          end

          protected

          def send_reset_password_instructions_notification(token, application = nil)
            send_devise_notification(
              :reset_password_instructions, token, application
            )
          end
        end

        class_methods do
          # Attempt to find a user by its email. If a record is found, send new
          # password instructions to it. If user is not found, returns a new user
          # with an email not found error.
          # Attributes must contain the user's email
          def send_reset_password_instructions(attributes = {}, application: nil)
            recoverable = find_or_initialize_with_errors(
              reset_password_keys, attributes, :not_found
            )

            recoverable.send_reset_password_instructions(application) if recoverable.persisted?
            recoverable
          end
        end
      end
    end
  end
end

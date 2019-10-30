# frozen_string_literal: true

# ApiBlocks::Doorkeeper::Passwords::Controller implements an API passwords reset
# workflow.
#
# @example
#   # app/controllers/api/v1/passwords_controller.rb
#   class Api::V1::PasswordsController < Api::V1::ApplicationController
#     include ApiBlocks::Doorkeeper::Passwords::Controller
#
#     private
#
#     def user_model
#       User
#     end
#   end
#
# @example
#   # config/routes.rb
#   Rails.application.routes.draw do
#     scope module: :api do
#       namespace :v1 do
#         resources :passwords, only: %i[create] do
#           get :callback, on: :collection
#           put :update, on: :collection
#         end
#       end
#     end
#   end
#
# @example
#   # app/models/user.rb
#   class User < ApplicationRecord
#     include ApiBlocks::Doorkeeper::Passwords::User
#   end
#
# @example
#   # config/initializers/devise.rb
#   Devise.setup do |config|
#     # Configure the class responsible to send e-mails.
#     config.mailer = "DeviseMailer"
#   end
#
# @example
#   # app/mailers/devise_mailer.rb
#
#   class DeviseMailer < Devise::Mailer
#     def reset_password_instructions(
#       record, token, application = nil, _opts = {}
#     )
#       @token = token
#       @application = application
#     end
#   end
#
module ApiBlocks::Doorkeeper::Passwords::Controller
  extend ActiveSupport::Concern

  included do # rubocop:disable Metrics/BlockLength
    # Skip pundit after action hooks because there is no authorization to
    # perform.
    skip_after_action :verify_authorized
    skip_after_action :verify_policy_scoped

    # Initialize the reset password workflow, sends a reset password email to
    # the user.
    def create
      application = Doorkeeper::Application.find_by!(uid: params[:client_id])

      user = user_model.send_reset_password_instructions(
        create_params, application: application
      )

      if successfully_sent?(user)
        render(status: :no_content)
      else
        respond_with(user)
      end
    end

    # Handles the redirection from the email towards the application's
    # `redirect_uri`.
    def callback
      application = Doorkeeper::Application.find_by!(uid: params[:client_id])

      query = {
        reset_password_token: params[:reset_password_token]
      }.to_query

      redirect_to(
        "#{application.reset_password_uri}?#{query}"
      )
    end

    # Updates the user password and returns a new Doorkeeper::AccessToken.
    def update
      application = Doorkeeper::Application.find_by!(uid: params[:client_id])
      user = user_model.reset_password_by_token(update_params)

      if user.errors.empty?
        user.unlock_access! if unlockable?(user)

        render json: access_token(application, user)
      else
        respond_with(user)
      end
    end

    private

    # Create permitted parameters
    def create_params
      params.require(:user).permit(:email)
    end

    # Update permitted parameters
    def update_params
      params.require(:user).permit(
        :reset_password_token, :password
      )
    end

    # Copied over from devise base controller in order to clear user errors if
    # `Devise.paranoid` is active.
    def successfully_sent?(user)
      if Devise.paranoid
        user.errors.clear
        true
      elsif user.errors.empty?
        true
      end
    end

    # Copied over from devise base controller in order to determine wether a ser
    # is unlockable or not.
    def unlockable?(resource)
      resource.respond_to?(:unlock_access!) &&
        resource.respond_to?(:unlock_strategy_enabled?) &&
        resource.unlock_strategy_enabled?(:email)
    end

    # Returns a new access token for this user.
    def access_token(application, user)
      Doorkeeper::AccessToken.find_or_create_for(
        application,
        user.id,
        Doorkeeper.configuration.default_scopes,
        Doorkeeper.configuration.access_token_expires_in,
        true
      )
    end

    # Returns the user model class.
    def user_model
      raise 'the method `user_model` must be implemented on your password controller' # rubocop:disable Metrics/LineLength
    end
  end
end

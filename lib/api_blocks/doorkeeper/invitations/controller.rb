# frozen_string_literal: true

# ApiBlocks::Doorkeeper::Invitations::Controller implements a devise invitable
# API controller.
module ApiBlocks::Doorkeeper::Invitations::Controller
  extend ActiveSupport::Concern

  included do # rubocop:disable Metrics/BlockLength
    skip_after_action :verify_authorized
    skip_after_action :verify_policy_scoped

    # Initialize a new invitation.
    def create
      user = user_model.invite!(
        create_params, current_user, application: oauth_application,
      )

      return render(status: :no_content) if user.errors.empty?

      respond_with(user)
    end

    # Renders informations about the invited user.
    def show
      user = user_model.find_by_invitation_token(params[:invitation_token], false)

      if user.nil? || !user.persisted?
        return render(
          problem: { details: "invalid invitation token" },
          status: :bad_request
        )
      end

      respond_with(user)
    end

    # Redirects to the application's redirect uri.
    def callback
      query = {
        invitation_token: params[:invitation_token]
      }.to_query

      redirect_to("#{oauth_application.invitation_uri}?#{query}")
    end

    # Finalize the invitation.
    def update
      user = user_model.accept_invitation!(update_params)

      return respond_with(user) unless user.errors.empty?

      user.unlock_access! if unlockable?(user)

      respond_with(Doorkeeper::OAuth::TokenResponse.new(
        access_token(oauth_application, user)
      ).body)
    end

    private

    def create_params
      params.require(:user).permit(:email)
    end

    def update_params
      params.require(:user).permit(
        :invitation_token, :password, :password_confirmation
      )
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

    def oauth_application
      @oauth_application ||= Doorkeeper::Application.find_by!(
        uid: params[:client_id]
      )
    end


    # Returns the user model class.
    def user_model
      raise 'the method `user_model` must be implemented on your invitations controller' # rubocop:disable Metrics/LineLength
    end
  end
end

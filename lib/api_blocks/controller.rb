# frozen_string_literal: true

# frozen_string_litreal: true

require 'pundit'
require 'active_support/core_ext/module'

# ApiBlocks::Controller provides a set of default configurations for
# Ruby on Rails api controllers.
#
# It sets up `ApiBlocks::Responder` as a responder, `Pundit` and controller
# defaults.
#
# @example
#
#   class Api::V1::ApplicationController < ActionController::API
#     include ApiBlocks::Controller
#
#     pundit_scope :api, :v1
#   end
#
module ApiBlocks
  module Controller
    extend ActiveSupport::Concern

    included do
      self.responder = ApiBlocks::Responder

      before_action :verify_request_format!

      include Pundit
      rescue_from Pundit::NotAuthorizedError, with: :render_forbidden_error

      # Enable pundit after_action hooks to ensure policies are consistently
      # used.
      after_action :verify_authorized
      after_action :verify_policy_scoped, except: :create

      # Override policy_scope to lookup pundit policies under the `scope`
      # namespace
      def policy_scope(scope, policy_scope_class: nil)
        api_scope = self.class.inherited_pundit_api_scope || []

        super(api_scope + [scope], policy_scope_class: policy_scope_class)
      end

      # Override authorize to lookup pundit policies under the `scope`
      # namespace
      def authorize(record, query = nil, policy_class: nil)
        api_scope = self.class.inherited_pundit_api_scope || []

        super(api_scope + [record], query, policy_class: policy_class)
      end

      handle_api_error Pundit::NotAuthorizedError do |error|
        [{ detail: error.message }, :forbidden]
      end
    end

    class_methods do
      # Returns the `pundit_api_scope` value that was defined last looking up into
      # the inheritance chain of the current class.
      def inherited_pundit_api_scope
        ancestors
          .select { |a| a.respond_to?(:pundit_api_scope) }
          .find(&:pundit_api_scope)
          .pundit_api_scope
      end

      # Provide a default scope to pundit's `PolicyFinder`.
      def pundit_scope(*scope)
        @pundit_api_scope ||= scope
      end

      def pundit_api_scope
        @pundit_api_scope
      end

      # Defines a error handler that returns
      def handle_api_error(error_class)
        rescue_from error_class do |ex|
          problem, status =
            if block_given?
              yield ex
            else
              [{ detail: ex.message }, :ok]
            end

          render problem: problem, status: status
        end
      end
    end
  end
end

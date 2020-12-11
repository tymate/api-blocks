# frozen_string_literal: true

require 'dry/transaction'
require 'dry/validation'

# ApiBlocks::Interactor implements a base interactor class.
#
# It is based on `Dry::Transaction` and implements input schema parsing and
# validation as well as database transaction handling.
#
# @example
#
#   class InviteUser < ApiBlocks::Interactor
#     input do
#       schema do
#         required(:email).filled
#         required(:password).filled
#
#         optional(:first_name)
#         optional(:last_name)
#       end
#     end
#
#     around :database_transaction!
#
#     step :validate_input!
#     try :create_user, catch: ActiveRecord::RecordInvalid
#     tee :deliver_invitation
#
#     def create_user(params)
#       Success(User.create!(params))
#     end
#
#     def deliver_invitation(user, mailer)
#       mailer.accept_invitation(user)
#     end
#   end
#
module ApiBlocks
  class Interactor
    include Dry::Transaction

    class << self
      attr_accessor :input_schema
    end

    # Define a contract for the input of this interactor using
    # `dry-validation`
    #
    # @example
    #
    #   class FooInteractor < ApiBlocks::Interactor
    #     input do
    #       schema do
    #         required(:bar).filled
    #       end
    #     end
    #
    #     step :validate_input!
    #   end
    #
    def self.input(&block)
      @input_schema = Class.new(Dry::Validation::Contract, &block).new
    end

    # Call the interactor with its arguments.
    #
    # @example
    #
    #   InviteUser.call(
    #     email: "foo@example.com",
    #     first_name: "Foo",
    #     last_name: "Bar"
    #   )
    #
    def self.call(*args)
      new.call(*args)
    end

    # Call the interactor with additional step arguments.
    #
    # @example
    #
    #   InviteUser.with_step_args(deliver_invitation: [mailer: UserMailer])
    #
    def self.with_step_args(*args)
      new.with_step_args(*args)
    end

    protected

    # Validates input with the class attribute `schema` if it is
    # defined.
    #
    # Add this step to your interactor if you want to validate its input.
    #
    def validate_input!(input)
      return Success(input) unless self.class.input_schema

      result = self.class.input_schema.call(input)

      if result.success?
        Success(result.values)
      else
        Failure(result)
      end
    end

    # Wraps the steps inside an AR transaction.
    #
    # Add this step to your interactor if you want to wrap its operations inside a
    # database transaction
    #
    def database_transaction!(input)
      result = nil

      ActiveRecord::Base.transaction do
        result = yield(Success(input))
        raise ActiveRecord::Rollback if result.failure?
      end

      result
    end
  end
end

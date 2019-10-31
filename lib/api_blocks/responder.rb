# frozen_string_literal: true

require 'action_controller/responder'
require 'responders'
require 'dry/monads/result'

# ApiBlocks::Responder provides a responder with better error handling and
# `ApiBlocks::Interactor` through `Dry::Monads::Result` support.
#
class ApiBlocks::Responder < ActionController::Responder
  include Responders::HttpCacheResponder

  # Override resource_errors to handle more error kinds and return a status
  # code.
  #
  def resource_errors
    case @resource
    when ApplicationRecord
      [{ errors: @resource.errors }, :unprocessable_entity]
    when ActiveRecord::RecordInvalid
      [{ errors: @resource.record.errors }, :unprocessable_entity]
    else
      # propagate the error so it can be handled through the standard rails
      # error handlers.
      raise @resource
    end
  end
  # Display is just a shortcut to render a resource's errors with the current format
  # using `problem_details` when format is set to JSON.
  #
  def display_errors
    return super unless format == :json

    errors, status = resource_errors

    controller.render problem: errors, status: status
  end

  # All other formats follow the procedure below. First we try to render a
  # template, if the template is not available, we verify if the resource
  # responds to :to_format and display it.
  #
  # In addition, if the resource is a Dry::Monads::Result we unwrap it and
  # assign the failure instead.
  #
  def to_format
    return super unless resource.is_a?(Dry::Monads::Result)

    # unwrap the result monad so it can be processed by
    # ActionController::Responder
    resource.fmap { |result| @resource = result }.or do |failure|
      @resource = failure
      @failure = true
    end

    super
  end

  def has_errors? # rubocop:disable Naming/PredicateName
    return true if @failure

    super
  end

  # Override ActionController::Responder#api_behavior in order to
  # provide one that matches our API documentation.
  #
  # The only difference so far is that on POST we do not render `status:
  # :created` along with a `Location` header.
  #
  # Moreover, we display the resource on PUT.
  #
  def api_behavior
    raise(MissingRenderer, format) unless has_renderer?

    if get? || post? || put?
      display resource
    else
      head :no_content
    end
  end
end

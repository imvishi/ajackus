class ApplicationController < ActionController::API
  include Clerk::Authenticatable

  rescue_from ActiveRecord::RecordNotFound do |error|
    render json: { error: "#{error.model || 'Record'} not found" }, status: :not_found
  end

  # Raised by command.validate! in command handlers.
  rescue_from ActiveModel::ValidationError do |error|
    render json: { error: error.model.errors.full_messages.to_sentence }, status: :unprocessable_entity
  end

  # Two requests changed the same vote at once (e.g. a double click); the later one loses.
  rescue_from RubyEventStore::WrongExpectedEventVersion do
    render json: { error: "Your vote changed at the same time, please try again" }, status: :conflict
  end

  private

  def command_bus
    Rails.configuration.command_bus
  end

  # Clerk user id of the signed-in user (e.g. "user_2abc..."), or nil.
  def current_user_id
    clerk&.user_id
  end

  # Valid token AND the session hasn't been signed out.
  def require_user!
    return if clerk&.user? && ClerkAuth::ActiveSession.new(session_id: clerk.session["sid"]).call

    render json: { error: "You must be signed in" }, status: :unauthorized
  end
end

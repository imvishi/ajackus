class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound do |error|
    render json: { error: "#{error.model || 'Record'} not found" }, status: :not_found
  end

  # Raised by command.validate! in command handlers.
  rescue_from ActiveModel::ValidationError do |error|
    render json: { error: error.model.errors.full_messages.to_sentence }, status: :unprocessable_entity
  end

  private

  def command_bus
    Rails.configuration.command_bus
  end

  # Temporary: the user id comes from the X-User-Id header until Clerk auth is added.
  def current_user_id
    request.headers["X-User-Id"].presence
  end

  def require_user!
    render json: { error: "X-User-Id header is required" }, status: :unauthorized unless current_user_id
  end
end

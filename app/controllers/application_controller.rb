class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound do |error|
    render json: { error: "#{error.model || 'Record'} not found" }, status: :not_found
  end
end

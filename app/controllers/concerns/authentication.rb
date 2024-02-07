# frozen_string_literal: true

module Authentication
  extend ActiveSupport::Concern

  include ActionController::HttpAuthentication::Basic::ControllerMethods
  include ActionController::HttpAuthentication::Token::ControllerMethods

  attr_reader :current_api_token, :current_user

  def authenticate_with_api_token!
    authenticate_or_request_with_http_token do |http_token, _options|
      @current_api_token = ApiToken.where(active: true).find_by(token: http_token)
      @current_user = current_api_token&.user
    end
  end
end

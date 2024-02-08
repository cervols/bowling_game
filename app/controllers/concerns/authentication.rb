# frozen_string_literal: true

module Authentication
  extend ActiveSupport::Concern

  include ActionController::HttpAuthentication::Basic::ControllerMethods
  include ActionController::HttpAuthentication::Token::ControllerMethods
  include ActiveSupport::SecurityUtils

  attr_reader :current_api_token, :current_user

  def authenticate_with_api_token!
    authenticate_or_request_with_http_token do |http_token, options|
      @current_api_token = find_active_api_token(options[:token_id])
      @current_user = current_api_token.user if api_token_valid?(http_token)
    end
  end

  protected

    def find_active_api_token(id)
      return unless id

      ApiToken.where(active: true).find_by(id: id)
    end

    def api_token_valid?(http_token)
      current_api_token && secure_compare(current_api_token.token, http_token)
    end
end

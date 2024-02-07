# frozen_string_literal: true

class ApiTokensController < ApplicationController
  include Authentication

  before_action :authenticate_with_api_token!, only: %i[index destroy]

  def index
    render json: current_user.api_tokens
  end

  def create
    authenticate_or_request_with_http_basic do |email, password|
      user = User.authenticate_by(email: email, password: password)

      if user
        api_token = user.api_tokens.create!
        render json: api_token, status: :created
      end
    end
  end

  def destroy
    current_api_token.destroy
  end
end

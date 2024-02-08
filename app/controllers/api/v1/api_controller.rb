# frozen_string_literal: true

class Api::V1::ApiController < ApplicationController
  include Authentication

  before_action :authenticate_with_api_token!
end

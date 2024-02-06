require 'rails_helper'

RSpec.describe "ApiTokens", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/api-tokens"
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /create" do
    it "returns http success" do
      post "/api-tokens"
      expect(response).to have_http_status(:success)
    end
  end

  describe "DELETE /destroy" do
    it "returns http success" do
      delete "/api-tokens"
      expect(response).to have_http_status(:success)
    end
  end
end

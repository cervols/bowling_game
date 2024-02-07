# frozen_string_literal: true

require "rails_helper"

RSpec.describe "ApiTokens", type: :request do
  describe "GET /index" do
    context "when request is unauthorized" do
      it "returns http unauthorized" do
        get "/api-tokens"
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when request is authorized" do
      let(:user) { User.create(email: "email@example.com", password: "qwerty") }
      let(:api_token) { user.api_tokens.create }
      let(:headers) { { Authorization: "Token token=#{api_token.token}" } }

      it "returns http success" do
        get "/api-tokens", headers: headers
        expect(response).to have_http_status(:success)
      end

      it "returns list of current user's tokens" do
        partial_response = {
          "user_id" => user.id,
          "token" => api_token.token
        }

        get "/api-tokens", headers: headers
        expect(JSON.parse(response.body).first).to include(partial_response)
      end
    end
  end

  describe "POST /create" do
    context "when request is unauthorized" do
      it "returns http unauthorized" do
        post "/api-tokens"
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when request is authorized" do
      let(:user) { User.create(email: "email@example.com", password: "qwerty") }
      let(:headers) { { Authorization: "Basic " + Base64.encode64("#{user.email}:#{user.password}") } }

      it "returns http success" do
        post "/api-tokens", headers: headers
        expect(response).to have_http_status(:success)
      end

      it "creates api_token" do
        expect do
          post "/api-tokens", headers: headers
        end.to change { user.api_tokens.count }.from(0).to(1)
      end

      it "returns created token" do
        post "/api-tokens", headers: headers

        partial_response = {
          "user_id" => user.id,
          "token" => ApiToken.last.token
        }
        expect(JSON.parse(response.body)).to include(partial_response)
      end
    end
  end

  describe "DELETE /destroy" do
    context "when request is unauthorized" do
      it "returns http unauthorized" do
        delete "/api-tokens"
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when request is authorized" do
      let(:user) { User.create(email: "email@example.com", password: "qwerty") }
      let!(:api_token) { user.api_tokens.create }
      let(:headers) { { Authorization: "Token token=#{api_token.token}" } }

      it "returns http success" do
        delete "/api-tokens", headers: headers
        expect(response).to have_http_status(:success)
      end

      it "destroys current api token" do
        expect do
          delete "/api-tokens", headers: headers
        end.to change { ApiToken.count }.from(1).to(0)
      end
    end
  end
end

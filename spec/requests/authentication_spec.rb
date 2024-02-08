# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Authentication", type: :request do
  subject(:request_to_protected_api) { get "/api/v1/games/#{game.id}/score", headers: headers }

  let(:game) { instance_double(Game, id: 1) }
  let(:headers) { {} }

  context "with invalid authentication scheme" do
    let(:headers) { { Authorization: "" } }

    it "returns HTTP status 401 Unauthorized" do
      request_to_protected_api
      expect(response).to have_http_status(:unauthorized)
    end
  end

  context "with valid authentication scheme" do
    let(:headers) { { Authorization: "Token token=#{api_token.token}, token_id=#{api_token.id}" } }

    context "with valid acive token" do
      let(:user) { User.create(email: "email@example.com", password: "qwerty") }
      let(:api_token) { user.api_tokens.create }

      it "does not return HTTP status unauthorized" do
        request_to_protected_api
        expect(response).not_to have_http_status(:unauthorized)
      end
    end

    context "with valid not acive token" do
      let(:user) { User.create(email: "email@example.com", password: "qwerty") }
      let(:api_token) { user.api_tokens.create(active: false) }

      it "returns HTTP status 401 Unauthorized" do
        request_to_protected_api
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "with invalid token" do
      let(:api_token) { OpenStruct.new(id: 1, token: SecureRandom.hex, active: true) }

      it "returns HTTP status 401 Unauthorized" do
        request_to_protected_api
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end

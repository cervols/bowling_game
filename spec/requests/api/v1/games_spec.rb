# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::V1::Games", type: :request do
  context "when auth token is not valid" do
    describe "POST /create" do
      it "creates a game" do
        expect do
          post api_v1_games_url
        end.not_to change { Game.count }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    describe "PUT /throw_ball" do
      let(:game) { Game.create }

      it "calls throw_ball method for the game" do
        expect_any_instance_of(Game).not_to receive(:throw_ball)
        put "/api/v1/games/#{game.id}/throw_ball", params: { game: { knocked_pins: 10 } }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    describe "GET /score" do
      let(:game) { Game.create }

      it "calls score method for the game" do
        expect_any_instance_of(Game).not_to receive(:score).and_call_original
        get "/api/v1/games/#{game.id}/score"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  context "when auth token is valid" do
    let(:user) { User.create(email: "email@example.com", password: "qwerty") }
    let(:api_token) { user.api_tokens.create }
    let(:headers) { { Authorization: "Token token=#{api_token.token}" } }

    describe "POST /create" do
      it "creates a game" do
        expect do
          post api_v1_games_url, headers: headers
        end.to change { Game.count }.by(1)
        expect(response).to have_http_status(:successful)
      end
    end

    describe "PUT /throw_ball" do
      let(:game) { Game.create }

      it "calls throw_ball method for the game" do
        expect_any_instance_of(Game).to receive(:throw_ball).with("10")
        put "/api/v1/games/#{game.id}/throw_ball", headers: headers, params: { game: { knocked_pins: 10 } }
        expect(response).to have_http_status(:successful)
      end
    end

    describe "GET /score" do
      let(:game) { Game.create }

      it "calls score method for the game" do
        expect_any_instance_of(Game).to receive(:score).and_call_original
        get "/api/v1/games/#{game.id}/score", headers: headers
        expect(response).to have_http_status(:successful)
      end
    end
  end
end

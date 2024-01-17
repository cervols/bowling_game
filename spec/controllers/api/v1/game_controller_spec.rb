# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::GamesController, type: :controller do
  describe "POST /create" do
    it "creates a game" do
      expect { post :create }.to change { Game.count }.by(1)
      expect(response).to have_http_status(:successful)
    end
  end

  describe "PUT /throw_ball" do
    let(:game) { Game.create }

    it "calls throw_ball method for the game" do
      expect_any_instance_of(Game).to receive(:throw_ball).with("10")
      put :throw_ball, params: { id: game.id, game: { knocked_pins: 10 } }
      expect(response).to have_http_status(:successful)
    end
  end

  describe "GET /score" do
    let(:game) { Game.create }

    it "calls score method for the game" do
      expect_any_instance_of(Game).to receive(:score).and_call_original
      put :score, params: { id: game.id }
      expect(response).to have_http_status(:successful)
    end
  end
end

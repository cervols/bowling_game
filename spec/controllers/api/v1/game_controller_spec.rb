# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::GamesController, type: :controller do
  describe "POST /create" do
    context "when there were no errors" do
      it "creates a game" do
        expect { post :create }.to change { Game.count }.by(1)
        expect(response).to have_http_status(:created)
      end

      it "renders id of created game" do
        post :create

        expect(api_response["id"]).to eq(Game.last.id)
      end
    end

    context "when there were some errors" do
      before do
        allow_any_instance_of(Game).to receive(:save).and_return(false)
      end

      it "doesn't create a game" do
        expect { post :create }.not_to change { Game.count }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PUT /throw_ball" do
    let(:game) { Game.create }

    it "calls throw_ball method for the game" do
      expect_any_instance_of(ThrowBall).to receive(:call)
      put :throw_ball, params: { id: game.id, game: { knocked_pins: 10 } }
      expect(response).to have_http_status(:success)
    end

    context "when wrong game id is provided" do
      it "renders correct error message" do
        put :throw_ball, params: { id: 0, game: { knocked_pins: 10 } }

        expect(response).to have_http_status(:not_found)
        expect(api_response["error"]).to eq("Game not found")
      end
    end

    context "when no params were provided" do
      it "renders correct error message" do
        put :throw_ball, params: { id: game.id }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(api_response["error"]).to eq("Missing parameter")
      end
    end

    context "when invalid number of pins were provided" do
      it "renders correct error message" do
        put :throw_ball, params: { id: game.id, game: { knocked_pins: 11 } }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(api_response["error"]).to eq("Invalid number of pins")
      end
    end

    context "when game is complete" do
      before do
        12.times { put :throw_ball, params: { id: game.id, game: { knocked_pins: 10 } } }
      end

      it "renders correct error message" do
        put :throw_ball, params: { id: game.id, game: { knocked_pins: 1 } }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(api_response["error"]).to eq("Game complete")
      end
    end
  end

  describe "GET /score" do
    let(:game) { Game.create }

    it "calls score method for the game" do
      expect_any_instance_of(CalculateScore).to receive(:call).and_call_original
      get :score, params: { id: game.id }
      expect(response).to have_http_status(:success)
    end

    context "when performs 2 requests" do
      before do
        get :score, params: { id: game.id }
        @etag = response.headers["ETag"]
      end

      context "when the game was not changed after the first request" do
        it "calculates points again" do
          expect_any_instance_of(CalculateScore).not_to receive(:call)
          request.headers["If-None-Match"] = @etag

          get :score, params: { id: game.id }
        end
      end

      context "when the game was changed after the first request" do
        it "doesn't calculate points again" do
          expect_any_instance_of(CalculateScore).to receive(:call).and_call_original
          request.headers["If-None-Match"] = @etag

          put :throw_ball, params: { id: game.id, game: { knocked_pins: 1 } }
          get :score, params: { id: game.id }
        end
      end
    end
  end
end

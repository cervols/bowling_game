# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::V1::Games", type: :request do
  describe "POST /create" do
    context "when request is unauthorized" do
      it "does not create a game" do
        expect do
          post api_v1_games_url
        end.not_to change { Game.count }

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when request is authorized" do
      let(:user) { User.create(email: "email@example.com", password: "qwerty") }
      let(:api_token) { user.api_tokens.create }
      let(:headers) { { Authorization: "Token token=#{api_token.token}, token_id=#{api_token.id}" } }

      context "when there were no errors" do
        it "creates a game" do
          expect do
            post api_v1_games_url, headers: headers
          end.to change { Game.count }.by(1)

          expect(response).to have_http_status(:created)
        end

        it "renders id of created game" do
          post api_v1_games_url, headers: headers

          expect(api_response["id"]).to eq(Game.last.id)
        end
      end

      context "when there were some errors" do
        before do
          allow_any_instance_of(Game).to receive(:save).and_return(false)
        end

        it "doesn't create a game" do
          expect do
            post api_v1_games_url, headers: headers
          end.not_to change { Game.count }

          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end

  describe "PUT /throw_ball" do
    let(:game) { Game.create }
    let(:game_id) { game.id }
    let(:params) { { game: { knocked_pins: 10 } } }

    context "when request is unauthorized" do
      it "does not call throw_ball method for the game" do
        expect_any_instance_of(ThrowBall).not_to receive(:call)
        put throw_ball_api_v1_game_path(game_id), params: params

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when request is authorized" do
      let(:user) { User.create(email: "email@example.com", password: "qwerty") }
      let(:api_token) { user.api_tokens.create }
      let(:headers) { { Authorization: "Token token=#{api_token.token}, token_id=#{api_token.id}" } }

      it "calls ThrowBall service" do
        expect_any_instance_of(ThrowBall).to receive(:call)
        put throw_ball_api_v1_game_path(game_id), params: params, headers: headers

        expect(response).to have_http_status(:success)
      end

      context "when wrong game id is provided" do
        let(:game_id) { 0 }

        it "renders correct error message" do
          put throw_ball_api_v1_game_path(game_id), params: params, headers: headers

          expect(response).to have_http_status(:not_found)
          expect(api_response["error"]).to eq("Game not found")
        end
      end

      context "when no params were provided" do
        let(:params) { {} }

        it "renders correct error message" do
          put throw_ball_api_v1_game_path(game_id), params: params, headers: headers

          expect(response).to have_http_status(:unprocessable_entity)
          expect(api_response["error"]).to eq("Missing parameter")
        end
      end

      context "when invalid number of pins were provided" do
        let(:params) { { game: { knocked_pins: 11 } } }

        it "renders correct error message" do
          put throw_ball_api_v1_game_path(game_id), params: params, headers: headers

          expect(response).to have_http_status(:unprocessable_entity)
          expect(api_response["error"]).to eq("Invalid number of pins")
        end
      end

      context "when game is complete" do
        before do
          12.times do
            put throw_ball_api_v1_game_path(game_id), params: params, headers: headers
          end
        end

        it "renders correct error message" do
          put throw_ball_api_v1_game_path(game_id), params: params, headers: headers

          expect(response).to have_http_status(:unprocessable_entity)
          expect(api_response["error"]).to eq("Game complete")
        end
      end
    end
  end

  describe "GET /score" do
    let(:game) { Game.create }
    let(:game_id) { game.id }

    context "when request is unauthorized" do
      it "does not call throw_ball method for the game" do
        expect_any_instance_of(CalculateScore).not_to receive(:call)
        get score_api_v1_game_path(game_id)

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when request is authorized" do
      let(:user) { User.create(email: "email@example.com", password: "qwerty") }
      let(:api_token) { user.api_tokens.create }
      let(:headers) { { Authorization: "Token token=#{api_token.token}, token_id=#{api_token.id}" } }

      it "calls score method for the game" do
        expect_any_instance_of(CalculateScore).to receive(:call).and_call_original
        get score_api_v1_game_path(game_id), headers: headers

        expect(response).to have_http_status(:success)
      end

      context "when performs 2 requests" do
        before do
          get score_api_v1_game_path(game_id), headers: headers
          @etag = response.headers["ETag"]
        end

        context "when the game was not changed after the first request" do
          it "does not calculate points again" do
            expect_any_instance_of(CalculateScore).not_to receive(:call)
            request.headers["If-None-Match"] = @etag

            get score_api_v1_game_path(game_id), headers: headers
          end
        end

        context "when the game was changed after the first request" do
          it "calculates points again" do
            expect_any_instance_of(CalculateScore).to receive(:call).and_call_original
            request.headers["If-None-Match"] = @etag

            put throw_ball_api_v1_game_path(game_id), params: { game: { knocked_pins: 1 } }, headers: headers
            get score_api_v1_game_path(game_id), headers: headers
          end
        end
      end
    end
  end
end

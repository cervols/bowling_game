# frozen_string_literal: true

require "rails_helper"

RSpec.describe Game, type: :model do
  let(:game) { Game.create }

  describe "#throw_ball" do
    context "when number of knocked pins grater than 10" do
      it "raises an error" do
        expect { game.throw_ball(11) }.to raise_error(Game::InvalidPinNumber)
      end
    end

    context "when number of knocked pins less than 0" do
      it "returns an error" do
        expect { game.throw_ball(11) }.to raise_error(Game::InvalidPinNumber)
      end
    end

    context "when game is finished" do
      before do
        20.times do
          game.throw_ball(1)
        end
      end

      it "returns an error" do
        expect { game.throw_ball(1) }.to raise_error(Game::GameCompleted)
      end
    end
  end

  describe "#score" do
    context "when the game is just started" do
      it "scores points correctly" do
        expect(game.score).to eq(
          frame_scores: [],
          total_score: 0
        )
      end
    end

    context "when the game is in the middle" do
      context "when there is a 'spare' frame" do
        before do
          # first frame
          game.throw_ball(1)
          game.throw_ball(1)
          # second 'spare' frame
          game.throw_ball(9)
          game.throw_ball(1)
          # third frame
          game.throw_ball(1)
          game.throw_ball(1)
        end

        it "scores points correctly" do
          expect(game.score).to eq(
            frame_scores: [2, 13, 15],
            total_score: 15
          )
        end
      end

      context "when there is a 'strike' frame" do
        before do
          # first frame
          game.throw_ball(1)
          game.throw_ball(2)
          # second 'strike' frame
          game.throw_ball(10)
          # third frame
          game.throw_ball(1)
          game.throw_ball(2)
        end

        it "scores points correctly" do
          expect(game.score).to eq(
            frame_scores: [3, 16, 19],
            total_score: 19
          )
        end
      end

      context "when there are 2 'strike' frames" do
        before do
          # first frame
          game.throw_ball(1)
          game.throw_ball(2)
          # second 'strike' frame
          game.throw_ball(10)
          # third 'strike' frame
          game.throw_ball(10)
          # fourth frame
          game.throw_ball(1)
          game.throw_ball(2)
        end

        it "scores points correctly" do
          expect(game.score).to eq(
            frame_scores: [3, 24, 37, 40],
            total_score: 40
          )
        end
      end

      context "when there is an uncomplited frame" do
        context "and this is a 'normal' frame" do
          before do
            # first frame
            game.throw_ball(1)
            game.throw_ball(1)
            # second uncomplited frame
            game.throw_ball(1)
          end

          it "doesn't score points for uncomplited frame" do
            expect(game.score).to eq(
              frame_scores: [2],
              total_score: 2
            )
          end
        end

        context "and this is a 'strike' frame" do
          before do
            # first frame
            game.throw_ball(1)
            game.throw_ball(1)
            # second uncomplited frame
            game.throw_ball(10)
          end

          it "doesn't score points for uncomplited frame" do
            expect(game.score).to eq(
              frame_scores: [2],
              total_score: 2
            )
          end
        end

        context "and this is a 'spare' frame" do
          before do
            # first frame
            game.throw_ball(1)
            game.throw_ball(1)
            # second uncomplited frame
            game.throw_ball(1)
            game.throw_ball(9)
          end

          it "doesn't score points for uncomplited frame" do
            expect(game.score).to eq(
              frame_scores: [2],
              total_score: 2
            )
          end
        end
      end
    end

    context "when the game is finished" do
      context "when last frame is a normal one" do
        before do
          20.times do
            game.throw_ball(1)
          end
        end

        it "scores points correctly" do
          expect(game.score).to eq(
            frame_scores: [2, 4, 6, 8, 10, 12, 14, 16, 18, 20],
            total_score: 20
          )
        end
      end

      context "when last frame is 'spare'" do
        before do
          19.times do
            game.throw_ball(1)
          end
          game.throw_ball(9)
          game.throw_ball(1)
        end

        it "scores points correctly" do
          expect(game.score).to eq(
            frame_scores: [2, 4, 6, 8, 10, 12, 14, 16, 18, 29],
            total_score: 29
          )
        end
      end

      context "when last frame is 'strike'" do
        before do
          18.times do
            game.throw_ball(1)
          end
          game.throw_ball(10)
          game.throw_ball(10)
          game.throw_ball(1)
        end

        it "scores points correctly" do
          expect(game.score).to eq(
            frame_scores: [2, 4, 6, 8, 10, 12, 14, 16, 18, 39],
            total_score: 39
          )
        end
      end

      context "when all the frames are 'strike'" do
        before do
          12.times do
            game.throw_ball(10)
          end
        end

        it "scores points correctly" do
          expect(game.score).to eq(
            frame_scores: [30, 60, 90, 120, 150, 180, 210, 240, 270, 300],
            total_score: 300
          )
        end
      end
    end
  end
end

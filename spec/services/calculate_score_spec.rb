# frozen_string_literal: true

require "rails_helper"

RSpec.describe CalculateScore do
  let(:game) { Game.create }
  subject(:service) { CalculateScore.call(game) }

  describe "#call" do
    context "when the game is just started" do
      it "scores points correctly" do
        expect(service).to eq(
          frame_scores: [],
          total_score: 0
        )
      end
    end

    context "when the game is in the middle" do
      context "when there is a 'spare' frame" do
        before do
          # first frame
          ThrowBall.call(game, 1)
          ThrowBall.call(game, 1)
          # second 'spare' frame
          ThrowBall.call(game, 9)
          ThrowBall.call(game, 1)
          # third frame
          ThrowBall.call(game, 1)
          ThrowBall.call(game, 1)
        end

        it "scores points correctly" do
          expect(service).to eq(
            frame_scores: [2, 13, 15],
            total_score: 15
          )
        end
      end

      context "when there is a 'strike' frame" do
        before do
          # first frame
          ThrowBall.call(game, 1)
          ThrowBall.call(game, 2)
          # second 'strike' frame
          ThrowBall.call(game, 10)
          # third frame
          ThrowBall.call(game, 1)
          ThrowBall.call(game, 2)
        end

        it "scores points correctly" do
          expect(service).to eq(
            frame_scores: [3, 16, 19],
            total_score: 19
          )
        end
      end

      context "when there are 2 'strike' frames" do
        before do
          # first frame
          ThrowBall.call(game, 1)
          ThrowBall.call(game, 2)
          # second 'strike' frame
          ThrowBall.call(game, 10)
          # third 'strike' frame
          ThrowBall.call(game, 10)
          # fourth frame
          ThrowBall.call(game, 1)
          ThrowBall.call(game, 2)
        end

        it "scores points correctly" do
          expect(service).to eq(
            frame_scores: [3, 24, 37, 40],
            total_score: 40
          )
        end
      end

      context "when there is an uncomplited frame" do
        context "and this is a 'normal' frame" do
          before do
            # first frame
            ThrowBall.call(game, 1)
            ThrowBall.call(game, 1)
            # second uncomplited frame
            ThrowBall.call(game, 1)
          end

          it "doesn't score points for uncomplited frame" do
            expect(service).to eq(
              frame_scores: [2],
              total_score: 2
            )
          end
        end

        context "and this is a 'strike' frame" do
          before do
            # first frame
            ThrowBall.call(game, 1)
            ThrowBall.call(game, 1)
            # second uncomplited frame
            ThrowBall.call(game, 10)
          end

          it "doesn't score points for uncomplited frame" do
            expect(service).to eq(
              frame_scores: [2],
              total_score: 2
            )
          end
        end

        context "and this is a 'spare' frame" do
          before do
            # first frame
            ThrowBall.call(game, 1)
            ThrowBall.call(game, 1)
            # second uncomplited frame
            ThrowBall.call(game, 1)
            ThrowBall.call(game, 9)
          end

          it "doesn't score points for uncomplited frame" do
            expect(service).to eq(
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
            ThrowBall.call(game, 1)
          end
        end

        it "scores points correctly" do
          expect(service).to eq(
            frame_scores: [2, 4, 6, 8, 10, 12, 14, 16, 18, 20],
            total_score: 20
          )
        end
      end

      context "when last frame is 'spare'" do
        before do
          19.times do
            ThrowBall.call(game, 1)
          end
          ThrowBall.call(game, 9)
          ThrowBall.call(game, 1)
        end

        it "scores points correctly" do
          expect(service).to eq(
            frame_scores: [2, 4, 6, 8, 10, 12, 14, 16, 18, 29],
            total_score: 29
          )
        end
      end

      context "when last frame is 'strike'" do
        before do
          18.times do
            ThrowBall.call(game, 1)
          end
          ThrowBall.call(game, 10)
          ThrowBall.call(game, 10)
          ThrowBall.call(game, 1)
        end

        it "scores points correctly" do
          expect(service).to eq(
            frame_scores: [2, 4, 6, 8, 10, 12, 14, 16, 18, 39],
            total_score: 39
          )
        end
      end

      context "when all the frames are 'strike'" do
        before do
          12.times do
            ThrowBall.call(game, 10)
          end
        end

        it "scores points correctly" do
          expect(service).to eq(
            frame_scores: [30, 60, 90, 120, 150, 180, 210, 240, 270, 300],
            total_score: 300
          )
        end
      end
    end
  end
end

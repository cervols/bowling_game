# frozen_string_literal: true

require "rails_helper"

RSpec.describe ThrowBall do
  subject { described_class.call(game, knocked_pins) }

  let(:game) { Game.create }
  let(:knocked_pins) { 1 }

  describe "#call" do
    it "updates the balls field with the number of knocked pins" do
      expect { subject }.to change { game.balls }.from([]).to([knocked_pins])
    end

    context "when number of knocked pins grater than 10" do
      let(:knocked_pins) { 11 }

      it "raises an error" do
        expect { subject }.to raise_error(Game::InvalidPinNumber)
      end
    end

    context "when number of knocked pins less than 0" do
      let(:knocked_pins) { -1 }

      it "returns an error" do
        expect { subject }.to raise_error(Game::InvalidPinNumber)
      end
    end

    context "when game is finished" do
      before do
        20.times do
          ThrowBall.call(game, 1)
        end
      end

      it "returns an error" do
        expect { subject }.to raise_error(Game::GameComplete)
      end
    end
  end
end

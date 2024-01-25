# frozen_string_literal: true

class ThrowBall < BaseService
  def initialize(game, knocked_pins)
    super(game)
    @knocked_pins = knocked_pins
  end

  def call
    raise Game::InvalidPinNumber, "invalid number of pins" if @knocked_pins > Game::MAX_FRAME_PINS_NUMBER || @knocked_pins.negative?

    raise Game::GameComplete, "game is complete" if completed_frames_count >= Game::MAX_FRAMES_NUMBER

    game.balls.push(@knocked_pins)
    game.save
  end

  private

    def completed_frames_count
      count = 0
      ball_index = 0

      Game::MAX_FRAMES_NUMBER.times do
        break if ball_index >= game.balls.size
        break unless frame_complete?(ball_index)

        count += 1

        if strike?(ball_index)
          ball_index += 1
        elsif spare?(ball_index)
          ball_index += 2
        else
          ball_index += 2
        end
      end

      count
    end
end

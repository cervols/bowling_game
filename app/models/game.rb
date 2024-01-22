# frozen_string_literal: true

class Game < ApplicationRecord
  MAX_PINS_NUMBER = 10
  MAX_FRAMES_NUMBER = 10

  InvalidPinNumber = Class.new(ArgumentError)
  GameComplete = Class.new(StandardError)

  def throw_ball(knocked_pins)
    raise InvalidPinNumber, "invalid number of pins" if knocked_pins > MAX_PINS_NUMBER || knocked_pins.negative?

    raise GameComplete, "game is complete" if completed_frames_count >= MAX_FRAMES_NUMBER

    balls.push(knocked_pins)
    save
  end

  def score
    ball_index = 0
    total_score = 0
    frame_scores = []

    MAX_FRAMES_NUMBER.times do
      break if ball_index >= balls.size
      break unless frame_complete?(ball_index)

      if strike?(ball_index)
        total_score += 10 + strike_bonus(ball_index)
        frame_scores << total_score
        ball_index += 1
      elsif spare?(ball_index)
        total_score += 10 + spare_bonus(ball_index)
        frame_scores << total_score
        ball_index += 2
      else
        total_score += frame_score(ball_index)
        frame_scores << total_score
        ball_index += 2
      end
    end

    {
      frame_scores: frame_scores,
      total_score: total_score
    }
  end

  private

    def completed_frames_count
      count = 0
      ball_index = 0

      MAX_FRAMES_NUMBER.times do
        break if ball_index >= balls.size
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

    def frame_complete?(ball_index)
      if strike?(ball_index)
        next_two_balls(ball_index).size == 2
      elsif spare?(ball_index)
        next_ball(ball_index + 1).present?
      else
        next_ball(ball_index).present?
      end
    end

    def strike?(ball_index)
      balls[ball_index] == 10
    end

    def spare?(ball_index)
      frame_score(ball_index) == 10
    end

    def frame_score(ball_index)
      first_ball = balls[ball_index] || 0
      second_ball = balls[ball_index + 1] || 0
      first_ball + second_ball
    end

    def next_ball(ball_index)
      balls[ball_index + 1]
    end

    def next_two_balls(ball_index)
      balls[ball_index + 1..ball_index + 2]
    end

    def strike_bonus(ball_index)
      next_two_balls(ball_index).sum
    end

    def spare_bonus(ball_index)
      balls[ball_index + 2]
    end
end

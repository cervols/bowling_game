# frozen_string_literal: true

class CalculateScore < BaseService
  def call
    ball_index = 0
    total_score = 0
    frame_scores = []

    Game::MAX_FRAMES_NUMBER.times do
      break if ball_index >= game.balls.size
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

    def strike_bonus(ball_index)
      next_two_balls(ball_index).sum
    end

    def spare_bonus(ball_index)
      game.balls[ball_index + 2]
    end
end

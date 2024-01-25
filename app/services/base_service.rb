# frozen_string_literal: true

class BaseService
  def self.call(*args, &block)
    new(*args, &block).call
  end

  def initialize(game)
    @game = game
  end

  protected

    attr_reader :game

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
      game.balls[ball_index] == 10
    end

    def spare?(ball_index)
      frame_score(ball_index) == 10
    end

    def frame_score(ball_index)
      first_ball = @game.balls[ball_index] || 0
      second_ball = @game.balls[ball_index + 1] || 0
      first_ball + second_ball
    end

    def next_ball(ball_index)
      game.balls[ball_index + 1]
    end

    def next_two_balls(ball_index)
      game.balls[ball_index + 1..ball_index + 2]
    end
end

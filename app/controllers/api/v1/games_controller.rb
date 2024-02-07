# frozen_string_literal: true

class Api::V1::GamesController < Api::V1::ApiController
  before_action :set_game, only: %i[throw_ball score]

  def create
    @game = Game.create

    if @game.save
      render json: { id: @game.id }, status: :created
    else
      render json: @game.errors, status: :unprocessable_entity
    end
  end

  def throw_ball
    @game.throw_ball(knocked_pins)
  end

  def score
    render json: @game.score
  end

  private

    def set_game
      @game = Game.find(params[:id])
    end

    def knocked_pins
      params.require(:game).permit(:knocked_pins)[:knocked_pins]
    end
end

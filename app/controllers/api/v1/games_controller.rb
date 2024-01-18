# frozen_string_literal: true

class Api::V1::GamesController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActionController::ParameterMissing, with: :parameter_missing

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
    if stale?(etag: @game, last_modified: @game.updated_at)
      render json: @game.score
    end
  end

  private

    def set_game
      @game = Game.find(params[:id])
    end

    def knocked_pins
      params.require(:game).permit(:knocked_pins)[:knocked_pins].to_i
    end

    def record_not_found
      render json: { error: "Game not found" }, status: :not_found
    end

    def parameter_missing
      render json: { error: "Missing parameter" }, status: :unprocessable_entity
    end
end

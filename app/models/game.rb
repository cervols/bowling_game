# frozen_string_literal: true

class Game < ApplicationRecord
  InvalidPinNumber = Class.new(ArgumentError)
  GameComplete = Class.new(StandardError)

  MAX_FRAME_PINS_NUMBER = 10
  MAX_FRAMES_NUMBER = 10
end

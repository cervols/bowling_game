# frozen_string_literal: true

require "rails_helper"

RSpec.describe Game, type: :model do
  it "is valid with no parameters" do
    expect(Game.new).to be_valid
  end
end

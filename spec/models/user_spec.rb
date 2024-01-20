require "rails_helper"

RSpec.describe User, type: :model do
  let(:password) { "qwerty" }

  it "validates presence of email" do
    user = User.new(password: password)

    expect(user).not_to be_valid
    expect(user.errors.messages[:email]).to include("can't be blank")
  end

  it "normalizes email before user is saved" do
    email = "\t  EMAIL@example.com\n"
    normalized_email = "email@example.com"
    user = User.create(email: email, password: password)

    expect(user.email).to eq(normalized_email)
  end
end

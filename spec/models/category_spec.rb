require 'rails_helper'

RSpec.describe Category, type: :model do
  let(:user) { User.create!(email_address: "category@example.com", password: "Password123!", password_confirmation: "Password123!") }

  it "requires a name and keeps names unique per user" do
    user.categories.create!(name: "Ruby")
    expect(user.categories.new(name: "Ruby")).not_to be_valid
    expect(user.categories.new(name: "")).not_to be_valid
  end

  it "allows separate users to use the same category name" do
    another = User.create!(email_address: "another@example.com", password: "Password123!", password_confirmation: "Password123!")
    expect(user.categories.create!(name: "Ruby")).to be_persisted
    expect(another.categories.create!(name: "Ruby")).to be_persisted
  end
end

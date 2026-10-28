require 'rails_helper'

RSpec.describe User, type: :model do
  it "normalizes email addresses and requires unique email addresses" do
    User.create!(email_address: "  USER@example.com ", password: "Password123!", password_confirmation: "Password123!")
    expect(User.new(email_address: "user@example.com", password: "Password123!", password_confirmation: "Password123!")).not_to be_valid
  end
end

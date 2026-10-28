require "rails_helper"

RSpec.describe Tag, type: :model do
  let(:user) do
    User.create!(email_address: "tag@example.com", password: "Password123!", password_confirmation: "Password123!")
  end
  describe "validations" do
    it "requires a name" do
      tag = user.tags.new(name: nil)

      expect(tag).not_to be_valid
    end

    it "requires a unique name" do
      user.tags.create!(name: "security")
      duplicate = user.tags.new(name: "security")

      expect(duplicate).not_to be_valid
    end
  end

  describe "associations" do
    it "can be associated with notes" do
      tag = user.tags.create!(name: "performance")

      expect(tag.notes).to be_empty
    end

    it "allows different users to reuse a tag name" do
      other_user = User.create!(email_address: "other@example.com", password: "Password123!", password_confirmation: "Password123!")
      expect(user.tags.create!(name: "rails")).to be_persisted
      expect(other_user.tags.create!(name: "rails")).to be_persisted
    end
  end
end

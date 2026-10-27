require "rails_helper"

RSpec.describe Tag, type: :model do
  describe "validations" do
    it "requires a name" do
      tag = Tag.new(name: nil)

      expect(tag).not_to be_valid
    end

    it "requires a unique name" do
      Tag.create!(name: "security")
      duplicate = Tag.new(name: "security")

      expect(duplicate).not_to be_valid
    end
  end

  describe "associations" do
    it "can be associated with notes" do
      tag = Tag.create!(name: "performance")

      expect(tag.notes).to be_empty
    end
  end
end

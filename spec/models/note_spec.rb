require "rails_helper"

RSpec.describe Note, type: :model do
  let(:user) do
    User.create!(
      email_address: "note-test@example.com",
      password: "Password123!",
      password_confirmation: "Password123!"
    )
  end

  describe "validations" do
    it "is valid with a title and note type" do
      note = user.notes.new(
        title: "Ruby Basics",
        note_type: "ruby"
      )

      expect(note).to be_valid
    end

    it "is invalid without a title" do
      note = user.notes.new(note_type: "ruby")

      expect(note).not_to be_valid
      expect(note.errors[:title]).to be_present
    end

    it "is invalid without a note type" do
      note = user.notes.new(title: "Ruby Basics")

      expect(note).not_to be_valid
      expect(note.errors[:note_type]).to be_present
    end
  end

  describe "scopes" do
    it "returns only favorite notes" do
      favorite = user.notes.create!(
        title: "Favorite Note",
        note_type: "rails",
        favorite: true
      )

      user.notes.create!(
        title: "Regular Note",
        note_type: "rails",
        favorite: false
      )

      expect(user.notes.favorites).to contain_exactly(favorite)
    end
  end
end

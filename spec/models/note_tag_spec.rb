require 'rails_helper'

RSpec.describe NoteTag, type: :model do
  it "prevents duplicate assignments and tags owned by another user" do
    owner = User.create!(email_address: "nt@example.com", password: "Password123!", password_confirmation: "Password123!")
    stranger = User.create!(email_address: "nt2@example.com", password: "Password123!", password_confirmation: "Password123!")
    note = owner.notes.create!(title: "Owned", note_type: "ruby")
    tag = owner.tags.create!(name: "rails")
    expect(NoteTag.create(note: note, tag: tag)).to be_valid
    expect(NoteTag.new(note: note, tag: tag)).not_to be_valid
    expect(NoteTag.new(note: note, tag: stranger.tags.create!(name: "rails"))).not_to be_valid
  end
end

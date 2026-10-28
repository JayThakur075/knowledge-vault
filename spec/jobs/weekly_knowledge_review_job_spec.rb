require "rails_helper"

RSpec.describe WeeklyKnowledgeReviewJob, type: :job do
  it "stores a per-user count of notes untouched for 30 days without reading note content" do
    user = User.create!(email_address: "review@example.com", password: "Password123!", password_confirmation: "Password123!")
    stale = user.notes.create!(title: "Old note", note_type: "rails")
    stale.update_column(:updated_at, 31.days.ago)
    user.notes.create!(title: "Recent note", note_type: "ruby")

    expect(Rails.cache).to receive(:write).with([ "weekly-review", user.id ], 1, expires_in: 8.days)

    described_class.perform_now
  end
end

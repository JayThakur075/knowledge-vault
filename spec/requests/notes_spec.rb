require "rails_helper"

RSpec.describe "Notes", type: :request do
  let(:password) { "Password123!" }

  let!(:user) do
    User.create!(
      email_address: "notes@example.com",
      password: password,
      password_confirmation: password
    )
  end

  let!(:note) do
    user.notes.create!(
      title: "Ruby Basics",
      content: "Learning Ruby and Rails",
      note_type: "rails"
    )
  end

  before do
    post session_path, params: {
      email_address: user.email_address,
      password: password
    }
  end

  describe "GET /notes" do
    it "returns http success" do
      get notes_path

      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /notes/:id" do
    it "returns http success" do
      get note_path(note)

      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /notes/new" do
    it "returns http success" do
      get new_note_path

      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /notes/:id/edit" do
    it "returns http success" do
      get edit_note_path(note)

      expect(response).to have_http_status(:success)
    end
  end
end
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

  it "creates, updates, and deletes a note with user-owned tags" do
    category = user.categories.create!(name: "Debugging")
    another_user = User.create!(email_address: "second-notes@example.com", password: password, password_confirmation: password)

    expect {
      post notes_path, params: { note: { title: "New note", note_type: "ruby", content: "example", category_id: category.id, user_id: another_user.id }, tag_names: "debugging, ruby" }
    }.to change(user.notes, :count).by(1)
    created = user.notes.order(:id).last
    expect(response).to redirect_to(note_path(created))
    expect(created.user).to eq(user)
    expect(created.tags.pluck(:name)).to contain_exactly("debugging", "ruby")

    patch note_path(created), params: { note: { title: "Updated note", favorite: "1" }, tag_names: "rails" }
    expect(response).to redirect_to(note_path(created))
    expect(created.reload).to have_attributes(title: "Updated note", favorite: true)
    expect(created.tags.pluck(:name)).to eq([ "rails" ])

    expect { delete note_path(created) }.to change(user.notes, :count).by(-1)
  end
end

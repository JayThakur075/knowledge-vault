require "rails_helper"

RSpec.describe "Knowledge Vault features", type: :request do
  let(:password) { "Password123!" }
  let!(:user) { User.create!(email_address: "owner@example.com", password: password, password_confirmation: password) }
  let!(:other_user) { User.create!(email_address: "other-owner@example.com", password: password, password_confirmation: password) }

  def sign_in(user, password)
    post session_path, params: { email_address: user.email_address, password: password }
  end

  it "requires authentication for the dashboard and private resources" do
    get dashboard_path
    expect(response).to redirect_to(new_session_path)
    get notes_path
    expect(response).to redirect_to(new_session_path)
  end

  it "scopes dashboard counts and recent notes to the signed-in user" do
    sign_in(user, password)
    user.notes.create!(title: "My private note", note_type: "rails")
    other_user.notes.create!(title: "Someone else's note", note_type: "ruby")

    get dashboard_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("My private note")
    expect(response.body).not_to include("Someone else's note")
  end

  it "searches notes by tag and composes filters safely" do
    sign_in(user, password)
    note = user.notes.create!(title: "Database tuning", content: "Query plan", note_type: "rails", favorite: true)
    note.tags << user.tags.create!(name: "performance")
    other = user.notes.create!(title: "Unrelated", note_type: "ruby")
    other.tags << user.tags.create!(name: "security")
    private_note = other_user.notes.create!(title: "Private performance note", note_type: "rails")
    private_note.tags << other_user.tags.create!(name: "performance")

    get notes_path, params: { query: "performance", favorite: "true", note_type: "rails" }

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Database tuning")
    expect(response.body).not_to include("Unrelated", "Private performance note")
  end

  it "paginates notes and preserves filters in navigation" do
    sign_in(user, password)
    12.times { |i| user.notes.create!(title: "Rails note #{i}", note_type: "rails") }

    get notes_path, params: { note_type: "rails", query: "Rails" }

    expect(response.body).to include("Page 1 of 2")
    expect(response.body).to include("note_type=rails")
    expect(response.body).to include("query=Rails")
  end

  it "does not allow a user to view another user's note or use their category" do
    sign_in(user, password)
    private_note = other_user.notes.create!(title: "Private", note_type: "sql")
    private_category = other_user.categories.create!(name: "Other user's category")

    get note_path(private_note)
    expect(response).to have_http_status(:not_found)

    post notes_path, params: { note: { title: "Attempt", note_type: "rails", category_id: private_category.id } }
    expect(response).to have_http_status(:not_found)
  end

  it "creates and scopes saved links to their owner" do
    sign_in(user, password)
    post links_path, params: { link: { title: "Rails Guides", url: "https://guides.rubyonrails.org" }, tag_names: "rails, docs" }
    link = user.links.last

    expect(response).to redirect_to(link_path(link))
    expect(link.tags.pluck(:name)).to contain_exactly("rails", "docs")

    patch link_path(link), params: { link: { title: "Rails documentation", url: "https://guides.rubyonrails.org" }, tag_names: "rails, reference" }
    expect(link.reload.title).to eq("Rails documentation")
    expect(link.tags.pluck(:name)).to contain_exactly("rails", "reference")

    sign_in(other_user, password)
    get link_path(link)
    expect(response).to have_http_status(:not_found)

    expect { delete link_path(link) }.not_to change(Link, :count)
  end

  it "rejects unsafe saved link schemes" do
    sign_in(user, password)
    post links_path, params: { link: { title: "Unsafe", url: "javascript:alert(1)" } }
    expect(response).to have_http_status(:unprocessable_content)
    expect(user.links).to be_empty
  end
end

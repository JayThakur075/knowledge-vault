require "rails_helper"

RSpec.describe "Categories", type: :request do
  let(:password) { "Password123!" }

  let!(:user) do
    User.create!(
      email_address: "categories@example.com",
      password: password,
      password_confirmation: password
    )
  end

  let!(:category) do
    user.categories.create!(name: "Ruby on Rails")
  end

  before do
    post session_path, params: {
      email_address: user.email_address,
      password: password
    }
  end

  describe "GET /categories" do
    it "returns http success" do
      get categories_path

      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /categories/new" do
    it "returns http success" do
      get new_category_path

      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /categories/:id/edit" do
    it "returns http success" do
      get edit_category_path(category)

      expect(response).to have_http_status(:success)
    end
  end

  it "creates, renames, and deletes a category without deleting its notes" do
    post categories_path, params: { category: { name: "Databases" } }
    created = user.categories.find_by!(name: "Databases")
    note = user.notes.create!(title: "SQL note", note_type: "sql", category: created)

    patch category_path(created), params: { category: { name: "SQL" } }
    expect(created.reload.name).to eq("SQL")

    expect { delete category_path(created) }.not_to change(Note, :count)
    expect(note.reload.category).to be_nil
  end

  it "does not allow another user to modify a category" do
    foreign_category = User.create!(email_address: "foreign-category@example.com", password: password, password_confirmation: password).categories.create!(name: "Private")
    patch category_path(foreign_category), params: { category: { name: "Stolen" } }
    expect(response).to have_http_status(:not_found)
  end
end

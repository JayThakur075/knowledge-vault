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
end
require "rails_helper"

RSpec.describe "Registrations", type: :request do
  describe "GET /sign_up" do
    it "returns http success" do
      get sign_up_path

      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /sign_up" do
    let(:valid_params) do
      {
        user: {
          email_address: "newuser@example.com",
          password: "Password123!",
          password_confirmation: "Password123!"
        }
      }
    end

    it "creates a new user" do
      expect {
        post sign_up_path, params: valid_params
      }.to change(User, :count).by(1)
    end

    it "redirects after successful registration" do
      post sign_up_path, params: valid_params

      expect(response).to have_http_status(:redirect)
    end
  end
end

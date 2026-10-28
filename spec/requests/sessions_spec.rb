require "rails_helper"

RSpec.describe "Sessions", type: :request do
  let(:password) { "Password123!" }
  let!(:user) { User.create!(email_address: "login@example.com", password: password, password_confirmation: password) }

  it "signs in, restores a requested page, and signs out" do
    get notes_path
    expect(response).to redirect_to(new_session_path)
    post session_path, params: { email_address: user.email_address, password: password }
    expect(response).to redirect_to(notes_url)
    delete session_path
    expect(response).to redirect_to(new_session_path)
  end

  it "rejects invalid credentials" do
    post session_path, params: { email_address: user.email_address, password: "wrong-password" }
    expect(response).to redirect_to(new_session_path)
    follow_redirect!
    expect(response.body).to include("Try another email address or password")
  end
end

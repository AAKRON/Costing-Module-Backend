require 'rails_helper'

RSpec.describe Api::V1::SessionsController, type: :controller do
    render_views

    describe "POST create" do
        before(:each) do
          @user = build(:user, password: "password")
          @user.save
        end

        it "returns username and token for VALID credentials" do
           valid_credentials = {username: @user.username, password: "password" }

           post :create, valid_credentials
           body = JSON.parse(response.body)

          expect(body["username"]).to eq valid_credentials[:username]
          expect(body["token"]).to_not be_nil
        end

        it "returns an error message for INVALID credentials" do
            invalid_credentials = { username: @user.username, password: nil }

            post :create, invalid_credentials
            body = JSON.parse(response.body)

            expect(body["message"]).to eq "invalid username or password"
            expect(response.status).to eq 401
        end
    end
end

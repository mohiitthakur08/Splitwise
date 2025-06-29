# spec/controllers/users_controller_spec.rb
require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:user) { create(:user) }
  let(:friend) { create(:user) }

  before { sign_in user }

  describe 'PATCH #update' do
    it 'updates the user and redirects with a notice' do
      patch :update, params: {
        user: {
          name: 'Updated Name',
          email: 'updated@example.com',
          mobile_number: '9999999999'
        }
      }

      user.reload
      expect(user.name).to eq('Updated Name')
      expect(user.email).to eq('updated@example.com')
      expect(user.mobile_number).to eq('9999999999')
      expect(response).to redirect_to(profile_path)
      expect(flash[:notice]).to eq('Profile updated successfully.')
    end
  end
end

require 'rails_helper'

describe UsersController do

  describe 'GET \'index\'' do
    let!(:bot_user) { create(:user, :bot) }
    let!(:user)     { create(:user) }

    render_views

    it 'renders the correct partial' do
      get :index

      expect(response).to render_template('index')
    end

    it 'does not include bot users' do
      get :index

      expect(assigns[:users]).to match_array([user])
    end
  end

  describe 'PATCH \'update\'' do
    let!(:user) { create(:user, send_standup_report: true) }

    render_views

    it 'renders nothing' do
      patch :update, id: user.id, user: { send_standup_report: false }

      expect(response[:body]).to be_blank
    end

    it 'updates the send_standup_report flag' do
      patch :update, id: user.id, user: { send_standup_report: false }

      user.reload

      expect(user.send_standup_report).to be_falsey
    end

    it 'does not update not permitted parameters' do
      patch :update, id: user.id, user: { email: 'another.email@domain.com' }

      user.reload

      expect(user.email).to_not eq('another.email@domain.com')
    end
  end

end

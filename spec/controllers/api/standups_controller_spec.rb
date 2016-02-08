require 'rails_helper'

describe Api::StandupsController do

  describe 'GET \'start\'' do
    let!(:setting) { create(:setting) }

    before do
      allow_any_instance_of(Standupbot::Sync).to receive(:valid?).and_return(true)
      allow_any_instance_of(Standupbot::Sync).to receive(:create!)
    end

    context 'when format is text' do
      render_views

      it 'returns an HTTP 200' do
        get :start, format: :text

        expect(response).to have_http_status(:ok)
      end

      it 'renders the correct template' do
        get :start, format: :text

        expect(response).to render_template(:start)
      end

      context 'when there are errors' do
        let(:errors) { [ Faker::Lorem.sentence, Faker::Lorem.sentence ] }

        before do
          allow_any_instance_of(Standupbot::Sync).to receive(:valid?).and_return(false)
          allow_any_instance_of(Standupbot::Sync).to receive(:errors).and_return(errors)
        end

        it 'returns a string with all the errors separated by comma' do
          get :start, format: :text

          expect(response.body.strip).to eq(errors.join(', '))
        end
      end

      context 'when there are no errors' do
        before { allow_any_instance_of(Standupbot::Sync).to receive(:valid?).and_return(true) }

        it 'returns a string with a success message' do
          get :start, format: :text

          expect(response.body.strip).to eq('Well done! Everything is ok, the standup will start soon.')
        end
      end
    end
  end

end

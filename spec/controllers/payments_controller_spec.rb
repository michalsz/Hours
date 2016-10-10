RSpec.describe PaymentsController, type: :controller do
  include Devise::TestHelpers
  include Warden::Test::Helpers

  Warden.test_mode!
  before do
    user = double('user')
    allow(user).to receive(:language).and_return('pl')
    allow(request.env['warden']).to receive(:authenticate!).and_return(user)
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe 'GET new' do
    context 'regular new action' do
      subject { get :new }

      it 'renders new' do
        expect(subject).to render_template(:new)
      end

      it 'assing new payment' do
        subject
        expect(assigns(:payment)).not_to eq nil
      end
    end
  end
end

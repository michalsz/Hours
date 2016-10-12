RSpec.describe PaymentsController, type: :controller do
  include Devise::TestHelpers
  include Warden::Test::Helpers

  Warden.test_mode!
  before do
    Rails.application.routes.default_url_options[:host] = 'domain.com'
    create(:user, id: 1)
    user = double('user')
    allow(user).to receive(:language).and_return('pl')
    allow(user).to receive(:id).and_return(1)
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

  describe 'POST create' do
    before do
      allow(Przelewy24).to receive(:send_request).and_return(response)
    end
    context 'regular create action' do
      let(:token) { 'dfsa43fsa433HJ&fase4'}
      let(:response) { double('response', error: '0', token: token, body: 'fdsfs') }
      subject { post :create,
        payment: { user_id: 1, email: 'tree@dasd.pl', subscription: 'medium'} }

      it 'redirects to przelewy24' do
        request.env["HTTP_REFERER"] = '/'
        expect(subject).to redirect_to "https://przelewy24.pl/trnRequest/#{token}"
      end
    end
  end
end

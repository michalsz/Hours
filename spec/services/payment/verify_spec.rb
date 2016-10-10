describe Payment::Verify do
  let(:payment) { create(:user_payment, :awaiting_verification) }
  let(:perform) { described_class.call(payment: payment) }
  let(:result) { perform.result }

  before do
    allow_any_instance_of(described_class).to receive(:payment_params).and_return({})
    allow(Przelewy24).to receive(:send_request).with(:verify, {}).and_return(expected_response)
    allow(Przelewy24).to receive(:sign)

    #allow(AssignProgressBadge).to receive(:call)
  end

  context 'updates payment' do
    let(:expected_response) { double('response', error: '0') }

    it 'sends request to p24 module' do
      perform
      expect(Przelewy24).to have_received(:send_request).with(:verify, {}) { expected_response }
    end

    it 'set payment status to success' do
      expect { perform }.to change { payment.reload.status }.to 'success'
    end

    it 'returns response' do
      expect(result).to eq(expected_response)
    end

    context 'registered user payment' do
      before do
        allow_any_instance_of(described_class).to receive(:user).and_return(user)
      end

      let(:payment) { create(:user_payment, :awaiting_verification) }
      let(:user) { payment.user }
      let(:current_badge_progress) { 1 }

      it 'calls assign progress badge service' do
        perform
        #expect(AssignProgressBadge).to have_received(:call).with(user: user, badge_type: 'donation_count', current_progress: current_badge_progress)
      end
    end

    context 'anonymous payment' do
      it 'doesnt call assign progress badge service' do
        perform
        #expect(AssignProgressBadge).to_not have_received(:call)
      end
    end
  end

  context 'fails on error response' do
    let(:expected_response) { double('response', error: '2', errorMessage: 'Something went wrong') }
    let(:error_message) { perform.error }

    it 'returns error with errorMessage' do
      expect(error_message).to eq(expected_response.errorMessage)
    end
  end
end

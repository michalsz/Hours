describe Payment::Register do
  let(:payment) { create(:user_payment, :pending) }
  let(:perform) { described_class.call(payment: payment) }
  let(:result) { perform.result }

  before(:each) do
    allow_any_instance_of(described_class).to receive(:payment_params).and_return({})
    allow(Przelewy24).to receive(:send_request).with(:register, {}).and_return(expected_response)
    allow(Przelewy24).to receive(:sign)
  end

  context 'response ok' do
    let(:expected_response) { double('response', token: 'Test-Token', error: '0') }

    it 'sends request to p24 module' do
      perform
      expect(Przelewy24).to have_received(:send_request).with(:register, {}) { expected_response }
    end

    it 'updates payment with received token' do
      expect { perform }.to change { payment.reload.token }.to expected_response.token
    end

    it 'returns updated payment' do
      expect(result).to eq(payment.reload)
    end
  end

  context 'response error' do
    let(:expected_response) { double('response', error: '2', errorMessage: 'Something went wrong') }
    let(:error_message) { perform.error }

    # it 'returns error with errorMessage' do
    #   expect(error_message).to eq(expected_response.errorMessage)
    # end
  end
end

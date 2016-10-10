describe Payment::Update do
  let(:payment) { create(:user_payment, :pending) }
  let(:perform) { described_class.call(payment: payment, params: params) }
  let(:result) { perform.result }

  let(:params) {{
    p24_amount: 100,
    p24_currency: 'PLN',
    p24_order_id: 100,
    p24_method: 100,
    p24_statement: 'Payment'
  }}

  let(:parsed_params) {{
    amount: params[:p24_amount],
    currency: params[:p24_currency],
    order_id: params[:p24_order_id],
    payment_method: params[:p24_method],
    payment_statement: params[:p24_statement]
  }}

  let(:response) { double('response') }
  let(:verification_service) { Payment::Verify }

  context 'updates payment' do
    before do
      allow(response).to receive(:result)
      allow(verification_service).to receive(:call).with(payment: payment.reload).and_return(response)
    end

    it 'updates payment status to awaiting_verification' do
      expect { perform }.to change { payment.reload.status }.to 'awaiting_verification'
    end

    it 'updates payment object with provided data' do
      perform
      expect(payment.reload).to have_attributes(parsed_params)
    end

    it 'calls verification service' do
      perform
      expect(verification_service).to have_received(:call).with(payment: payment.reload)
    end
  end
end

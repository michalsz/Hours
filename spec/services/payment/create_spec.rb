describe Payment::Create do
  let(:perform) { described_class.call(user: user,  params: params) }
  let(:user) { create(:user) }

  context 'creates new payment object' do
    let(:response) { double('response', success?: true, result: nil) }

    before do
      allow(Payment::Register).to receive(:call).and_return(response)
    end

    context 'payment by registered user' do
      let(:user) { create(:user) }
      let(:params) {{ email: 'email@rails.app', amount: 1000 }}

      it 'assigns payment to user' do
        perform
        expect(Payment.last.user).to eq(user)
      end

      it 'saves payment to database' do
        expect { perform }.to change { Payment.count }.by 1
      end
    end

    context 'payment by anonymous user' do
      let(:params) {{ email: 'email@rails.app', amount: 1000 }}

      it 'assigns payment to user' do
        perform
        expect(Payment.last.user).not_to be_nil
      end

      it 'saves payment to database' do
        expect { perform }.to change { Payment.count }.by 1
      end
    end
  end

  context 'calls register service' do
    let(:params) {{ email: 'email@rails.app', amount: 1000 }}
    let(:payment) { build(:user_payment) }

    let(:updated_payment) { payment.assign_attributes(token: 'aaa') }
    let(:response) { double('response', success?: true, result: updated_payment) }

    before do
      allow_any_instance_of(described_class).to receive(:create_payment).and_return(payment)
      allow(Payment::Register).to receive(:call).with(payment: payment).and_return(response)
    end

    it 'calls payment registration service' do
      perform
      expect(Payment::Register).to have_received(:call).with(payment: payment) { response }
    end
  end

  context 'missing params' do
    let(:params) {{ email: 'email@rails.app' }}
    let(:error_message) { perform.error }

    it 'fails with missing_params error' do
      expect(error_message).to eq(:missing_params)
    end

    it 'doesnt call payment registration service' do
      spy = class_spy(Payment::Register)
      perform
      expect(spy).to_not have_received(:call)
    end

    it 'doesnt create payment object' do
      expect { perform }.to_not change { Payment.count }
    end
  end
end

describe Payment::Cancel do
  let(:perform) { described_class.call(payment: payment) }
  let(:result) { perform.result }

  context 'payment pending' do
    let(:payment) { create(:user_payment, :pending) }

    it 'sets payment status to cancelled' do
      expect { perform }.to change { payment.reload.status }.to 'cancelled'
    end

    it 'clears token' do
      expect { perform }.to change { payment.reload.token }.to nil
    end

    it 'returns updated payment object' do
      expect(result).to be_kind_of(Payment)
    end
  end

  context 'payment already cancelled' do
    let(:payment) { create(:user_payment, :cancelled) }

    it 'fails to update payment' do
      expect(payment.reload.token).to eq(payment.token)
      expect(payment.reload.status).to eq(payment.status)
    end

    it 'returns nil' do
      expect(result).to be_nil
    end

    it 'fails with already_cancelled error' do
      expect(perform.error).to eq(:already_cancelled)
    end
  end

  context 'cannot cancel success/awaiting_verification payment' do
    let(:payment) { create(:user_payment, :success) }

    it 'fails to update payment' do
      expect(payment.reload.token).to eq(payment.token)
      expect(payment.reload.status).to eq(payment.status)
    end

    it 'returns nil' do
      expect(result).to be_nil
    end

    it 'fails with cannot_cancel error' do
      expect(perform.error).to eq(:cannot_cancel)
    end
  end
end

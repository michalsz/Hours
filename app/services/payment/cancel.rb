class Payment::Cancel < BusinessProcess::Base
  needs :payment

  def call
    if payment.pending?
      payment.update(token: nil, status: :cancelled)
      payment
    elsif payment.cancelled?
      fail(:already_cancelled)
    else
      fail(:cannot_cancel)
    end
  end
end

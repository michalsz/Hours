class Payment::Verify < BusinessProcess::Base
  needs :payment

  def call
    response = Przelewy24.send_request(:verify, payment_params)

    if response.error == '0'
      assign_progress_badge if user
      payment.update(status: :success)
    else
      fail(response.errorMessage)
    end

    response
  end

  private

  def assign_progress_badge
  #  AssignProgressBadge.call(user: user, badge_type: 'donation_count', current_progress: user.payments.count)
  end

  def user
    @_user ||= payment.user
  end

  def payment_params
    {
      p24_merchant_id: Przelewy24.merchant_id,
      p24_pos_id: Przelewy24.merchant_id,
      p24_session_id: payment.session_id,
      p24_amount: payment.amount,
      p24_currency: payment.currency,
      p24_order_id: payment.order_id,
      p24_sign: control_sum
    }
  end

  def control_sum
    @_control_sum ||= Przelewy24.sign("#{payment.session_id}|#{payment.order_id}|#{payment.amount}|#{payment.currency}|#{Przelewy24.crc_key}")
  end
end

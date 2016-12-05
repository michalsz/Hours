class Payment::Register < BusinessProcess::Base
  include Rails.application.routes.url_helpers

  needs :payment

  # TODO: Required if credit card payment
  # needs :name
  # needs :city
  # needs :zip
  # needs :address

  def call
    response = Przelewy24.send_request(:register, payment_params)

    if response.error == '0'
      if payment.update(token: response.token)
        payment
      end
    else
      fail(response.errorMessage)
    end
  end

  private

  def payment_params
    {
      p24_merchant_id: Przelewy24.merchant_id,
      p24_pos_id: Przelewy24.merchant_id,
      p24_session_id: payment.session_id,
      p24_amount: payment.amount,
      p24_currency: payment.currency,
      p24_description: payment.description,
      p24_email: payment.user.email,
      p24_country: payment.country,
      p24_url_return: payments_url(session_id: payment.session_id, host: 'http://misz.hours.dev'),
      p24_url_status: status_payments_url(host: 'http://misz.hours.dev'),
      p24_api_version: '3.2',
      p24_sign: control_sum
    }
  end

  def control_sum
    @_control_sum ||= Przelewy24.sign("#{payment.session_id}|#{Przelewy24.merchant_id}|#{payment.amount}|#{payment.currency}|#{Przelewy24.crc_key}")
  end
end

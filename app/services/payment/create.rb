class Payment::Create < BusinessProcess::Base
  needs :user
  needs :params

  def call
    if required_params_provided?
      perform = Payment::Register.call(payment: create_payment)
      perform.result if perform.success?
    else
      fail(:missing_params)
    end
  end

  private

  def create_payment
    @_payment ||= Payment.create({
      session_id: session_id,
      amount: params[:amount].to_i * 100,
      currency: 'PLN',
      user_id: user.try(:id),
      country: 'PL',
      description: description,
      status: :pending
    })
  end

  def session_id
    @_session_id ||= SecureRandom.hex(40)
  end

  def required_params_provided?
    %i(email amount).all? { |key| params[key].present? }
  end

  # TODO: I18n
  def description
    # TODO
    "Wpłata dla  - Dla trudly #{params[:for_trudly]}%"
  end

  # TODO: Params required for credit card payment processing
  def credit_card_params_provided?
    %i(name city zip address).all? { |key| params[key].present? }
  end
end

class Payment::Update < BusinessProcess::Base
  needs :payment
  needs :params

  def call
    if payment.update(parsed_params)
      Payment::Verify.call(payment: payment).result
    end
  end

  private

  def parsed_params
    {
      amount: params[:p24_amount],
      currency: params[:p24_currency],
      order_id: params[:p24_order_id],
      payment_method: params[:p24_method],
      payment_statement: params[:p24_statement],
      status: :awaiting_verification
    }
  end
end

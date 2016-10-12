class PaymentsController < ApplicationController
  def new
    @payment = Payment.new
  end

  def create
    payment = Payment::Create.call(params: payment_params, user: current_user).result

    if payment
      redirect_to Przelewy24.url_for(:redirect, token: payment.token)
    else
      redirect_to :back, alert: t('.failure')
    end
  end

  private

 def payment_params
   params.require(:payment).permit(:currency, :amount, :country, :email, :name, :city, :zip, :address, :for_trudly)
 end
end

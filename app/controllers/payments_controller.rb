require "subscription"

class PaymentsController < ApplicationController
  layout 'payments'

  before_action :select_amount, only: [:create]
  def new
    @payment = Payment.new
    @subscriptions = Subscription.subscriptions.map{ |s| s[:name]}
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

 def select_amount
   subscription = Subscription.subscriptions.select {|s| s[:name] == params['payment']['subscription']}
   params[:payment][:amount] = subscription[0][:price]
 end

 def payment_params
   params.require(:payment).permit(:user_id, :currency, :amount, :country,
                                   :email, :name, :city, :zip, :address,
                                   :subscription)
 end
end

class Payment < ActiveRecord::Base
  validates :user_id, presence: true

  belongs_to :user

  attr_accessor :subscription, :email

  enum status: { pending: 0, awaiting_verification: 1, success: 2, failure: 3, cancelled: 4 }
end

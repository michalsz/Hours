FactoryGirl.define do
  factory :payment do
    session_id { SecureRandom.hex(20) }
    amount 1
    user_id 1
    currency 'PLN'
    country 'PL'
    description { FFaker::Lorem.sentence }
    token "MyString"

    trait :pending do
      status :pending
    end

    trait :cancelled do
      status :cancelled
      token nil
    end

    trait :awaiting_verification do
      status :awaiting_verification
      order_id 1
    end

    trait :success do
      status :success
      order_id 1
      payment_method 1
      payment_statement "MyString"
    end

  end

  factory :user_payment, parent: :payment do
    user
  end
end

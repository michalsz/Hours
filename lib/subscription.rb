class Subscription
  def self.subscriptions
    [{ name: 'medium',
      price: 25,
      period: 'month'
    },
    { name: 'large',
      price: 75,
      period: 'month'
    }]
  end
end

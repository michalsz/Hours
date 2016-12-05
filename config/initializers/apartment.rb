Apartment.configure do |config|
  config.excluded_models = ["Account", "Payment"]
  config.tenant_names = -> { Account.pluck(:subdomain) }
end

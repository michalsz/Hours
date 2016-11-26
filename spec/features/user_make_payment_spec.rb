feature "User make payment" do
  let(:subdomain) { generate(:subdomain) }
  let(:owner) { build(:user) }

  before(:each) do
    create(:account_with_schema, subdomain: subdomain, owner: owner)
    sign_in_user(owner, subdomain: subdomain)
  end

  scenario "displays payment form" do
    user = create(:user)

    visit new_payment_url(subdomain: subdomain)

    expect(page).to have_content I18n.t('payments.purchase')
    # expect(page).to have_content user.email
    #
    # expect(page).to have_content owner.full_name
    # expect(page).to have_content owner.email
  end

  # context "when a new user is invited" do
  #   before do
  #     visit users_url(subdomain: subdomain)
  #
  #     fill_in "Email", with: "new.invitee@example.com"
  #     click_button "Invite User"
  #   end
  # end
end

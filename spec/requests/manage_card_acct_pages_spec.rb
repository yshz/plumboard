require 'spec_helper'

feature "CardAccounts" do
  subject { page }
  let(:user) { create(:contact_user) }
  let(:user2) { create(:contact_user) }
  let(:admin) { create(:admin) }
  let(:submit) { "Save" }

  before(:each) do
    create :category
    create :category, name: 'Electronics'
    init_setup admin
  end

  def set_token
    page.execute_script %Q{ $('#token').val("X98XX88X") }
  end

  describe "Create Card Account - Admin" do 
    before :each do
      visit new_card_account_path(adminFlg: true)
    end

    it 'shows content' do
      expect(page).to have_content 'Manage Accounts'
      expect(page).to have_selector('h2', text: 'Setup Your Card Account')
      expect(page).to have_content("Card Holder")
      expect(page).to have_content("Card #")
      expect(page).to have_button("Save")
    end

    it "creates an new account", js: true do
      @other = create :contact_user, last_name: 'Bling'
      fill_in "buyer_name", with: @other.name
      expect {
        load_credit_card "4242424242424242", "123", true, false; sleep 5
      }.to change(CardAccount, :count).by(1)
      expect(page).to have_content 'Manage Accounts'
      expect(page).to have_content '# Cards'
      expect(page).to have_content @other.name
    end
  end

  describe 'Show Card Accounts - Admin' do
    before do
      @account = user.card_accounts.create attributes_for :card_account, status: 'active'
      @account2 = user2.card_accounts.create attributes_for :card_account, card_no: '9999', status: 'active', token: 'xxx1234'
      sleep 5
      visit card_accounts_path(adminFlg: true)
    end
    it "shows accounts" do
      expect(page).to have_content 'Manage Accounts'
      expect(page).to have_content 'User'
      expect(page).to have_content 'Email'
      expect(page).to have_content '# Cards'
      expect(page).to have_content user.name
      expect(page).to have_content user2.name
    end

    context 'delete card', js: true do
      before do
        click_link 'Details'; sleep 2
        click_link 'Details'; sleep 2
      end

      it "removes an account" do
        expect(page).to have_link("Remove") #, href: card_account_path(@account)
        click_remove_ok
        expect(page).not_to have_link("#{@account.id}", href: card_account_path(@account)) 
        expect(page).to have_content 'Manage Accounts'
        expect(page).to have_content 'User'
        expect(page).to have_link 'Add Card'
        expect(page).not_to have_content user.name
        expect(page).to have_content user2.name
      end
    end
  end
end

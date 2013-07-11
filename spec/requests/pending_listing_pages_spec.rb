require 'spec_helper'

describe "PendingListings", :type => :feature do
  subject { page }
  let(:user) { FactoryGirl.create :admin, confirmed_at: Time.now }
  let(:listing) { FactoryGirl.create :temp_listing_with_transaction }

  before(:each) do
    login_as(user, :scope => :user, :run_callbacks => false)
    @user = user
  end

  describe "Review Pending Orders" do 
    before { visit pending_listing_path(listing) }

    it { should have_selector('title', text: 'Review Pending Order') }
    it { should have_content listing.title }
    it { should have_content "Posted By: #{listing.seller_name}" }
    it { should_not have_link 'Follow', href: '#' }
    it { should_not have_selector('#contact_content') }
    it { should_not have_selector('#comment_content') }
    it { should have_link 'Back', href: pending_listings_path }
    it { should have_link 'Deny', href: deny_pending_listing_path(listing) }
    it { should have_link 'Approve', href: approve_pending_listing_path(listing) }
    it { should have_content "ID: #{listing.pixi_id}" }
    it { should have_content "Posted: #{get_local_time(listing.start_date)}" }
    it { should have_content "Updated: #{get_local_time(listing.updated_at)}" }

    it "Returns to pending order list" do
      click_link 'Back'
      page.should have_content("Pending Orders")
    end

    it 'Approves an order' do
      expect {
        click_link 'Approve'; sleep 3
	}.to change(Listing, :count).by(1)

      page.should_not have_content listing.title 
      page.should have_content("Pending Orders")
    end

    it 'Denies an order' do
      expect {
        click_link 'Deny'; sleep 2
	}.to change(Listing, :count).by(0)

      page.should have_content("Pending Orders")
    end
  end

  describe "GET /pending_listings" do  
    let(:listings) { 30.times { FactoryGirl.create(:temp_listing_with_transaction, seller_id: @user.id) } }
    before :each do
      visit pending_listings_path 
    end

    it "should display listings" do 
      page.should have_content("Pending Orders")
    end

    it "paginate should list each listing" do
      @user.temp_listings.get_by_status('pending').paginate(page: 1).each do |listing|
        page.should have_selector('td', text: listing.title)
      end
    end
  end
end


require 'login_user_spec'

describe SearchesController do
  include LoginTestUser

  def mock_listing(stubs={})
    (@mock_listing ||= mock_model(TempListing, stubs).as_null_object).tap do |listing|
       listing.stub(stubs) unless stubs.empty?
    end
  end

  before(:each) do
    log_in_test_user
  end

  describe 'GET /index' do
    before :each do
      @listings = mock("listings")
      Listing.stub!(:search).and_return( @listings )
      controller.stub_chain(:query, :page).and_return(:success)
    end

    def do_get
      xhr :get, :index, search: 'test'
    end

    it "should load the requested listing" do
      Listing.stub(:search).with('test').and_return(@listings)
      do_get
    end

    it "should assign @listings" do
      listing = FactoryGirl.create(:listing)
      do_get
      assigns(:listings).should == @listings
    end
    
    it "searching for listings" do
      listing = FactoryGirl.create(:listing)
      ThinkingSphinx::Test.run do
        do_get
	assigns(:listings).should_not be_nil
      end
    end

    it "index action should render nothing" do
      do_get
      controller.stub!(:render)
    end
  end
end
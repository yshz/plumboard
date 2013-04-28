require 'login_user_spec'

describe TempListingsController do
  include LoginTestUser

  def mock_listing(stubs={})
    (@mock_listing ||= mock_model(TempListing, stubs).as_null_object).tap do |listing|
      listing.stub(stubs) unless stubs.empty?
    end
  end

  def mock_user(stubs={})
    (@mock_user ||= mock_model(User, stubs).as_null_object).tap do |user|
      user.stub(stubs) unless stubs.empty?
    end
  end

  before(:each) do
    log_in_test_user
    @listing = stub_model(TempListing, :id=>1, site_id: 1, seller_id: 1, pixi_id: '1', title: "Guitar for Sale", description: "Guitar for Sale")
  end

  describe 'GET show/:id' do
    before :each do
      @photo = stub_model(Picture)
      TempListing.stub!(:find_by_pixi_id).and_return( @listing )
      @listing.stub!(:pictures).and_return( @photo )
    end

    def do_get
      get :show, :id => '1'
    end

    it "should show the requested listing" do
      do_get
      response.should be_success
    end

    it "should load the requested listing" do
      TempListing.stub(:find_by_pixi_id).with('1').and_return(@listing)
      do_get
    end

    it "should assign @listing" do
      do_get
      assigns(:listing).should_not be_nil
    end

    it "should assign @photo" do
      do_get
      assigns(:listing).pictures.should_not be_nil
    end

    it "show action should render show template" do
      do_get
      response.should render_template(:show)
    end
  end

  describe "GET 'new'" do

    before :each do
      TempListing.stub!(:new).and_return( @listing )
      @picture = stub_model(Picture)
      @listing.stub_chain(:pictures, :build).and_return(@picture)
    end

    def do_get
      get :new
    end

    it "should assign @listing" do
      do_get
      assigns(:listing).should_not be_nil
    end

    it "should assign @picture" do
      do_get
      assigns(:listing).pictures.should_not be_nil
    end

    it "new action should render new template" do
      do_get
      response.should render_template(:new)
    end
  end

  describe "POST create" do
    
    context 'failure' do
      
      before :each do
        TempListing.stub!(:save).and_return(false)
      end

      def do_create
        post :create
      end

      it "should assign @listing" do
        do_create
        assigns(:listing).should_not be_nil 
      end

      it "should render the new template" do
        do_create
        response.should render_template(:new)
      end
    end

    context 'success' do

      before :each do
        TempListing.stub!(:save).and_return(true)
      end

      def do_create
        post :create, :temp_listing => { 'title'=>'test', 'description'=>'test' }
      end

      it "should load the requested listing" do
        TempListing.stub(:new).with({'title'=>'test', 'description'=>'test' }) { mock_listing(:save => true) }
        do_create
      end

      it "should assign @listing" do
        do_create
        assigns(:listing).should_not be_nil 
      end

      it "redirects to the created listing" do
        TempListing.stub(:new).with({'title'=>'test', 'description'=>'test' }) { mock_listing(:save => true) }
        do_create
        response.should be_redirect
      end

      it "should change listing count" do
        lambda do
          do_create
          should change(TempListing, :count).by(1)
        end
      end
    end
  end

  describe "GET 'edit/:id'" do

    before :each do
      TempListing.stub!(:find_by_pixi_id).and_return( @listing )
      @picture = stub_model(Picture)
      @listing.stub_chain(:pictures, :build).and_return(@picture)
    end

    def do_get
      get :edit, id: '1'
    end

    it "should load the requested listing" do
      TempListing.should_receive(:find_by_pixi_id).with('1').and_return(@listing)
      do_get
    end

    it "should assign @listing" do
      do_get
      assigns(:listing).should_not be_nil 
    end

    it "should load the requested listing" do
      do_get
      response.should be_success
    end
  end

  describe "PUT /:id" do
    before (:each) do
      TempListing.stub!(:find_by_pixi_id).and_return( @listing )
    end

    def do_update
      put :update, :id => "1", :temp_listing => {'title'=>'test', 'description' => 'test'}
    end

    context "with valid params" do
      before (:each) do
        @listing.stub(:update_attributes).and_return(true)
      end

      it "should load the requested listing" do
        TempListing.stub(:find_by_pixi_id) { @listing }
        do_update
      end

      it "should update the requested listing" do
        TempListing.stub(:find_by_pixi_id).with("1") { mock_listing }
	mock_listing.should_receive(:update_attributes).with({'title' => 'test', 'description' => 'test'})
        do_update
      end

      it "should assign @listing" do
        TempListing.stub(:find_by_pixi_id) { mock_listing(:update_attributes => true) }
        do_update
        assigns(:listing).should_not be_nil 
      end

      it "redirects to the updated listing" do
        do_update
        response.should redirect_to @listing
      end
    end

    context "with invalid params" do
    
      before (:each) do
        @listing.stub(:update_attributes).and_return(false)
      end

      it "should load the requested listing" do
        TempListing.stub(:find_by_pixi_id) { @listing }
        do_update
      end

      it "should assign @listing" do
        TempListing.stub(:find_by_pixi_id) { mock_listing(:update_attributes => false) }
        do_update
        assigns(:listing).should_not be_nil 
      end

      it "renders the edit form" do 
        TempListing.stub(:find_by_pixi_id) { mock_listing(:update_attributes => false) }
        do_update
	response.should render_template(:edit)
      end
    end
  end

  describe "DELETE 'destroy'" do

    before (:each) do
      TempListing.stub!(:find_by_pixi_id).and_return(@listing)
    end

    def do_delete
      delete :destroy, :id => "37"
    end

    context 'success' do

      it "should load the requested listing" do
        TempListing.stub(:find_by_pixi_id).with("37").and_return(@listing)
      end

      it "destroys the requested listing" do
        TempListing.stub(:find_by_pixi_id).with("37") { mock_listing }
        mock_listing.should_receive(:destroy)
        do_delete
      end

      it "redirects to the listings list" do
        TempListing.stub(:find_by_pixi_id) { mock_listing }
        do_delete
        response.should be_redirect
      end

      it "should decrement the TempListing count" do
        lambda do
          do_delete
          should change(TempListing, :count).by(-1)
        end
      end
    end
  end

  describe "PUT /resubmit/:id" do
    before (:each) do
      TempListing.stub!(:find_by_pixi_id).and_return( @listing )
    end

    def do_resubmit
      put :resubmit, :id => "1"
    end

    context "success" do
      before :each do
        @listing.stub!(:resubmit_order).and_return(true)
      end

      it "should load the requested listing" do
        TempListing.stub(:find_by_pixi_id) { @listing }
        do_resubmit
      end

      it "should update the requested listing" do
        TempListing.stub(:find_by_pixi_id).with("1") { mock_listing }
	mock_listing.should_receive(:resubmit_order).and_return(:success)
        do_resubmit
      end

      it "should assign @listing" do
        TempListing.stub(:find_by_pixi_id) { mock_listing(:resubmit_order => true) }
        do_resubmit
        assigns(:listing).should_not be_nil 
      end

      it "redirects the page" do
        do_resubmit
	response.should be_redirect
      end
    end

    context 'failure' do
      before :each do
        @listing.stub!(:resubmit_order).and_return(false) 
      end

      it "should assign listing" do
        do_resubmit
        assigns(:listing).should_not be_nil 
      end

      it "should render show template" do
        do_resubmit
        response.should render_template(:show)
      end
    end
  end

end
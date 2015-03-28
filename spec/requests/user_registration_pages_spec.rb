require 'spec_helper'

feature "UserRegistrations" do
  subject { page }

  describe 'allows a user to register' do
    let(:submit) { "Register" } 

    def user_info
      fill_in "user_first_name", with: 'New'
      fill_in "user_last_name", with: 'User'
    end

    def user_birth_date
      select('Jan', :from => "user_birth_date_2i")
      select('10', :from => 'user_birth_date_3i')
      select('1983', :from => 'user_birth_date_1i')
    end

    def user_pwd
      fill_in 'user_password', :with => 'userpassword'
      # fill_in "user_password_confirmation", with: 'userpassword'
    end

    describe "with invalid information" do
      before :each do  
        create_user_types
        visit new_user_registration_path 
      end

      it 'shows content' do
        page.should have_content 'Already have an account?'
        page.should have_link 'Sign In', href: new_user_session_path
        page.should have_link "Pixiboard's Terms of Service", href: terms_path
        page.should have_link 'Privacy Policy', href: privacy_path
      end

      it "should not create a empty user" do
        expect{ 
          fill_in "user_first_name", with: ''
	  click_button submit 
	}.not_to change(User, :count)
        page.should have_content "Create Your Account"
      end

      it "should not create a incomplete user" do
        expect{ 
		user_info
		click_button submit 
	}.not_to change(User, :count)
        page.should have_content "Create Your Account"
      end

      it "should not create user w/o email" do
        expect{ 
		user_info
		user_birth_date
		select('Male', :from => 'user_gender')
		click_button submit 
	}.not_to change(User, :count)
        page.should have_content "Create Your Account"
      end

      it "should not create user w/o gender" do
        expect{ 
		user_info
		user_birth_date
        	fill_in 'user_email', :with => 'newuser@example.com'
		user_pwd
      		add_data_w_photo
		click_button submit 
	}.not_to change(User, :count)
        page.should have_content "Create Your Account"
      end

      it "should not create user w/o birthdate" do
        expect{ 
		user_info
		select('Male', :from => 'user_gender')
        	fill_in 'user_email', :with => 'newuser@example.com'
		user_pwd
      		add_data_w_photo
		click_button submit 
	}.not_to change(User, :count)
        page.should have_content "Create Your Account"
      end

      it "should not create user w/o zip" do
        expect{ 
		user_info
		user_birth_date
		select('Male', :from => 'user_gender')
        	fill_in 'user_email', :with => 'newuser@example.com'
		user_pwd
      		add_data_w_photo
		click_button submit 
	}.not_to change(User, :count)
        page.should have_content "Create Your Account"
      end

      it "should not create user w/o valid zip" do
        expect{ 
		user_info
		user_birth_date
		select('Male', :from => 'user_gender')
        	fill_in 'user_email', :with => 'newuser@example.com'
		user_pwd
                fill_in 'home_zip', :with => '99999'
      		add_data_w_photo
		click_button submit 
	}.not_to change(User, :count)
        page.should have_content "Create Your Account"
      end

      it "should not create user w/o password" do
        expect{ 
		user_info
		user_birth_date
		select('Male', :from => 'user_gender')
        	fill_in 'user_email', :with => 'newuser@example.com'
        	fill_in "user_password_confirmation", with: 'userpassword'
      		add_data_w_photo
		click_button submit 
	}.not_to change(User, :count)
        page.should have_content "Create Your Account"
      end

      it "should not create user w/o password confirmation" do
        expect{ 
		user_info
		user_birth_date
		select('Male', :from => 'user_gender')
        	fill_in 'user_email', :with => 'newuser@example.com'
        	fill_in "user_password", with: 'userpassword'
      		add_data_w_photo
		click_button submit 
	}.not_to change(User, :count)
        page.should have_content "Create Your Account"
      end

      it "should not create a user with no photo" do
        expect{ 
      		user_data
		click_button submit 
	}.not_to change(User, :count)
        page.should have_content "Create Your Account"
      end

      it "should not create a business user with name" do
        expect{ 
      		user_data false
      		add_data_w_photo
        	fill_in "user_business_name", with: ''
		click_button submit 
	}.not_to change(User, :count)
        page.should have_content "Create Your Account"
      end
    end

    def user_data flg=true
      user_info
      fill_in 'user_email', :with => 'newuser@example.com'
      if flg
        select('Male', :from => 'user_gender')
        user_birth_date
      else
        select('Business', :from => 'ucode')
        fill_in 'user_business_name', :with => 'Company A'
      end
      fill_in 'home_zip', :with => '90201'
      user_pwd
    end

    def add_data_w_photo
      attach_file('user_pic', Rails.root.join("spec", "fixtures", "photo.jpg"))
    end

    def user_with_photo flg=true
      user_data flg
      add_data_w_photo
    end

    def register val="YES", cnt=1
      expect { 
	stub_const("USE_LOCAL_PIX", val)
	user_with_photo
	click_button submit; sleep 2 
        page.should have_content 'A message with a confirmation link has been sent to your email address' if cnt > 0
      }.to change(User, :count).by(cnt)
    end
    
    describe 'create user from registration page', process: true do
      before { visit new_user_registration_path }
      it "should create a user - local pix" do
        register
      end	

      it "should create a user" do
        register "NO"
      end	
    end

    describe "create user from modal", process: true do
      before(:each) do
        create_user_types
        visit root_path
        click_link 'Signup'; sleep 2
      end

      it "should create a user - local pix" do
        check_page_selectors ['#pwd, #register-btn'], true, false
        register 'YES', 0
      end	

      it "should create a user" do
        check_page_selectors ['#pwd, #register-btn'], true, false
        register "NO", 0
      end

      def create_user val='NO', flg=true
        expect { 
	  stub_const("USE_LOCAL_PIX", val)
	  user_with_photo flg
	  click_button submit; sleep 2 
	 }.to change(User, :count).by(1)
      end

      it "should create a user - local pix" do
        create_user 'YES'
        page.should have_link 'How It Works', href: howitworks_path 
        page.should have_content 'A message with a confirmation link has been sent to your email address' 
      end	

      it "should create a user" do
        create_user
      end	

      it "should create a business user" do
        create_user 'NO', false
	expect(User.first.url).not_to be_nil
      end	
    end
  end  
end

require 'spec_helper'

describe TransactionObserver do
  let(:user) { FactoryGirl.create(:pixi_user) }

  def process_post
    @post = mock(Post)
    @observer = TransactionObserver.instance
    @observer.stub(:send_post).with(@model).and_return(@post)
  end

  def update_addr
    @user = mock(User)
    @observer = TransactionObserver.instance
    @observer.stub(:update_contact_info).with(@model).and_return(@user)
  end

  describe 'after_update' do
    let(:transaction) { FactoryGirl.create :transaction }
    before(:each) do
      transaction.status = 'approved'
    end

    it 'should deliver the receipt' do
      @user_mailer = mock(UserMailer)
      UserMailer.stub(:delay).and_return(UserMailer)
      UserMailer.should_receive(:send_transaction_receipt).with(transaction)
      transaction.save!
    end
  end

  describe 'after_create' do
    before do
      @model = user.transactions.build FactoryGirl.attributes_for(:transaction, transaction_type: 'invoice')
    end

    it 'sends a post' do
      process_post
    end

    it 'updates contact info' do
      update_addr
    end

    it 'should add inv pixi points' do
      @model.save!
      user.user_pixi_points.find_by_code('inv').code.should == 'inv'
    end

    it 'should deliver the receipt' do
      @model.status = 'approved'
      @user_mailer = mock(UserMailer)
      UserMailer.stub(:delay).and_return(UserMailer)
      UserMailer.should_receive(:send_transaction_receipt).with(@model)
      @model.save!
    end
  end
end

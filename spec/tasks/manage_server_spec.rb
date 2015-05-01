require 'spec_helper'
require 'rake'

describe 'manage_server' do
  before :all do
    load File.expand_path("../../../lib/tasks/manage_server.rake", __FILE__)
    Rake::Task.define_task(:environment)
  end

  describe 'close_expired_pixis' do
    it_behaves_like("manage_server", "manage_server:close_expired_pixis", nil, Listing, :close_pixis)
  end

  describe "load_news_feeds" do
    it_behaves_like("manage_server", "manage_server:load_news_feeds", nil, LoadNewsFeed, :read_feeds)
  end

  describe 'send_expiring_draft_pixi_notices' do
    it_behaves_like("manage_server", "manage_server:send_expiring_draft_pixi_notices", {arg1: 7}, TempListing, :soon_expiring_pixis)
  end

  describe 'send_expiring_pixi_notices' do
    it_behaves_like("manage_server", "manage_server:send_expiring_pixi_notices", {arg1: 7}, Listing, :soon_expiring_pixis)
  end

  describe 'send_invoiceless_pixi_notices' do
    it_behaves_like("manage_server", "manage_server:send_invoiceless_pixi_notices", nil, Listing, :invoiceless_pixis)
  end

  describe 'send_unpaid_old_invoice_notices' do
    it_behaves_like("manage_server", "manage_server:send_unpaid_old_invoice_notices", nil, Invoice, :unpaid_old_invoices)
  end
end
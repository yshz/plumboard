class ListingParent < ActiveRecord::Base
  self.abstract_class = true

  before_update :must_have_pictures

  # load pixi config keys
  ALIAS_LENGTH = PIXI_KEYS['pixi']['alias_length']
  KEY_LENGTH = PIXI_KEYS['pixi']['key_length']
  SITE_FREE_AMT = PIXI_KEYS['pixi']['site_init_free']
  MAX_PIXI_AMT = PIXI_KEYS['pixi']['max_pixi_amt']

  attr_accessible :buyer_id, :category_id, :description, :title, :seller_id, :status, :price, :show_alias_flg, :show_phone_flg, :alias_name,
  	:site_id, :start_date, :end_date, :transaction_id, :pictures_attributes, :pixi_id, :parent_pixi_id, :id, :created_at, :updated_at,
	:edited_by, :edited_dt

  belongs_to :user, :foreign_key => :seller_id
  belongs_to :site
  belongs_to :category
  belongs_to :transaction

  validates :title, :presence => true, :length => { :maximum => 80 }
  validates :description, :presence => true
  validates :seller_id, :presence => true
  validates :site_id, :presence => true
  validates :start_date, :presence => true
  validates :category_id, :presence => true
  validates :price, :allow_blank => true, :numericality => { greater_than_or_equal_to: 0, less_than_or_equal_to: MAX_PIXI_AMT.to_f }
  validate :must_have_pictures

  # reset default controller id parameter to pixi_id
  def to_param
    pixi_id
  end

  # validate existance of at least one picture
  def must_have_pictures
    if !any_pix? || pictures.all? {|pic| pic.marked_for_destruction? }
      errors.add(:base, 'Must have at least one picture')
    end
  end

  # check if pictures already exists
  def any_pix?
    pictures.detect { |x| x && !x.photo_file_name.nil? }
  end

  # select active listings
  def self.active
    where(:status=>'active').order('updated_at DESC')
  #  where("status = 'active' AND end_date => curdate()")
  end

  # find listings by status
  def self.get_by_status val
    where(:status => val).order('updated_at ASC')
  end

  # find listings by site id
  def self.get_by_site val
    where(:site_id => val)
  end

  # find listings by seller user id
  def self.get_by_seller val
    where(:seller_id => val)
  end

  # verify if listing has been paid for
  def has_transaction?
    !transaction_id.blank?
  end

  # verify if listing is active
  def active?
    status == 'active'
  end

  # verify if alias is used
  def alias?
    show_alias_flg == 'yes'
  end

  # verify if current user is listing seller
  def seller? uid
    seller_id == uid
  end

  # get category name for a listing
  def category_name
    category.name.titleize rescue nil
  end

  # get site name for a listing
  def site_name
    site.name rescue nil
  end

  # get seller name for a listing
  def seller_name
    alias? ? alias_name : user.name rescue nil
  end

  # short description
  def brief_descr
    description[0..26] + '...' rescue nil
  end

  # titleize title
  def nice_title
    title.titleize rescue nil
  end

  # set end date to x days after start to denote when listing is no longer displayed on network
  def set_end_date
    self.end_date = self.start_date + PIXI_DAYS.days
  end

  # get number of sites where pixi is posted
  def get_site_count
    site_name ? 1 : site_listings.size
  end

  # set nice time
  def get_local_time(tm)
    tm.utc.getlocal.strftime('%m/%d/%Y %I:%M%p') rescue nil
  end
end

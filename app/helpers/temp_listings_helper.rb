module TempListingsHelper

  # set promo code for free order if appropriate
  def set_promo_code site
    PIXI_KEYS['pixi']['launch_promo_cd'] if Listing.free_order?(site)
  end

  # set delete messsage for pixi
  def msg
    'Are you sure? All your changes will be lost.'
  end

  # set delete messsage for photo
  def photo_msg
    'Image will be removed. Are you sure?'
  end

  # return # of steps to submit new pixi
  def step_count listing
    listing.free? ? 2 : !listing.new_status? ? 2 : 3 rescue 2
  end
  
  # build array for year selection dropdown
  def get_year_ary
    (Date.today.year-99..Date.today.year).inject([]){|x,y| x << y}.reverse
  end

  # check controller name
  def pending_listings?
    controller_name == 'pending_listings'
  end

  # check if pending listing
  def check_pending_pixi listing
    path = (mobile_device? ? 'mobile' : 'shared') + '/pending_listing' 
    render partial: path, locals: {listing: listing} if pending_listings?
  end

  # set different url if pixi is pending
  def set_pixi_path listing
    listing.pending? && controller_name == 'pending_listings' ? pending_listing_url(listing) : listing
  end

  # check if post is by seller 
  def seller_post? listing
    !@user.is_support? && @ptype.blank? && listing.new_record?
  end

  # check if new pixi post
  def new_pixi_post? listing
    listing.pixi_post? && !listing.edit?
  end

  # check if in edit mode
  def edit_mode? listing
    !listing.pixi_post? || listing.edit?
  end

  # check if pixi is an item
  def is_item? listing, flg=true
    val = %w(employment service item housing)
    flg ? !(listing.is_category_type? val) : (listing.is_category_type? val)
  end

  # check if pixi has quantity
  def has_qty? listing
    !listing.is_category_type? %w(employment service vehicle)
  end

  # check if pixi has condition
  def has_condition? listing
    !listing.is_category_type? %w(employment service event housing item)
  end

  def has_event_type? listing
    listing.is_category_type? %w(event)
  end

  # set large size if condition is not visible
  def set_category_size listing
    has_condition?(listing) || has_event_type?(listing) ? 'span2' : 'span4'
  end

  # check if pixi is chargeable
  def chargeable? listing
    listing.seller?(@user) && listing.new_status? 
  end

  # toggle element on image slider
  def set_element pic
    controller_name == 'temp_listings' ? get_pixi_image(pic) : get_pixi_image(pic, 'large')
  end

  # toggle image slider title
  def set_image_title
    controller_name == 'temp_listings' ? '' : 'Pin it @ Pinterest'
  end

  # check for admin editor
  def check_edit_status listing
    listing.seller_id != @user.id ? can?(:manage_pixi_posts, @user) && listing.user.is_business? ? 'bus' : 'mbr' : ''
  end

  # show edit button
  def render_edit_button listing
    unless expired_or_sold?(listing)
      link_to 'Edit', edit_temp_listing_path(listing, ptype: check_edit_status(listing)), id: 'pixi-edit-btn', class: 'btn btn-large' 
    end
  end

  # toggle display buttons
  def toggle_buttons listing
    if listing.edit?
      render partial: 'shared/return_buttons', locals: {listing: listing}
    elsif listing.active? && controller_name == 'listings'
      render partial: 'shared/button_menu', locals: {model: listing, atype: 'Remove'}
    else
      link_to 'Remove', listing, method: :delete, confirm: msg, class: 'btn btn-large', title: 'Remove Pixi' unless expired_or_sold?(listing)
    end
  end

  # check for pixi post
  def show_seller_fields f, listing
    render partial: 'shared/listing_seller_fields', locals: { f: f, listing: listing } if new_pixi_post?(listing)
  end

  # set autocomplete path based on user type
  def autocomplete_path ptype
    ptype && ptype.upcase == 'BUS' ? autocomplete_user_business_name_temp_listings_path : autocomplete_user_first_name_temp_listings_path
  end

  def show_temp_listing listing
    if listing.free?
      link_to "Done!", submit_temp_listing_path(listing), method: :put, class: "btn btn-large btn-primary submit-btn", id: 'px-done-btn'
    else
      render partial: 'shared/item_purchase', locals: {listing: listing} if chargeable? listing 
    end
  end

  def set_draft_partial aFlg
    aFlg ? 'shared/manage_pixis' : 'shared/mypixis_list'
  end
end

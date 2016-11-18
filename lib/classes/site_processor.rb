class SiteProcessor
  include ProcessMethod

  def initialize site
    @site = site
  end

  def get_site_type
    case @site.site_type_code
      when 'pub' then 'pub'
      when 'school' then 'edu'
      else 'loc'
    end
  end

  # initialize data
  def set_flds
    @site.site_url = @site.name 
  end

  # create unique url for user
  def generate_url value, cnt=0
    ProcessMethod::generate_url 'Site', value, cnt
  end

  def url_str
    [ProcessMethod::get_host, '/', get_site_type, '/'].join('')
  end

  # getter for url
  def site_url 
    [url_str, @site.url].join('') rescue nil
  end

  def local_site_path
    ['/', get_site_type, '/', @site.url].join('') rescue nil
  end

  # get nearest region
  def get_nearest_region loc, val='region'
    regions, nearest, nearest_distance = Site.inc_list.get_by_type(val), nil, Float::INFINITY
    regions.each do |region|
      distance = region.contacts.first.distance_to(loc)
      nearest, nearest_distance = region, distance if distance && distance < nearest_distance
    end
    nearest ||= Site.inc_list.find_by_name(PIXI_LOCALE)
  end

  # get nearest area by zip
  def get_nearest_area zip, stype='area', miles=1, ctype='Site'
    Site.where(site_type_code: stype, name: Contact.near(zip, miles).where(contactable_type: ctype).map(&:city).uniq)
  end

  # select active sites w/ pixis
  def active_with_pixis
    Site.where(id: Listing.active.pluck(:site_id).uniq)
  end

  # assign lat and lng, then save
  def save_site params
    if !params[:user].blank?
      params[:user][:pictures_attributes].each do |_, v|
        @site.pictures.build(v)
      end
    end
    c = @site.contacts.first
    loc = [c.address, c.city, c.state].join(', ') << ' ' << c.zip
    c.lat, c.lng = LocationManager.get_lat_lng_by_loc(loc)
    @site.save
  end

  def with_picture
    @site.pictures.build if @site.pictures.blank? || @site.pictures.size < 2
    @site.contacts.build if @site.contacts.blank?
    @site
  end
end

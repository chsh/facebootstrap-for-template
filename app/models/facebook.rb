class Facebook
  class Config
    def self.app_id
      @@app_id ||= ConfigOrEnv['facebook.app_id']
    end
    def self.app_secret
      @@app_secret ||= ConfigOrEnv['facebook.app_secret']
    end
    def self.app_scope
      @@app_scope ||= ConfigOrEnv['facebook.app_scope']
    end
    def self.app_namespace
      @@app_namespace ||= ConfigOrEnv['facebook.app_namespace']
    end
    def self.publish_timeline?
      ConfigOrEnv['facebook.publish_timeline']
    end
  end
  class Profile
    class Hash < HashWithMethod
    end
  end
  class SignedRequest < HashWithMethod
  end

  class OGP
    attr_accessor :title, :type, :image, :description
    def initialize(attrs = {}, extra_attrs = {})
      attrs.each do |attr, value|
        setter = "#{attr}="
        if self.respond_to? setter
          self.send(setter, value)
        end
      end
      @extra_attrs = extra_attrs
    end
    def title
      @title ||= I18n.t(:service_name)
    end
    def description
      @description ||= I18n.t(:service_description)
    end
    def type
      @type ||= "website"
    end
    def image
      @image ||= "logo.jpg"
    end
    def site_name
      @@site_name ||= I18n.t(:site_name)
    end
    def extra_attrs
      @extra_attrs
    end
  end

  def initialize(profile_hash)
    @profile = Profile::Hash.from(profile_hash[:profile])
  end
  def profile; @profile end

  def public_graph
    @public_graph ||= Koala::Facebook::API.new
  end
  def private_graph()
    @private_graph ||= Koala::Facebook::API.new self.profile.credentials.token
  end

  def publish_action(action, params)
    if Config.publish_timeline?
      text = "publish_action:#{Config.app_namespace}:#{action},#{params.inspect}"
      begin
        private_graph.put_connections('me',
                                      "#{Config.app_namespace}:#{action}",
                                      params)
        Rails.logger.info(text + ":SUCCESS")
      rescue Koala::Facebook::APIError
        Rails.logger.info(text + ":FAILED")
      end
    else
      {}
    end
  end

  def friends
    qc = FacebookApi::QueryCache.query(self.profile.uid, [:get_connections, 'me', 'friends'])
    qc.recent_response(private_graph)
  end
  def friend_by_name(name)
    friends.each do |friend|
      return friend if friend['name'] == name
    end
    nil
  end

  def self.public_graph
    @@public_graph ||= Koala::Facebook::API.new
  end

  def self.parse_signed_request(signed_request)
    oauth = Koala::Facebook::OAuth.new(Config.app_id, Config.app_secret)
    SignedRequest.from oauth.parse_signed_request(signed_request)
  end
end

class OmniAuthTokenRefreshWorker
  include Sidekiq::Worker

  def perform(provider_id)
    @provider = OmniAuthProvider.find_by_id(provider_id)
    return unless @provider

    refresh_token
  end

private

  def refresh_token
    # Only refresh tokens that expire
    return unless @provider.auth_data["credentials"]["expires"]

    # Only refresh tokens that expire in the next 30 minutes
    expires_at = Time.at(@provider.auth_data["credentials"]["expires_at"])
    return if expires_at > Time.now + 30.minutes

    # Refresh the token
    response = RestClient.post(token_url,
      grant_type:    "refresh_token",
      refresh_token: @provider.auth_data["credentials"]["refresh_token"],
      client_id:     ENV["#{@provider.name.upcase}_CLIENT_ID"],
      client_secret: ENV["#{@provider.name.upcase}_CLIENT_SECRET"]
    )
    refresh_data = JSON.parse(response.body)
    save_auth_data(refresh_data)
  end

  def save_auth_data(refresh_data)
    @provider.auth_data["credentials"]["token"] = refresh_data["access_token"]
    @provider.auth_data["credentials"]["expires_at"] = Time.now.to_i + refresh_data["expires_in"].to_i
    @provider.auth_data["credentials"]["refresh_token"] = refresh_data["refresh_token"]
    @provider.save
  end

  def token_url
    config = Devise::OmniAuth::Config.new(@provider.name, [{}])
    client_options = config.strategy_class.default_options["client_options"]
    token_url = client_options["token_url"]

    unless token_url.starts_with?("http")
      token_url = "#{client_options['site']}#{client_options['token_url']}"
    end

    token_url
  end

end

module OmniAuthProviderClients
  extend ActiveSupport::Concern

  included do
    has_many :omni_auth_providers, as: :subscriber, dependent: :destroy
  end

  # DigitalOcean client instance with subscriber's access token.
  # Example Usage: user.digitalocean_client.droplet.all
  # @return [Barge::Client]
  def digitalocean_client
    @digitalocean_client ||= begin
      if provider = self.omni_auth_providers.where(name: "digitalocean").first
        Barge::Client.new(access_token: provider.access_token)
      end
    end
  end

  # DNSimple client instance with subscriber's access token.
  # Example Usage: user.dnsimple_client.list_domains
  # @return [Fog::DNS]
  def dnsimple_client
    @dnsimple_client ||= begin
      if provider = self.omni_auth_providers.where(name: "dnsimple").first
        Fog::DNS.new(
          provider:       "DNSimple",
          dnsimple_email: provider.email,
          dnsimple_token: provider.access_token
        )
      end
    end
  end

  # Facebook client instance with subscriber's access token.
  # Example Usage: user.facebook_client.get_object("me")
  # @return [Koala::Facebook::API]
  def facebook_client
    @facebook_client ||= begin
      if provider = self.omni_auth_providers.where(name: "facebook").first
        Koala::Facebook::API.new(provider.access_token)
      end
    end
  end

  # GitHub client instance with subscriber's access token.
  # Example Usage: user.github_client.repos
  # @return [Octokit::Client]
  def github_client
    @github_client ||= begin
      if provider = self.omni_auth_providers.where(name: "github").first
        Octokit::Client.new(access_token: provider.access_token)
      end
    end
  end

  # Heroku client instance with subscriber's access token.
  # Example Usage: user.heroku_client.app.list
  # @return [PlatformAPI::Client]
  def heroku_client
    @heroku_client ||= begin
      if provider = self.omni_auth_providers.where(name: "heroku").first
        PlatformAPI.connect_oauth(provider.access_token)
      end
    end
  end

  # Twitter client instance with subscriber's access token.
  # @return [Twitter::REST::Client]
  def twitter_client
    @twitter_client ||= begin
      if provider = self.omni_auth_providers.where(name: "twitter").first
        Twitter::REST::Client.new do |config|
          config.consumer_key        = ENV["TWITTER_CLIENT_ID"]
          config.consumer_secret     = ENV["TWITTER_CLIENT_SECRET"]
          config.access_token        = provider.auth_data["credentials"]["token"]
          config.access_token_secret = provider.auth_data["credentials"]["secret"]
        end
      end
    end
  end
end

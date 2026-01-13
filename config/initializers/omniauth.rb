require "set"

OmniAuth.config.allowed_request_methods = %i[get post]
OmniAuth.config.logger = Rails.logger

def cred_or_env(cred_path, env_key)
  creds = Rails.application.credentials.dig(*Array(cred_path))
  return creds if creds.present?
  ENV[env_key]
end

provider_configs = [
  {
    name: :google_oauth2,
    id_key: [ :oauth, :google, :client_id ],
    secret_key: [ :oauth, :google, :client_secret ],
    env_id: "GOOGLE_CLIENT_ID",
    env_secret: "GOOGLE_CLIENT_SECRET",
    options: {
      scope: "userinfo.email,userinfo.profile",
      prompt: "select_account",
      access_type: "online"
    }
  }
]

Rails.application.config.x.oauth_providers = Set.new

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer unless Rails.env.production?

  provider_configs.each do |config|
    client_id = cred_or_env(config[:id_key], config[:env_id])
    client_secret = cred_or_env(config[:secret_key], config[:env_secret])
    next if client_id.blank? || client_secret.blank?

    Rails.application.config.x.oauth_providers << config[:name].to_sym
    provider config[:name], client_id, client_secret, **config[:options]
  end

  # Apple OAuth removed by request; keep only providers with configured credentials.
end

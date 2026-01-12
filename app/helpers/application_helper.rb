module ApplicationHelper
  def oauth_provider_enabled?(name)
    providers = Rails.application.config.x.oauth_providers
    return providers.include?(name.to_sym) if providers.present?

    provider_credentials_present?(name)
  end

  private

  def provider_credentials_present?(name)
    case name.to_sym
    when :google_oauth2
      google_client_id.present? && google_client_secret.present?
    else
      false
    end
  end

  def google_client_id
    Rails.application.credentials.dig(:oauth, :google, :client_id) || ENV["GOOGLE_CLIENT_ID"]
  end

  def google_client_secret
    Rails.application.credentials.dig(:oauth, :google, :client_secret) || ENV["GOOGLE_CLIENT_SECRET"]
  end
end

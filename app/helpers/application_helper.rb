module ApplicationHelper
  def oauth_provider_enabled?(name)
    providers = Rails.application.config.x.oauth_providers
    return providers.include?(name.to_sym) if providers.present?

    provider_credentials_present?(name)
  end

  def rating_stars(rating, size: :sm, show_label: false)
    return content_tag(:span, "No rating", class: "text-xs text-slate-500") if rating.blank?

    value = rating.to_f.clamp(0.0, 5.0)
    size_class = size == :sm ? "h-4 w-4" : "h-6 w-6"
    gap_class = size == :sm ? "gap-0.5" : "gap-1"

    stars = content_tag(:div, class: "flex #{gap_class}", aria: { hidden: true }) do
      safe_join(Array.new(5) do |index|
        fill_percent = [[value - index, 0].max, 1].min * 100

        content_tag(:div, class: "relative text-white/30") do
          safe_join([
            star_outline_svg(size_class),
            content_tag(:div, class: "absolute inset-0 overflow-hidden text-amber-300", style: "width: #{fill_percent}%;") do
              star_solid_svg(size_class)
            end
          ])
        end
      end)
    end

    label_class = show_label ? "text-xs font-medium text-slate-500" : "sr-only"
    label = content_tag(:span, format("%.1f / 5", value), class: label_class)

    safe_join([ stars, label ], " ")
  end

  def star_outline_svg(size_class = "h-5 w-5")
    tag.svg(viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", stroke_width: "1.6", stroke_linecap: "round", stroke_linejoin: "round", class: size_class) do
      tag.path(d: "M12 17.27 18.18 21l-1.64-7.03L22 9.24l-7.19-.62L12 2 9.19 8.62 2 9.24l5.46 4.73L5.82 21z")
    end
  end

  def star_solid_svg(size_class = "h-5 w-5")
    tag.svg(viewBox: "0 0 24 24", fill: "currentColor", class: size_class) do
      tag.path(d: "M12 17.27 18.18 21l-1.64-7.03L22 9.24l-7.19-.62L12 2 9.19 8.62 2 9.24l5.46 4.73L5.82 21z")
    end
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

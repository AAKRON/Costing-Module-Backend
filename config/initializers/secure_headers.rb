# frozen_string_literal: true

SecureHeaders::Configuration.default do |config|
  config.cookies = {
    secure: Rails.env.production?, # mark cookies as "Secure" in production
    httponly: true, # mark cookies as "HttpOnly"
    samesite: {
      strict: true # mark cookies as SameSite=strict
    }
  }

  config.hsts = "max-age=31536000; includeSubdomains"
  config.x_frame_options = "DENY"
  config.x_content_type_options = "nosniff"
  config.x_xss_protection = "1; mode=block"
  config.x_download_options = "noopen"
  config.x_permitted_cross_domain_policies = "none"
  config.referrer_policy = %w[origin-when-cross-origin strict-origin-when-cross-origin]

  # Content Security Policy
  config.csp = {
    # Fallback directive
    default_src: %w['self'],
    
    # Allow scripts from self
    script_src: %w['self'],
    
    # Allow stylesheets from self
    style_src: %w['self' 'unsafe-inline'],
    
    # Allow images from self and data URIs
    img_src: %w['self' data:],
    
    # Allow fonts from self
    font_src: %w['self'],
    
    # Restrict object/embed
    object_src: %w['none'],
    
    # Only allow form submissions to self
    form_action: %w['self'],
    
    # Control where the page can be embedded
    frame_ancestors: %w['none'],
    
    # Require HTTPS for all connections
    upgrade_insecure_requests: Rails.env.production?,
    
    # block_all_mixed_content deprecated in secure_headers 7.x
    # Mixed content is handled by upgrade_insecure_requests instead
  }

  # Disable CSP in development for easier debugging
  config.csp_report_only = Rails.env.development?
end
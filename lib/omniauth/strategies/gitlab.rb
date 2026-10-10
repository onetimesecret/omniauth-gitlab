
require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class GitLab < OmniAuth::Strategies::OAuth2
      # Enough to read the signed-in user's profile. Without an explicit scope
      # GitLab falls back to its own default, `api`, which grants full
      # read/write access to the API.
      DEFAULT_SCOPE = 'read_user'.freeze

      option :client_options, site: 'https://gitlab.com'

      option :redirect_url

      uid { raw_info['id'].to_s }

      info do
        {
          name: raw_info['name'],
          username: raw_info['username'],
          email: raw_info['email'],
          image: raw_info['avatar_url']
        }
      end

      extra do
        { raw_info: raw_info }
      end

      # Applied here rather than as `option :scope` so that a scope passed in
      # `authorize_params` is not overridden by the default.
      def authorize_params
        super.tap do |params|
          params[:scope] ||= DEFAULT_SCOPE
        end
      end

      def raw_info
        @raw_info ||= access_token.get('api/v4/user').parsed
      end

      def callback_url
        options.redirect_url || (full_host + callback_path)
      end
    end
  end
end

OmniAuth.config.add_camelization 'gitlab', 'GitLab'

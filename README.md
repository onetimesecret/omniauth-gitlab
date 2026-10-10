# Omniauth::Gitlab

[![Join the chat at https://gitter.im/linchus/omniauth-gitlab](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/linchus/omniauth-gitlab?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

This is the OAuth2 strategy for authenticating to your GitLab service.

## Requirements

GitLab 9.0+ (API v4)

## Installation

Add this line to your application's Gemfile:

    gem 'omniauth-gitlab'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install omniauth-gitlab

## Basic Usage

    use OmniAuth::Builder do
      provider :gitlab, ENV['GITLAB_KEY'], ENV['GITLAB_SECRET']
    end

## Self-managed GitLab

    use OmniAuth::Builder do
      provider :gitlab, ENV['GITLAB_KEY'], ENV['GITLAB_SECRET'],
        {
           client_options: {
             site: 'https://gitlab.YOURDOMAIN.com'
           }
        }
    end

An instance served under a relative URL root also works, e.g. `site: 'https://example.com/gitlab'`.

## Custom scopes

By default, the `read_user` scope is requested. It is enough to read the signed in user's profile, and the GitLab application must allow it. To use different scopes:

    use OmniAuth::Builder do
      provider :gitlab, ENV['GITLAB_KEY'], ENV['GITLAB_SECRET'], scope: 'read_user openid'
    end

If your app uses the access token for further API calls, request what it needs, for example `scope: 'api'` or `scope: 'read_api'`.

Requesting a scope that is not configured will result the error "The requested scope is invalid, unknown, or malformed.".

### Upgrading from 4.1.0 and earlier

Earlier versions sent no scope, so GitLab granted its default, `api`, which is full read/write access to the API. If your GitLab application only has the `api` scope enabled, either enable `read_user` on it or set `scope: 'api'` to keep the old behaviour.

## Custom certificate authority

If your GitLab instance uses a private CA or a self-signed certificate, pass Faraday SSL options:

    use OmniAuth::Builder do
      provider :gitlab, ENV['GITLAB_KEY'], ENV['GITLAB_SECRET'],
        {
           client_options: {
             site: 'https://gitlab.YOURDOMAIN.com',
             connection_opts: { ssl: { ca_file: '/path/to/ca.pem' } }
           }
        }
    end

## Multiple GitLab instances

Use OmniAuth's `setup` option to choose the GitLab instance per request. Here the app's own hostname picks the instance, so the request and callback phases agree:

    GITLAB_INSTANCES = {
      'a.example.com' => { site: 'https://gitlab.a.example', key: ENV['GITLAB_A_KEY'], secret: ENV['GITLAB_A_SECRET'] },
      'b.example.com' => { site: 'https://gitlab.b.example', key: ENV['GITLAB_B_KEY'], secret: ENV['GITLAB_B_SECRET'] }
    }

    use OmniAuth::Builder do
      provider :gitlab, setup: lambda { |env|
        instance = GITLAB_INSTANCES.fetch(Rack::Request.new(env).host)
        strategy = env['omniauth.strategy']
        strategy.options[:client_id] = instance[:key]
        strategy.options[:client_secret] = instance[:secret]
        strategy.options[:client_options][:site] = instance[:site]
      }
    end

The `uid` is GitLab's numeric user id, which is only unique within one instance, so key identities on `auth.extra.site` plus `auth.uid`. Store `extra.site` with any access or refresh token too, since a token only works against the instance that issued it.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

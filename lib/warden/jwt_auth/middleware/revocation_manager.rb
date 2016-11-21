# frozen_string_literal: true

module Warden
  module JWTAuth
    class Middleware
      # Revokes a token
      class RevocationManager < Middleware
        ENV_KEY = 'warden-jwt_auth.revocation_manager'

        attr_reader :config

        def initialize(app, config)
          @app = app
          @config = config
        end

        def call(env)
          env[ENV_KEY] = true
          response = @app.call(env)
          revoke_token(env)
          response
        end

        private

        def revoke_token(env)
          return unless env['PATH_INFO'].match(config.token_revocation_paths)
          token = HeaderParser.parse_from_env(env)
          payload = TokenCoder.decode(token, config)
          user = UserCoder.decode_from_payload(payload)
          config.revocation_strategy.revoke(payload, user)
        end
      end
    end
  end
end

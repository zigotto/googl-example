require "rubygems"
require "googl"

module Googl
  module OAuth2

    # OAuth 2.0 for native applications
    #
    # http://code.google.com/apis/accounts/docs/OAuth2.html#IA
    #
    class Native

      attr_accessor :client_id, :client_secret, :access_token, :refresh_token

      SCOPE = "https://www.googleapis.com/auth/urlshortener"

      def initialize(options={})
        options = {:client_id => "", :client_secret => ""}.merge(options)
        @client_id = options[:client_id]
        @client_secret = options[:client_secret]
      end

      def authorize_url
        "https://accounts.google.com/o/oauth2/auth?client_id=#{client_id}&redirect_uri=urn:ietf:wg:oauth:2.0:oob&scope=#{SCOPE}&response_type=code"
      end

      def request_access_token(options={})
        params = "code=#{options[:code]}&client_id=#{client_id}&client_secret=#{client_secret}&redirect_uri=urn:ietf:wg:oauth:2.0:oob&grant_type=authorization_code"
        Googl::Request.headers.merge!('Content-Type' => 'application/x-www-form-urlencoded')
        resp = Googl::Request.post("https://accounts.google.com/o/oauth2/token", :body => params)
        if resp.code == 200
          Googl::Request.headers.merge!("Authorization" => "OAuth #{resp["access_token"]}")
          @access_token  = resp["access_token"]
          @refresh_token = resp["refresh_token"]
        else
          "Erro: #{resp.code} #{resp.parsed_response}"
        end
      end

      def history
        resp = Googl::Request.get("https://www.googleapis.com/urlshortener/v1/url/history")
        if resp.code == 200
          resp.parsed_response["items"]
        elsif resp.code == 401
          # params = "client_id=#{client_id}&client_secret=#{client_secret}&refresh_token=#{refresh_token}&grant_type=refresh_token"
          puts "Token espirado"
        else
          "Erro: #{resp.code} #{resp.parsed_response}"
        end
      end

    end

  end
end

if $0 == __FILE__
  native = Googl::OAuth2::Native.new(:client_id => "185706845724.apps.googleusercontent.com", :client_secret => "DrBLCdCQ3gOybHrj7TPz/B0N")

  puts native.client_id
  puts native.client_secret

  puts native.authorize_url

  native.request_access_token(:code => "4/0-WSc_JtFagX34LtIQP8n65fz1zF")

  puts native.access_token
  puts native.refresh_token

  puts native.history
end

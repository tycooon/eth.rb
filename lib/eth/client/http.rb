# Copyright (c) 2016-2025 The Ruby-Eth Contributors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "uri"
require "ezclient"

# Provides the {Eth} module.
module Eth

  # Provides an HTTP/S-RPC client with basic authentication.
  class Client::Http < Client

    # The host of the HTTP endpoint.
    attr_reader :host

    # The port of the HTTP endpoint.
    attr_reader :port

    # The full URI of the HTTP endpoint, including path.
    attr_reader :uri

    # Attribute indicator for SSL.
    attr_reader :ssl

    # Attribute for user.
    attr_reader :user

    # Constructor for the HTTP Client. Should not be used; use
    # {Client.create} instead.
    #
    # @param host [String] an URI pointing to an HTTP RPC-API.
    def initialize(host)
      super
      uri = URI.parse(host)
      raise ArgumentError, "Unable to parse the HTTP-URI!" unless ["http", "https"].include? uri.scheme
      @host = uri.host
      @port = uri.port
      @ssl = uri.scheme == "https"
      if !(uri.user.nil? && uri.password.nil?)
        @user = uri.user
        @password = uri.password
        if uri.query
          @uri = URI("#{uri.scheme}://#{uri.user}:#{uri.password}@#{@host}:#{@port}#{uri.path}?#{uri.query}")
        else
          @uri = URI("#{uri.scheme}://#{uri.user}:#{uri.password}@#{@host}:#{@port}#{uri.path}")
        end
      else
        @uri = uri
      end
    end

    # Sends an RPC request to the connected HTTP client.
    #
    # @param payload [Hash] the RPC request parameters.
    # @return [String] a JSON-encoded response.
    def send_request(payload)
      debug_http { "send_request #{@uri} #{payload}" }
      response = client.perform!(:post, @uri, body: payload)
      debug_http { "#{response.inspect}" }
      debug_http { "#{response.body}" }
      response.body.to_s
    end

    private

    def debug_http(&)
      return unless ENV["ETH_LOG_HTTP"]
      debug(&)
    end

    def client
      @client ||=
        EzClient.new(
          keep_alive: Eth.client_keep_alive,
          headers: { "Content-Type" => "application/json" },
          timeout: Eth.client_timeout,
        )
    end
  end

  private

  # Attribute for password.
  attr_reader :password
end

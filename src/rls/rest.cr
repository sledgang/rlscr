require "json"
require "http/client"
require "openssl/ssl/context"

require "./mappings/*"

module RLS
  module REST
    SSL_CONTEXT = OpenSSL::SSL::Context::Client.new
    USER_AGENT  = "rlscr (https://github.com/z64/rlscr, #{RLS::VERSION})"
    API_BASE    = "https://api.rocketleaguestats.com/v1"

    @last_headers : HTTP::Headers?

    # Make a request to the RLS API.
    def request(method : String, path : String,
                headers : HTTP::Headers = HTTP::Headers.new,
                body : String? = nil)
      headers["User-Agent"] = USER_AGENT
      headers["Authorization"] = @key

      request_done = false
      response = nil

      (@mutex ||= Mutex.new).synchronize do
        until request_done
          sleep until_reset if will_be_rate_limited?

          response = HTTP::Client.exec(
            method: method,
            url: API_BASE + path,
            headers: headers,
            body: body,
            tls: SSL_CONTEXT)

          @last_headers = response.headers

          begin
            handle_response(response)
            request_done = true
          rescue ex : CodeException
            if ex.error_code == 429
              sleep until_reset
            else
              raise ex
            end
          end
        end
      end

      response.not_nil!
    end

    private def handle_response(response : HTTP::Client::Response)
      unless response.success?
        raise StatusException.new(response) unless response.content_type == "application/json"

        begin
          error = APIError.from_json(response.body)
        rescue
          raise StatusException.new(response)
        end
        raise CodeException.new(response, error)
      end

      response
    end

    private def last_header(key : String)
      if headers = @last_headers
        headers[key]?
      end
    end

    private def until_reset
      (last_header("x-rate-limit-reset-remaining") || 0).to_i.milliseconds
    end

    private def remaining_requests
      last_header("x-rate-Limit-Remaining").try &.to_i || -1
    end

    private def rate_limit_reset
      if str = last_header("x-rate-limit-reset")
        Time::Format::ISO_8601_DATE_TIME.parse(str)
      else
        Time.now
      end
    end

    private def will_be_rate_limited?
      return false unless @last_headers
      return false if Time.now >= rate_limit_reset
      remaining_requests.zero?
    end

    # Returns the list of active platforms tracked by RLS
    def platforms
      response = request("GET", "/data/platforms")
      Array(PlatformResponse).from_json(response.body)
    end

    # Returns the current list of seasons tracked by RLS
    def seasons
      response = request("GET", "/data/seasons")
      Array(Season).from_json(response.body)
    end

    # Returns the current list of playlists tracked by RLS
    def playlists
      response = request("GET", "/data/playlists")
      Array(PlaylistResponse).from_json(response.body)
    end

    # Returns the current list of tiers for the current season
    def tiers
      response = request("GET", "/data/tiers")
      Array(TierResponse).from_json(response.body)
    end

    # Retrieves a single player
    def player(id : String, platform : Platform = Platform::Steam)
      params = HTTP::Params.build do |form|
        form.add "unique_id", id
        form.add "platform_id", platform.to_i.to_s
      end

      response = request("GET", "/player?#{params}")
      Player.from_json(response.body)
    end

    # Fetch up to 10 players with one request
    def players(query : Array(BatchPlayersPayload))
      raise ArgumentError.new("Only 10 players may be fetched at a time") if query.size > 10

      response = request(
        "POST",
        "/player/batch",
        HTTP::Headers{"Content-Type" => "application/json"},
        query.to_json
      )
      Array(Player).from_json(response.body)
    end

    # Fetch up to 10 players with one request
    def players(query : Tuple(BatchPlayersPayload))
      players(query.to_a)
    end

    # Search for players by display name
    def search(display_name : String, page : UInt32 = 0u32)
      query = HTTP::Params.build do |form|
        form.add "display_name", display_name
        form.add "page", page.to_s
      end

      response = request(
        "GET",
        "/search/players?#{query}"
      )
      SearchResults.new(self, response.body, display_name)
    end

    # Retrieves an array of 100 players sorted by their current season rating
    def leaderboard(playlist : RankedPlaylist)
      query = HTTP::Params.build do |form|
        form.add "playlist_id", playlist.to_i.to_s
      end

      response = request(
        "GET",
        "/leaderboard/ranked?#{query}"
      )
      Array(Player).from_json(response.body)
    end

    # Retrieves an array of 100 players sorted by their specified stat amount
    def leaderboard(type : StatType)
      query = HTTP::Params.build do |form|
        form.add "type", type.to_s.downcase
      end

      response = request(
        "GET",
        "/leaderboard/stat?#{query}"
      )
      Array(Player).from_json(response.body)
    end
  end
end

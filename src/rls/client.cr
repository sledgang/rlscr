require "./rest"
require "./cache"

module RLS
  # The client is the main utility for interacting with the RLS API. It
  # abstracts your API key and caches certain hot API routes. See the
  # `REST` module for a full description of the API.
  # ```
  # client = RLS::Client.new("API_KEY")
  # puts client.player("76561198034606292") # => RLS::Player
  # ```
  #
  # By default, caching is enabled and is handled in memory with a collection
  # of hashes. Cached objects have set expiry rules, and once objects expire
  # the client will perform an HTTP request to update the cache.
  #
  # If you want to disable caching:
  # ```
  # client.player_cache = nil
  # client.leaderboard_cache = nil
  # ```
  class Client
    include REST

    # Cache for `Player` objects
    property player_cache : Memory::Player? = Memory::Player.new

    # Cache for leaderboards, which are arrays of `Player` objects
    property leaderboard_cache : Memory::Leaderboard? = Memory::Leaderboard.new

    def initialize(@key : String)
    end

    # Retrieves a single player by ID and `Platform`. ID is a Steam ID, PSN
    # username, Xbox Gamertag, or Xbox XUID.
    #
    # If the `player_cache` is present, it will be used to return cached
    # players immediately, or perform an API request on a cache miss.
    def player(id : String, platform : Platform = Platform::Steam)
      if cache = @player_cache
        maybe_player = cache.resolve(id, platform)
        if player = maybe_player
          return player
        else
          return cache.cache super(id, platform)
        end
      else
        super(id, platform)
      end
    end

    # Fetch up to 10 players with one request. See `BatchPlayersPayload`
    #
    # If the `player_cache` is present, it will be used to return cached
    # players immediately, or perform an API request on a cache miss.
    def players(query : Array(REST::BatchPlayersPayload))
      results = [] of Player

      if cache = @player_cache
        uncached = [] of REST::BatchPlayersPayload

        query.each do |element|
          if player = cache.resolve(element.id, element.platform)
            results << player
          else
            uncached << element
          end
        end

        if uncached.any?
          results += super(uncached)
          results.each { |p| cache.cache(p) }
        end

        results
      else
        super(query)
      end
    end

    # Retrieves an array of 100 players sorted by their current season rating
    #
    # If the `leaderboard_cache` is present, it will be used to immediately return
    # a leaderboard, or perform an API request on a cache miss
    def leaderboard(playlist : REST::RankedPlaylist)
      if cache = @leaderboard_cache
        maybe_board = cache.resolve(playlist)
        if board = maybe_board
          return board
        else
          return cache.cache(playlist, super(playlist))
        end
      else
        super(playlist)
      end
    end

    # Retrieves an array of 100 players sorted by their specified stat amount
    #
    # If the `leaderboard_cache` is present, it will be used to immediately return
    # a leaderboard, or perform an API request on a cache miss
    def leaderboard(type : REST::StatType)
      if cache = @leaderboard_cache
        maybe_board = cache.resolve(type)
        if board = maybe_board
          return board
        else
          return cache.cache(type, super(type))
        end
      else
        super(type)
      end
    end
  end
end

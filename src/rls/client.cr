require "./rest"
require "./cache"

module RLS
  class Client
    include REST

    property player_cache : Memory::Player? = Memory::Player.new

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
  end
end

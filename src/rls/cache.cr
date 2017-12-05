module RLS
  # Collection of in-memory caches
  module Memory
    # Cache for `Player` objects. Player objects are considered valid until
    # their expiry time of `Player#next_update` is reached.
    class Player
      @data = {} of Tuple(String, RLS::Platform) => RLS::Player

      # Stores a player in the cache
      def cache(player : RLS::Player)
        @data[{player.id, player.platform}] = player
      end

      # Resolves a player from the cache. Returns `nil` if the stored
      # player data is due for an update.
      def resolve(id : String, platform : RLS::Platform) : RLS::Player?
        if player = @data[{id, platform}]?
          Time.now > player.next_update ? nil : player
        end
      end

      # Prunes the cache of expired players
      def prune
        players = @data.values

        players.each do |player|
          if Time.now > player.next_update
            @data[{player.id, player.platform}] = nil
          end
        end
      end
    end
  end
end

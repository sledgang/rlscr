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

    # Cache for leaderboards, which are arrays of players associated
    # with a particular stat type or game mode. Leaderboards are valid
    # (server-side) for `EXPIRY_TIME`, as described in the RLS documentation.
    # TODO: `prune` method
    class Leaderboard
      # The duration to hold onto leaderboards for
      EXPIRY_TIME = 15.minutes

      @data = {} of RLS::REST::StatType | RLS::REST::RankedPlaylist => Tuple(Time, Array(RLS::Player))

      # Stores a leaderboard in the cache
      def cache(type : RLS::REST::StatType | RLS::REST::RankedPlaylist, players : Array(RLS::Player))
        @data[type] = {Time.now + EXPIRY_TIME, players}
        players
      end

      # Resolves a leaderboard from the cache. Returns `nil` if the stored
      # leaderboard is due for an update.
      def resolve(type : RLS::REST::StatType | RLS::REST::RankedPlaylist) : Array(RLS::Player)?
        if board = @data[type]?
          return if Time.now > board[0]
          board[1]
        end
      end
    end
  end
end

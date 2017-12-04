module RLS
  # An entry in a player's ranked history
  struct RankedHistory
    getter! playlist : Playlist

    JSON.mapping(
      rank_points: {type: UInt32, key: "rankPoints"},
      matches_played: {type: UInt32?, key: "matchesPlayed"},
      tier: Tier?,
      division: {type: UInt8?, key: "division"}
    )

    def initialize(@playlist : Playlist, parser : JSON::PullParser)
      initialize(parser)
    end
  end
end

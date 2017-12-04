module RLS
  # Playlists. These are changed very infrequently, so this constant enum
  # is provided to avoid unecessary API requests.
  enum Playlist : UInt8
    Duel               =  1
    Doubles            =  2
    Standard           =  3
    Chaos              =  4
    RankedDuel         = 10
    RankedDoubles      = 11
    RankedSoloStandard = 12
    RankedStandard     = 13
    MutatorMashup      = 14
    SnowDay            = 15
    RocketLabs         = 16
    Hoops              = 17
    Rumble             = 18
    Dropshot           = 23
  end
end

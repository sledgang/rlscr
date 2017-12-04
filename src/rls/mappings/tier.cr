module RLS
  # Ranked Tiers. These are changed very infrequently, so this constant enum
  # is provided to avoid unecessary API requests.
  enum Tier : UInt8
    Unranked      =  0
    BronzeI       =  1
    BronzeII      =  2
    BronzeIII     =  3
    SilverI       =  4
    SilverII      =  5
    SilverIII     =  6
    GoldI         =  7
    GoldII        =  8
    GoldIII       =  9
    PlatinumI     = 10
    PlatinumII    = 11
    PlatinumIII   = 12
    DiamondI      = 13
    DiamondII     = 14
    DiamondIII    = 15
    ChampionI     = 16
    ChampionII    = 17
    ChampionIII   = 18
    GrandChampion = 19
  end
end

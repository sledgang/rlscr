module RLS
  # A player's overall stats, as recorded by RLS
  struct Stats
    JSON.mapping(
      wins: UInt32,
      goals: UInt32,
      mvps: UInt32,
      saves: UInt32,
      shots: UInt32,
      assists: UInt32
    )
  end
end

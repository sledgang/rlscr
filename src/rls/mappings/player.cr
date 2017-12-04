module RLS
  # A Rocket League player, as tracked by RLS
  struct Player
    JSON.mapping(
      id: {type: String, key: "uniqueId"},
      display_name: {type: String, key: "displayName"},
      platform: {type: Platform, converter: PlatformConverter},
      avatar: String?,
      profile_url: {type: String, key: "profileUrl"},
      signature_url: {type: String, key: "signatureUrl"},
      stats: Stats,
      last_requested: {type: Time, key: "lastRequested", converter: EpochConverter},
      created_at: {type: Time, key: "createdAt", converter: EpochConverter},
      updated_at: {type: Time, key: "updatedAt", converter: EpochConverter},
      next_update: {type: Time, key: "nextUpdateAt", converter: EpochConverter},
      ranked_history: {type: Hash(UInt8, Array(RankedHistory)), key: "rankedSeasons", converter: RankedHistoryConverter}
    )
  end
end

module RLS
  # A Rocket League season, as tracked by RLS
  struct Season
    JSON.mapping(
      id: {type: UInt8, key: "seasonId"},
      started_on: {type: Time, key: "startedOn", converter: EpochConverter},
      ended_on: {type: Time?, key: "endedOn", converter: MaybeEpochConverter}
    )

    # Whether this season is the current season
    def current?
      @ended_on.nil?
    end
  end
end

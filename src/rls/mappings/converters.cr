module RLS
  # :nodoc:
  module EpochConverter
    def self.from_json(parser : JSON::PullParser)
      Time.epoch parser.read_int
    end

    def self.to_json(value : Time, builder : JSON::Builder)
      builder.number value.epoch
    end
  end

  # :nodoc:
  module MaybeEpochConverter
    def self.from_json(parser : JSON::PullParser)
      if value = parser.read_int_or_null
        Time.epoch value
      end
    end

    def self.to_json(value : Time?, builder : JSON::Builder)
      if value
        builder.number value.epoch
      else
        builder.null
      end
    end
  end

  # :nodoc:
  module PlatformConverter
    def self.from_json(parser : JSON::PullParser)
      platform = REST::PlatformResponse.new(parser)
      Platform.new(platform.id)
    end

    def self.to_json(value : Platform, builder : JSON::Builder)
      builder.string value.to_i.to_s
    end
  end

  # :nodoc:
  module RankedHistoryConverter
    def self.from_json(parser : JSON::PullParser)
      hash = {} of UInt8 => Array(RankedHistory)

      parser.read_object do |key|
        season_id = key.to_u8
        history = [] of RankedHistory

        parser.read_object do |key|
          playlist_id = Playlist.new(key.to_u8)
          history << RankedHistory.new(playlist_id, parser)
        end

        hash[season_id] = history
      end

      hash
    end
  end
end

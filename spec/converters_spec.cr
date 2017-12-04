require "./spec_helper"

def it_converts(json, to value, with converter, file = __FILE__, line = __LINE__)
  describe converter, file, line do
    describe ".from_json" do
      it "converts #{json.inspect} to #{value.inspect}" do
        parser = JSON::PullParser.new(json)
        converted = converter.from_json(parser)
        converted.should eq value
      end
    end
  end
end

def it_serializes(value, to json, with converter, file = __FILE__, line = __LINE__)
  describe converter, file, line do
    describe ".to_json" do
      it "serializes #{value.inspect} to #{json.inspect}" do
        converted = JSON.build do |builder|
          converter.to_json(value, builder)
        end

        converted.should eq json
      end
    end
  end
end

describe "Converters" do
  it_converts("0", to: Time.epoch(0), with: RLS::EpochConverter)
  it_serializes(Time.epoch(0), to: "0", with: RLS::EpochConverter)

  it_converts("0", to: Time.epoch(0), with: RLS::MaybeEpochConverter)
  it_serializes(Time.epoch(0), to: "0", with: RLS::MaybeEpochConverter)
  it_converts("null", to: nil, with: RLS::MaybeEpochConverter)
  it_serializes(nil, to: "null", with: RLS::MaybeEpochConverter)

  it_converts(%({"id":1, "name":"Steam"}), to: RLS::Platform::Steam, with: RLS::PlatformConverter)
  it_serializes(RLS::Platform::Steam, to: %("1"), with: RLS::PlatformConverter)

  describe RLS::RankedHistoryConverter do
    json = %({"1":{"10":{"rankPoints":366},"11":{"rankPoints":715},"12":{"rankPoints":515},"13":{"rankPoints":517}},"5":{"10":{"rankPoints":706,"matchesPlayed":27,"tier":8,"division":2},"11":{"rankPoints":809,"matchesPlayed":17,"tier":10,"division":0},"12":{"rankPoints":557,"matchesPlayed":12,"tier":6,"division":1},"13":{"rankPoints":776,"matchesPlayed":39,"tier":9,"division":2}}})

    describe ".from_json" do
      it "converts sample JSON to Hash(UInt8, Array(RankedHistory))" do
        parser = JSON::PullParser.new(json)
        converted = RLS::RankedHistoryConverter.from_json(parser)
        converted.should be_a Hash(UInt8, Array(RLS::RankedHistory))
      end
    end
  end
end

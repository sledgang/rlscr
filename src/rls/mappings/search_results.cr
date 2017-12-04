module RLS
  # Paginated search results from RLS
  struct SearchResults
    getter! client : Client

    getter! display_name : String

    JSON.mapping(
      page: UInt32,
      results: UInt32,
      total_results: {type: UInt32, key: "totalResults"},
      max_results_per_page: {type: UInt32, key: "maxResultsPerPage"},
      players: {type: Array(Player), key: "data"}
    )

    def initialize(@client : Client, parser : JSON::PullParser, name : String)
      @display_name = name
      initialize(parser)
    end

    def initialize(client : Client, data : String, name : String)
      parser = JSON::PullParser.new(data)
      initialize(client, parser, name)
    end

    def next_page
      return [] of Player if players.size >= total_results
      @page += 1u32
      search = client.search(display_name, page)
      @players += search.players
      search.players
    end

    def all
      until next_page.empty?
        # What could possibly go wrong?
      end
      players
    end
  end
end

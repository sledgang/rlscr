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
      data: Array(Player)
    )

    def initialize(@client : Client, parser : JSON::PullParser, diplay_name : String)
      @display_name = display_name
      initialize(parser)
    end

    def next_page
      return [] of Player if results < max_results_per_page
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

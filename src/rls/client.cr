require "./rest"

module RLS
  class Client
    include REST

    def initialize(@key : String)
    end
  end
end

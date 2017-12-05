module RLS::REST
  class StatusException < Exception
    getter response : HTTP::Client::Response

    def initialize(@response : HTTP::Client::Response)
    end

    delegate status_code, status_message, to: @response

    def message
      "#{status_code} #{status_message}"
    end

    def to_s(io)
      io << status_code << " " << status_message
    end
  end

  class APIError
    JSON.mapping(code: UInt16, message: String)
  end

  class CodeException < StatusException
    getter error : APIError

    def initialize(@response : HTTP::Client::Response, @error : APIError)
    end

    def error_code
      @error.code
    end

    def error_message
      @error.message
    end

    def message
      super + ": Code #{error_code} - #{error_message}"
    end

    def to_s(io)
      super(io)
      io << ": Code " << error_code << " - " << error_message
    end
  end
end

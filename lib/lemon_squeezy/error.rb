module LemonSqueezy
  class Error < StandardError
    attr_reader :status, :error_details

    def initialize(message, status: nil, error_details: nil)
      @status = status
      @error_details = error_details
      super(message)
    end
  end
end

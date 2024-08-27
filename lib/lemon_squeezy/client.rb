module LemonSqueezy
  class Client

    class << self

      def connection
        @connection ||= Faraday.new("https://api.lemonsqueezy.com/v1") do |conn|
          conn.request :authorization, :Bearer, LemonSqueezy.config.api_key

          conn.headers = {
            "User-Agent" => "lemonsqueezy/v#{VERSION} (github.com/deanpcmad/lemonsqueezy)",
            "Accept" => "application/vnd.api+json",
            "Content-Type" => "application/vnd.api+json"
          }

          conn.request :json
          conn.response :json
        end
      end

      def get_request(url, params: {}, headers: {})
        handle_response connection.get(url, params, headers)
      end

      def post_request(url, body: {}, headers: {})
        handle_response connection.post(url, body, headers)
      end

      def patch_request(url, body:, headers: {})
        handle_response connection.patch(url, body, headers)
      end

      def delete_request(url, headers: {})
        handle_response connection.delete(url, headers)
      end

      def handle_response(response)
        case response.status
        when 400
          raise Error.new("Error 400: Your request was malformed.", status: 400, error_details: response.body["errors"])
        when 401
          raise Error.new("Error 401: You did not supply valid authentication credentials.", status: 401, error_details: response.body["errors"])
        when 403
          raise Error.new("Error 403: You are not allowed to perform that action.", status: 403, error_details: response.body["errors"])
        when 404
          raise Error.new("Error 404: No results were found for your request.", status: 404, error_details: response.body["errors"])
        when 409
          raise Error.new("Error 409: Your request was a conflict.", status: 409, error_details: response.body["errors"])
        when 429
          raise Error.new("Error 429: Your request exceeded the API rate limit.", status: 429, error_details: response.body["errors"])
        when 422
          raise Error.new("Error 422: Unprocessable Entity.", status: 422, error_details: response.body["errors"])
        when 500
          raise Error.new("Error 500: We were unable to perform the request due to server-side problems.", status: 500, error_details: response.body["errors"])
        when 503
          raise Error.new("Error 503: You have been rate limited for sending more than 20 requests per second.", status: 503, error_details: response.body["errors"])
        when 501
          raise Error.new("Error 501: This resource has not been implemented.", status: 501, error_details: response.body["errors"])
        when 204
          return true
        end

        if response.body && response.body["error"]
          raise Error.new("Error #{response.body["error"]["code"]} - #{response.body["error"]["message"]}", status: response.status, error_details: response.body["error"])
        end

        response
      end

    end

  end
end

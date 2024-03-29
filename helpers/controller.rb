class Controller < Sinatra::Base
  helpers do 

    # Public: Require a user to login to access a route
    #
    # Examples
    #
    #   get "/protected" end
    #     require_login
    #   end
    #
    # Returns nothing.
    def require_login
      load_current_user
      redirect "/login" unless logged_in?
    end
    
    # Public: Requires a read token to access a route
    #
    # Examples
    #
    #   get "/protected" end
    #     require_read_token
    #   end
    #
    # Returns nothing if a write token is available.
    # Returns a 401 unauthorized error if a read token is unavailable.
    def require_read_token
      process_token
      api_error_unauthorized "invalid access token" if @_raptor_read_token.nil?
    end
    
    # Public: Requires a write token to access a route
    #
    # Examples
    #
    #   get "/protected" end
    #     require_write_token
    #   end
    #
    # Returns nothing if a write token is available.
    # Returns a 401 unauthorized error if a write token is unavailable.
    def require_write_token
      process_token
      api_error_unauthorized "invalid access token" if @_raptor_write_token.nil?
    end

    # Public: Requires a read token or an active session to access a route
    #
    # Examples
    #
    #   get "/protected" end
    #     require_read_token_or_login
    #   end
    #
    # Returns nothing if a write token or active session if available.
    # Returns a 401 unauthorized error if a read token/session is unavailable.
    def require_read_token_or_login
      load_current_user
      unless  logged_in? || @_raptor_read_token.nil?
        api_error_unauthorized "invalid authorization" 
      end
    end

    # Public: Requires a write token or an active session to access a route
    #
    # Examples
    #
    #   get "/protected" end
    #     require_write_token_or_login
    #   end
    #
    # Returns nothing if a write token or active session if available
    # Returns a 401 unauthorized error if a write token/session is unavailable.
    def require_write_token_or_login
      load_current_user
      unless  logged_in? || @_raptor_write_token.nil?
        api_error_unauthorized "invalid authorization" 
      end
    end

    # Public: Checks if the user is currently logged in.
    # 
    # Examples
    #
    #   logged_in?
    #   # => true
    #
    #   logged_in?
    #   # => false
    #
    # Returns true if the user is logged in or false if they are not.
    def logged_in?
      (!@_current_user.nil? && session[:session_id]) ? true : false
    end

    # Public: Convenience method for accessing the currently logged in user
    # 
    # Examples
    #
    #   current_user.email
    #   # => joe.smith@example.com
    #
    # Returns the currently logged in user.
    def current_user
      @_current_user
    end

    # Public: Helper for returning JSON output from a route
    # 
    # status  - The Integer representing the HTTP status code of the response.
    # payload - A Ruby Object that responds to the to_json method to be sent as 
    #           the response body
    #
    # Examples
    #
    #   get "/json" do
    #     api_response(200, {result'ok'})
    #   end
    #
    # Returns a response with the HTTP status code and json encoded payload.
    def api_response(status, payload)
      halt status, process_payload(payload)
    end

    API_ERRORS = [
      {status: 400, type: 'bad_request'},
      {status: 401, type: 'unauthorized'},
      {status: 402, type: 'payment_required'},
      {status: 403, type: 'access_denied'},
      {status: 404, type: 'not_found'},
      {status: 406, type: 'not_acceptable'},
      {status: 409, type: 'conflict'},
      {status: 422, type: 'invalid_input'},
      {status: 429, type: 'rate_limited'},
      {status: 500, type: 'server_error'},
      {status: 502, type: 'bad_gateway'},
      {status: 503, type: 'service_unavailable'},
      {status: 507, type: 'insufficient_storage'}
    ]

    API_ERRORS.each do |api_error|
      define_method "api_error_#{api_error[:type]}".to_sym do |message, fields=nil|
        api_error api_error[:status], api_error[:type], message, fields
      end
    end

    # Public: Helper for returning consistant error messages from a route
    # 
    # status  - An Integer representing the HTTP status code of the error
    # type    - A String represneting the type of the error
    # message - A String respresenting a description of the error
    # fields  - (Optional) An array of erro messages generated by MongoIDs
    #           validations          
    #
    # Examples
    #
    #   get "/not_found" do
    #     api_error(404, "not_found", "the requested route was not found")
    #   end
    #
    #   get "/invalid_input" do
    #     user = User.create({
    #       ... invalid data
    #     })
    #     api_error(422, "invalid_input", "the provided input was invalid", user.errors)
    #   end
    #
    # Returns a response with the HTTP status code and a json error message.
    def api_error(status, type, message, fields=nil)
      payload = {error: {type: type, message: message}}
      payload[:error][:fields] = api_field_errors(fields) if fields
      halt status, process_payload(payload)
    end

    # Public: Helper for returning JSON errors based on MongoID validations
    # 
    # errors  - A set of errors from MongoID validations
    #
    # Examples
    #
    #   get "/invalid_input" do
    #     user = User.create({
    #       ... invalid data
    #     })
    #     api_validation_error(user.errors)
    #   end
    #
    # Returns a HTTP error message detailing the invalid input.
    def api_validation_error(errors)
      field_errors = api_field_errors(errors)
      if errors.count <= 1
        error = errors.messages.first[1]
        api_error(error[:status], error[:type], error[:message], field_errors)
      else
        api_error_invalid_input("there was a problem with the input", field_errors)
      end
    end
    
    # Public: Helper for normalizing JSON encoded POST requests and query string params
    # 
    #
    # Returns a HTTP error message detailing the invalid input.
    def process_input
      request_body = request.body.read
      if request_body[0] == "{" && request_body[-1] == "}"
        @_input = JSON.parse(request_body)
      else
        @_input = params
      end
    end

    def input_hash
      @_input
    end

    def input_mash
      Hashie::Mash.new @_input
    end

    private
    
    # Internal: Helper to format MongoID validation errors.
    # 
    # errors  - A set of errors from MongoID validations
    #
    # Examples
    #
    #   get "/invalid_input" do
    #     user = User.create({
    #       ... invalid data
    #     })
    #     api_validation_error(user.errors)
    #   end
    #
    # Returns a Hash with of validation errors that can be converted to JSON.
    def api_field_errors(errors)
      fields = []
      errors.messages.each do |field, error|
        fields << {
          field: field,
          type: error[:type],
          message: error[:message]
        }
      end
      fields
    end

    # Internal: Finds a read or write token from a request. Used by other 
    # permission checking methods such as `require_write_token`.
    # 
    # Examples
    #
    #   get "/protected" end
    #     process_token
    #   end
    #
    # Returns nothing.
    def process_token
      auth_token = params[:raptor_auth] || request["X-Raptor-Auth"]
      api_error_unauthorized "the endpoint '#{request.path}' requires an access token" if auth_token.nil?
      if auth_token[0] === "r"
        @_raptor_read_token = Token.where(read: auth_token).only(:read).first().read
      elsif auth_token[0] === "w"
        @_raptor_write_token = Token.where(write: auth_token).only(:write).first().write
      else
        api_error_unauthorized "invalid access token"
      end
    end
    
    # Internal: Load the user from the session object.
    # 
    # Examples
    #
    #   load_current_user
    #   # => @_current_user = <Mong>
    #
    # Returns the currently logged in user.
    def load_current_user
      @_current_user = User.find(session[:user_id]) if(session[:user_id] && session[:session_id])
    end

    # Internal: Output helper to support JSONP for requests.
    # 
    # payload - An Object to be converted to JSON for output
    #
    # Examples
    #
    #   get "/invalid_input" do
    #     user = User.create({
    #       ... invalid data
    #     })
    #     api_validation_error(user.errors)
    #   end
    #
    # Returns the payload object converted to JSON.
    # Returns the JSON in a callback function if a callback id was supplied.
    def process_payload(payload)
      if p[:callback]
        response_body = "#{p[:callback]}({\n"+
                        "  #{payload.to_json}\n"+
                        "})"
      else
        response_body = payload.to_json
      end
    end

  end
end
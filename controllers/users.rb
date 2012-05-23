class Users < Controller
  
  before do
    content_type 'application/json'
    if request.request_method === "GET"
      require_read_token_or_login
    else
      require_write_token_or_login
    end
  end

  get "/" do
    api_response(200, User.all_in)
  end

  get "/me" do
    api_response(200, current_user)
  end

  get "/:id" do
    user = User.find(params[:id])
    if user.nil?
      api_error_not_found("not_found", "could not find user with id '#{params[:id]}'")
    else
      api_response(200, user)
    end
  end

  post "/" do
    data = JSON.parse(request.body.read)
    user = User.create data
    if user.valid?
      api_response(201, user)
    else
      api_validation_error(user.errors)
    end
  end

  put "/user/:id" do
    data = JSON.parse(request.body.read)
    user = User.find(params[:id])

    api_error_not_found("not_found", "could not find user with id '#{params[:id]}'") if user.nil?
    
    user.attributes = data
    
    if user.valid?
      api_response(200, user)
    else
      api_validation_error(user.errors)
    end
  end

  delete "/:id" do
    user = User.find(params[:id])
    if user.nil?
      api_error_not_found("not_found", "could not find user with id '#{params[:id]}'")
    elsif user.delete
      api_response(200, {action: "deleted", resource: "user", id:params[:id]})
    else
      api_error_server_error("server_error", "could not delete user with id '#{params[:id]}'")
    end
  end
end
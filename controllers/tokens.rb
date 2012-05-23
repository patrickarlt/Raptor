class Tokens < Controller
  
  before do
    content_type 'application/json'
    load_current_user
    unless logged_in?
      user = User.where({email: params[:email]}).first
      if user.nil? && !user.authenticates?(params[:password])
        api_error_unauthorized({type:"unauthorized", message:"email or password is incorrect"})
      end
    end
  end

  get "/write" do
    api_response(200, Token.first.write)
  end

  get "/read" do
    api_response(200, Token.first.read)
  end

end
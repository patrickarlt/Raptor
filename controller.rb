class Controller < Sinatra::Base
  
  get '/' do
    require_login
    title "Index"
    #erb :'index'
  end
  
  get '/login/?' do
    title "Login"
    erb :'login', layout: :"page-layout"
  end

  post '/login/?' do

    user = User.unscoped.where({email: params[:email]}).first
    if !user.nil? && user.authenticates?(params[:password])
      session[:user_id] = user[:_id]
      redirect '/admin'
    else 
      flash[:error] = "Username Or password is incorrect"
      redirect '/login'
    end
  end

  get '/logout/?' do
    session.clear
    @_current_user = nil
    erb :'logout', layout: :"page-layout"
  end

  get '/admin' do
    require_login
    title "Admin"
    erb :index
  end

  get "/admin/*" do
    require_login
    title "Admin"
    erb :index
  end

end
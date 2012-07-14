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

<<<<<<< HEAD
  get "/admin/*" do
    require_login
    title "Admin"
=======
  # Put Routes Here
  get "/" do
    title "Home Page"
    description "An application framework with Sinatra, MongoID, and Redis"
    @message = "Hello visitor #" + Counter.increment.to_s + " the CRON has been run " + Counter.cron.to_s || "0" + " times"
    Resque.enqueue(Counter)
>>>>>>> 43e1cd449eb7b740cea596215a148bd1c8fbc62c
    erb :index
  end

end
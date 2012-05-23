class Posts < Controller
  
  helpers do
    def respond_with_post post
      if post
        api_response(200, post)
      else 
        api_error_not_found("that post does not exist")
      end
    end
  end

  before do
    content_type 'application/json'
    if request.request_method === "GET"
      require_read_token_or_login
    else
      require_write_token_or_login
    end
    process_input
  end

  # Public: Get posts matching query parameters
  #
  # skip     - (Integer) Return posts from this page
  # limit    - (Integer) Alias for per_page
  # slug     - (String)  String representing the post slug
  # id       - (Integer) Integer representing the post id
  # before   - (Date)    Returns all posts before Date
  # after    - (Date)    Returns all posts after Date
  # from     - (Date)    Returns all posts from Date (also requires to)
  # to       - (Date)    Returns all posts to Date (also requires from)
  # status   - (String)  String representing publish status (published, idea, scheduled)
  # order    - (String)  ASC or DESC
  # order_by - (String)  String Representing the field to order on
  #
  # Examples
  #
  #   get "/protected" end
  #     require_login
  #   end
  #
  # Returns a JSON encoded array of posts
  get "/" do
    puts input_hash.inspect
    posts = Post.build_criteria(input_hash)
    api_response(200, posts)
  end

  get "/search" do
    api_response(200, current_user)
  end

  get "/:slug" do
    post = Post.find_by_slug(params[:id])
    respond_with_post post
  end

  get "/:id" do
    post = Post.find(params[:id])
    respond_with_post post
  end

  post "/" do
    post = Post.create(input_hash)
    if post.valid?
      api_response(201, post)
    else
        api_validation_error(post.errors)
    end
  end

  put "/:id" do
    post = Post.find(params[:id])
    post.update_attributes(input_hash)
    if post.valid?
      post.save()
      if(post.persisted?)
        api_response(201, post)
      else
        api_error_server_error("could not save post")
      end
    else
      api_validation_error(user.errors)
    end
  end

  delete "/:id" do
    post = Post.find(params[:id])
    post.delete()
    post.destory()
    if(post.exists?)
      api_error_server_error("there was an error deleting your post");
    else 
      api_response(201, {
        result:"ok",  
      })
    end
  end
end
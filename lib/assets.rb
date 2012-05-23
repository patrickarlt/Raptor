module Assets
  def self.included(klass)
    klass.register Sinatra::AssetPack
    
    klass.assets {
      serve '/js',     from: 'assets/js'
      serve '/css',    from: 'assets/css'
      serve '/images', from: 'assets/img'
      serve '/templates', from: 'assets/templates/'
      
      # Setup a bundle of Javascript      
      js :admin_libs, [
        '/js/libs/underscore/underscore-min.js',
        '/js/libs/underscore/underscore.string.min.js',
        '/js/extensions/underscore.js',
        '/js/libs/backbone/backbone-min.js',
        '/js/libs/jquery/jquery.serializeObject.js'
      ]
      
      js :admin_main, [
        '/js/admin/namespace.js',
        '/js/admin/views/posts/list.js',
        '/js/admin/views/posts/single.js',
        '/js/admin/models/post.js',
        '/js/admin/collections/posts.js',
        '/js/admin/views/main.js',
        '/js/admin/router.js',
        '/js/admin/init.js'
      ]

      # Setup a bundle of CSS
      css :main_css, [
        #'/css/reset.css'
      ]
      
      # Set Compressors
      js_compression  :yui, :munge => true
      css_compression :sass

      # Prebuild assets in prodctions
      prebuild ENV['RACK_ENV'] === 'production'
    }
  end
end
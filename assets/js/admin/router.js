Raptor.namespace("Raptor.Routers.Main", function(){
  router = Backbone.Router.extend({
    routes: {
      "": "root",
      "posts/new": "newPost",
      "posts/edit/:slug": "editPost"
    },
    initialize: function(){
      Raptor.Views.Main.render();
    },
    root: function(){
    },
    newPost: function(){
      console.log("New Post");
      Raptor.Views.Posts.Single.render();
    },
    editPost: function(slug){
      Raptor.Views.Posts.Single.render(slug);
    }
  });
  return router;
});
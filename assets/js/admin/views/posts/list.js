Raptor.Views.Posts.List = (function(){

  list = Backbone.View.extend({
    el: "body",
    events: {
      "click .delete": "deletePost"
    },
    render: function(posts){
      // Fetch the hello.html template from the server run a callback to render the
      // template to the page. The callback is run in the context of the view.
      Raptor.fetchTemplate("PostList", "posts/list.html", _.bind(function(template){
        this.template =  template;
        this.$el.html(this.template({posts: posts}));
      }, this));
    },
    deletePost: function(e){
      postId = $(e.target).data("post-id");
      Raptor.Collections.Posts.get(postId).destroy({
        success: function(){
          console.log("Deleted");
        },
        error: function(){
          console.log("Error");
        }
      });
    }
  });

  return new list();

})();
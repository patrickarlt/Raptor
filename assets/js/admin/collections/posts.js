Raptor.Collections.Posts = (function(){

  posts = Backbone.Collection.extend({
    model: Raptor.Models.Post,
    view: Raptor.Views.Posts.List,
    url: "posts",
    initialize: function(){
      this.fetch({
        data: {
          limit: -1,
          status: "any"
        },
        processData:true
      });

      this.on("reset", function(collection){
        this.view.render(collection);
      });

      this.on("add", function(collection){
        this.view.render(collection);
      });
    },
    getBySlug: function(slug){
      this.where({slug: slug});
    }
  });

  return new posts();

})();
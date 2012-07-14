Raptor.namespace("Raptor.Models.Post", function(){

  post = Backbone.Model.extend({
    url: "posts",
    validate: function(attributes){
      if(!attributes.title){
        return "You must have a title";
      }
      if(!attributes.content){
       return "You must have some content";
      }
    }
  });

  return post;

});
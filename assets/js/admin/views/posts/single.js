Raptor.namespace("Raptor.Views.Posts.Single", function(){
	
	edit = Backbone.View.extend({
		el: "body",
		events: {
			"#post-form": "createPost"
		},
		render: function(slug){
			post = (slug) ? Raptor.Collections.Posts.getBySlug(slug) : null;
			Raptor.fetchTemplate("PostList", "posts/single.html", _.bind(function(template){
				this.template =  template;
				this.$el.html(this.template({post: null}));
			}, this));
		},
		createPost: function(e){
			data = $(e.target).serializeObject();
			Raptor.Collections.Posts.create(data);
			Raptor.Router.navigate("/");
		}
	});
	
	return new edit();
});
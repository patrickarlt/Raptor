Raptor.Views.Main = (function(){

  main = Backbone.View.extend({
    el: "body",
    events: {},
    render: function(){

      // Fetch the hello.html template from the server run a callback to render the 
      // template to the page. The callback is run in the context of the view.
      Raptor.fetchTemplate("Main", "hello.html", _.bind(function(template){
        this.template =  template;
        this.$el.html(this.template());
      }, this));

    },
    initialize: function(){
      
    }
  });

  return new main();

})();
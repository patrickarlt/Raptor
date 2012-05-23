// Start the Router
Raptor.init = function(){
  Raptor.Router = new Raptor.Routers.Main();

  $(document).on("click", "a:not([data-bypass])", function(e) {
    var href = $(this).attr("href");
    var protocol = this.target.protocol + "//";
    if (href && href.slice(0, protocol.length) !== protocol) {
      e.preventDefault();
      Raptor.Router.navigate(href, true);
    }
  });
  
  Backbone.history.start({pushState: true, root:"/admin/"});
};

// Loads any script tag with a `data-raptor-template` attribute
Raptor.loadTemplates = function() {
  $("script[data-raptor-template]").each(function(){
    templateName = $(this).data("raptor-template");
    templateContent = _.trim($(this).text());
    Raptor.Templates[templateName] = _.template(templateContent);
    $(this).remove();
  });
};

// Asynchronously fetch a template from the server and execute a callback with a certaion context
Raptor.fetchTemplate = function(name, path, callback) {
  var def = new $.Deferred();

  // Should be an instant synchronous way of getting the template, if it
  // exists in the JST object.
  if (Raptor.Templates[path]) {
    if (_.isFunction(callback)) {
      callback(Raptor.Templates[path]);
    }

    return def.resolve(Raptor.Templates[path]);
  }

  // Fetch it asynchronously if not available from JST, ensure that
  // template requests are never cached and prevent global ajax event
  // handlers from firing.
  $.ajax({
    url: "/templates/"+path,
    type: "get",
    dataType: "text",
    cache: false,
    global: false,

    success: function(contents) {
      Raptor.Templates[path] = _.template(contents);

      // Set the global JST cache and return the template
      if (_.isFunction(callback)) {
        callback(Raptor.Templates[path]);
      }

      // Resolve the template deferred
      def.resolve(Raptor.Templates[path]);
    }
  });

  // Ensure a normalized return value (Promise)
  return def.promise();
},

// Run Raptor.init on DOMready
$(function(){
  Raptor.init();
});
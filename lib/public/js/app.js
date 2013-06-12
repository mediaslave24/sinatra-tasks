(function($) {
  var app = {
    confirmHandler: function() {
      var confirmMessage = $(this).attr("data-confirm");
          if(!confirm(confirmMessage))
            event.preventDefault();
    }
  }

  $("a[data-confirm]").click(app.confirmHandler);
})(jQuery);

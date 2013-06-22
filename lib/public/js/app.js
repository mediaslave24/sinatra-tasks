var app = app || {};

(function($) {

  var App = function() {

    function confirmHandler() {
      var confirmMessage = $(this).attr("data-confirm");
          if(!confirm(confirmMessage))
            event.preventDefault();
    }

    function makeEditable() {
      var link = $(this),
          header = link
                    .parent()
                    .parent()
                    .siblings('h3'),
          name = link.attr("data-name");
          url = link.attr("data-url"),
          target = link.attr("data-target"),
          editable = $("<input type='text'/>",{
                        type: "text",
                        class: "editable",
                        name: name
                      }),
          requiredCss = header.css([
            "font-family", 
            "font-size",
            "font-weight",
            "width",
            "height",
            "line-height",
            "color",
            "margin",
            "padding"
          ]),
          value = header.text(); 

      editable.css(requiredCss);
      editable.attr("value", value);
      header.after(editable);
      editable.keyup(function(event){
        if ( event.keyCode == 13) {
          $.get(
            url + '?' + name + '=' + value,
            function() { link.remove(); }
          )
        }
      });
    }

    $("a[data-confirm]").click(confirmHandler);
    $("a[data-action='edit']").click(makeEditable);
  }

  app = new App();

})(jQuery);

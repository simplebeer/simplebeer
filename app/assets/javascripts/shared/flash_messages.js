(function() {
  "use strict";

  $('.flash-alert i, .flash-notice i, #error_explanation i').click(function() {
    var flashElement = $(this).parent();
    flashElement.animate({
      height:        0,
      paddingBottom: 0,
      paddingTop:    0
    }, function() {
      flashElement.remove();
    });
    return false;
  });

})();

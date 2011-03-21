var fbready = false;
var docready = false;

window.fbAsyncInit = function() {
  fbready = true;
  if( docready ) {
    init();
  }
};

$(document).ready(function(){
  docready = true;
  if( fbready ) {
    init();
  }
});

function init() {
  FB.init({appId: fbAppId, status: true, cookie: true});
  FB.Canvas.setAutoResize();
  setTimeout( function(){
    FB.Canvas.setAutoResize(false);
  }, 2000 );

  $("#credits_test").click(function(){
    var obj = {
      method: 'pay',
      credits_purchase: true
    };
    FB.ui( obj, function(){
      
    });
    return false;
  });

  $("#other_test").click(function(){
    var obj = {
      method: 'pay',
      order_info: '12345',
      purchase_type: 'item'
    };
    FB.ui( obj, function(){

    });
    return false;
  });
}
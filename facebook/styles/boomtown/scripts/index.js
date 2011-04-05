var fbready = false;
var docready = false;

function fbReady() {
  fbready = true;
  if( docready ) {
    init();
  }
}

function docReady() {
  docready = true;
  if( fbready ) {
    init();
  }
}

var fbinitialized = false;
var refreshtoken = false;
function init() {
  FB.init({appId: fbAppId, status: true, cookie: true});
  fbinitialized = true;
  FB.Canvas.setAutoResize();
  setTimeout( function(){
    FB.Canvas.setAutoResize(false);
  }, 2000 );
  if( refreshtoken ) {
    refreshtoken = false;
    refreshToken();
  }
}

function refreshToken() {
  if( !fbinitialized ) {
    refreshtoken = true;
  } else {
    FB.getLoginStatus(function(response){
      if( response.session ) {
        swfobject.getObjectById( "gameflash" ).tokenRefreshed( response.session.access_token );
      } else {
        window.top.url = authURL;
      }
    });
  }
  return true;
}

function requestPermissions( perms ) {
  FB.login(function(response){
    var enabled = false;
    if( response.session && response.perms && response.perms === perms ) {
      enabled = true;
    }
    swfobject.getObjectById( "gameflash" ).enablePhotos( enabled );
  }, {perms:perms});
  return true;
}
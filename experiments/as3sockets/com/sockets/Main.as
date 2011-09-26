package com.sockets {
	import flash.display.Sprite;
	
  public class Main extends Sprite {
    
    public function Main() {
      
      trace( "Creating socket server!" );
      var socket:SocketClient = new SocketClient( "50.56.98.99", 10000 );
      
    }
    
  }

}
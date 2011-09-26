package com.sockets {
  import flash.events.Event;
  import flash.events.IOErrorEvent;
  import flash.events.ProgressEvent;
	import flash.net.Socket;
	
  public class SocketClient extends Socket {
    
    public function SocketClient( host:String = null, port:uint = 8200 ) {
      addEventListener( Event.CONNECT, onConnect );
      addEventListener( Event.CLOSE, onClose );
      addEventListener( IOErrorEvent.IO_ERROR, onError );
      addEventListener( ProgressEvent.SOCKET_DATA, onResponse );
      
      trace( "SocketClient created, connecting..." );
      
      super( host, port );    
      connect( host, port );
    }
    
    private function onConnect( e:Event ):void {
      trace( "Connected!" );
      
      this.writeUTFBytes( "Testing 1\n" );
      this.writeUTFBytes( "Testing 2\n" );
      this.writeUTFBytes( "Testing 3\n" );
      this.writeUTFBytes( "shutdown\n" );
    }
    
    private function onClose( e:Event ):void {
      trace( "Closed!" );
    }
    
    private function onError( e:IOErrorEvent ):void {
      trace( "Error!" );
    }
    
    private function onResponse( e:ProgressEvent ):void {
      var str:String = this.readUTFBytes( this.bytesAvailable );
      trace( "Response: " + str );
    }
    
  }

}
package com.kuro.kuroexpress {
  import flash.net.URLRequest;
  import flash.net.URLRequestHeader;
  import flash.net.URLRequestMethod;
  import flash.utils.ByteArray;
  import flash.utils.Endian;
	/**
   * ...
   * @author David Talley
   */
  public class PostGenerator {
    
    private static var _boundary:String = "";
    
    public static function getBoundary():String {
      if ( _boundary.length == 0 ) {
        for ( var i:int = 0; i < 32; i++ ) {
          _boundary += String.fromCharCode( int( 97 + Math.random() * 25 ) );
        }
      }
      return _boundary;
    }
    
    public static function getRequest( url:String, params:Object ):URLRequest {
      var postData:ByteArray = new ByteArray();
      postData.endian = Endian.BIG_ENDIAN;
      
      if ( params == null ) {
        params = { };
      }
      
      //Add all of the requested parameters
      for ( var name:String in params ) {
        if( params[name] ) {
          postData = addBoundary( postData );
          postData = addLineBreak( postData );        
          postData.writeMultiByte( "Content-Disposition: form-data; name=\"" + name + "\"", 'ascii' );
          if ( params[name] is PostGeneratorFile ) {
            if ( !params[name].filename || !params[name].file ) {
              trace( "Incomplete post file." );
            }
            postData.writeMultiByte( "; filename=\"" + params[name].filename + "\"", 'ascii' );          
            postData = addLineBreak( postData );
            postData.writeMultiByte( "Content-Type: application/octet-stream", 'ascii' );
            postData = addLineBreak( addLineBreak( postData ) );
            postData.writeBytes( params[name].file, 0, params[name].file.length );
          } else {
            postData = addLineBreak( addLineBreak( postData ) );
            postData.writeUTFBytes( params[name] );
          }
          postData = addLineBreak( postData );
        }
      }
      
      //Add final boundary
      postData = addBoundary( postData );
      postData = addDoubleDash( postData );
      
      var request:URLRequest = new URLRequest( url );
      request.contentType = "multipart/form-data; boundary=" + getBoundary();
      request.method = URLRequestMethod.POST;
      request.data = postData;
      
      return request;
    }
    
    public static function formatFile( filename:String, file:ByteArray ):Object {
      return new PostGeneratorFile( filename, file );
    }
    
    private static function addBoundary( p:ByteArray ):ByteArray {
      addDoubleDash( p );
      p.writeMultiByte( getBoundary(), 'ascii' );
      return p;
    }
    
    private static function addLineBreak( p:ByteArray ):ByteArray {
      p.writeMultiByte( "\r\n", 'ascii' );
      return p;
    }
    
    private static function addDoubleDash( p:ByteArray ):ByteArray {
      p.writeMultiByte( "--", 'ascii' );
      return p;
    }
    
  }

}

import flash.utils.ByteArray;
class PostGeneratorFile extends Object {
    
  private var _filename:String;
  private var _file:ByteArray;
  
  public function PostGeneratorFile( filename:String, file:ByteArray ):void {
    _filename = filename;
    _file = file;
  }
  
  public function get filename():String {
    return _filename;
  }
  
  public function get file():ByteArray {
    return _file;
  }
  
}
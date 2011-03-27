package com.boomtown.core {
  import flash.display.Bitmap;
  
  public class Rank {
    
    private var _association:String;
    private var _id:String;
    private var _title:String;
    private var _name:String;
    private var _level:uint;
    private var _image:Bitmap;
    
    private var _next:Rank;
    private var _previous:Rank;
    
    public function Rank( data:Object = null ):void {      
      update( data );
    }
    
    public function update( data:Object ):void {
      if ( data.association ) {
        _association = data.association;
      }
      if ( data.id ) {
        _id = data.id;
      }
      if ( data.title ) {
        _title = data.title;
      }
      if ( data.name ) {
        _name = data.name;
      }
      if ( data.level ) {
        _level = data.level;
      }
      if ( data.image ) {
        _image = data.image;
      }
      if ( data.next ) {
        _next = data.next; 
      }      
      if ( data.previous ) {
        _next = data.previous;
      }
    }
    
    public function get association():String {
      return _association;
    }
    
    public function get id():String {
      return _id;
    }
    
    public function get title():String {
      return _title;
    }
    
    public function get name():String {
      return _name;
    }
    
    public function get level():uint {
      return _level;
    }
    
    public function get image():Bitmap {
      return _image;
    }
    
    public function get next():Rank {
      return _next;
    }
    
    public function get previous():Rank {
      return _previous;
    }
    
  }
  
}
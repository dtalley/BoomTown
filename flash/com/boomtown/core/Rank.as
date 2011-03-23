package com.boomtown.core {
  
  public class Rank {
    
    private var _association:String;
    private var _id:String;
    private var _title:String;
    private var _name:String;
    private var _level:uint;
    
    private var _next:Rank;
    private var _previous:Rank;
    
    public function Rank( data:Object ):void {      
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
      if ( data.next ) {
        _next = data.next; 
      }      
      if ( data.previous ) {
        _next = data.previous;
      }
    }
    
  }
  
}
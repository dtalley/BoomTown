package com.boomtown.core {
  
  /**
   * ...
   * @author ...
   */
  public class CommandCenter {
    
    private var _association:String;
    private var _id:String;
    private var _title:String;
    private var _name:String;
    private var _description:String;
    private var _bandwidth:uint;
    
    public function CommandCenter( data:Object = null ):void {      
      if( data ) {
        update( data );
      }
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
      if ( data.description ) {
        _description = data.description;
      }
      if ( data.bandwidth ) {
        _bandwidth = data.bandwidth;
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
    
    public function get description():String {
      return _description;
    }
    
    public function get bandwidth():uint {
      return _bandwidth;
    }
    
  }
  
}
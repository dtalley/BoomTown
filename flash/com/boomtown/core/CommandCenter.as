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
    private var _bandwidth:uint;
    
    public function CommandCenter( data:Object ):void {      
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
      if ( data.bandwidth ) {
        _bandwidth = data.bandwidth;
      }
    }
    
  }
  
}
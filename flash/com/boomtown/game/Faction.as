package com.boomtown.game {
  
  /**
   * ...
   * @author ...
   */
  public class Faction {
    
    private var _association:String;
    private var _id:String;
    private var _title:String;
    private var _name:String;
    private var _description:String;
    private var _population:uint;
    private var _acronym:String;
    private var _maxDropships:uint;
    private var _currentDropships:uint;
    
    public function Faction( data:Object = null ):void {      
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
      if ( data.population ) {
        _population = data.population;
      }
      if ( data.acronym ) {
        _acronym = data.acronym;
      }
      if ( data.maxDropships ) {
        _maxDropships = data.maxDropships;
      }
      if ( data.currentDropships ) {
        _currentDropships = data.currentDropships;
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
    
    public function get population():uint {
      return _population;
    }
    
    public function get acronym():String {
      return _acronym;
    }
    
    public function get maxDropships():uint {
      return _maxDropships;
    }
    
    public function get currentDropships():uint {
      return _currentDropships;
    }
    
  }
  
}
package com.boomtown.core {
  
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
    
    public function Faction( data:Object ):void {      
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
    
  }
  
}
package com.boomtown.modules.worldmap.grid {	
  public class WorldGridNodeType {    
    public function WorldGridNodeType( lock:WorldGridNodeTypeLock ) {}
    
    private static var _undefined:WorldGridNodeType;
    public static function get UNDEFINED():WorldGridNodeType {
      if ( !_undefined ) {
        _undefined = new WorldGridNodeType( new WorldGridNodeTypeLock() );
      }
      return _undefined;
    }    
    private static var _active:WorldGridNodeType;
    public static function get ACTIVE():WorldGridNodeType {
      if ( !_active ) {
        _active = new WorldGridNodeType( new WorldGridNodeTypeLock() );
      }
      return _active;
    }    
    private static var _inactive:WorldGridNodeType;
    public static function get INACTIVE():WorldGridNodeType {
      if ( !_inactive ) {
        _inactive = new WorldGridNodeType( new WorldGridNodeTypeLock() );
      }
      return _inactive;
    }
  }
}
class WorldGridNodeTypeLock {}
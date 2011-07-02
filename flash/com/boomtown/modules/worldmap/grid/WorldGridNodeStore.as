package com.boomtown.modules.worldmap.grid {
	
  internal class WorldGridNodeStore {
    
    private var _status:uint;
    private var _faction:uint;
    
    public function WorldGridNodeStore( status:uint, faction:uint ) {
      _status = status;
      _faction = faction;
    }
    
    internal function get status():uint {
      return _status;
    }
    
    internal function get faction():uint {
      return _faction;
    }
    
    internal function get complete():Boolean {
      if ( _status && _faction ) {
        return true;
      }
      return false;
    }
    
  }

}
package com.boomtown.modules.battle.events {
  import flash.events.Event;
	/**
   * ...
   * @author David Talley
   */
  public class BattleGridEvent extends Event {
    
    public function BattleGridEvent( type:String ) {
      super( type );
    }
    
    public static const READY:String = "battle_grid_ready";    
    public static const POPULATED:String = "battle_grid_populated";
    
  }

}
package com.boomtown.modules.battle.events {
  import flash.events.Event;
	
  public class BattleGridNodeEvent extends Event {
    
    public function BattleGridNodeEvent( type:String ) {
      super( type );
    }
    
    public static const CLICKED:String = "battle_grid_node_clicked";    
    public static const OVER:String = "battle_grid_node_over";
    
  }

}
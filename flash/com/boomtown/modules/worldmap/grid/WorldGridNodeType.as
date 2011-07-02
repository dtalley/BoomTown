package com.boomtown.modules.worldmap.grid {	
  public class WorldGridNodeType {    
    public function WorldGridNodeType( lock:WorldGridNodeTypeLock ) {}
    
    public static const UNDEFINED:WorldGridNodeType = new WorldGridNodeType(new WorldGridNodeTypeLock());    
    public static const ACTIVE:WorldGridNodeType = new WorldGridNodeType(new WorldGridNodeTypeLock());
    public static const INACTIVE:WorldGridNodeType = new WorldGridNodeType(new WorldGridNodeTypeLock());
  }
}
class WorldGridNodeTypeLock{function WorldGridNodeTypeLock():void{}}
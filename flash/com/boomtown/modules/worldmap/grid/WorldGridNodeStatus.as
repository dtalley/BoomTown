package com.boomtown.modules.worldmap.grid {	
  public class WorldGridNodeStatus {    
    public function WorldGridNodeStatus( lock:WorldGridNodeStatusLock ) {}
    
    public static const LOCKED:WorldGridNodeStatus = new WorldGridNodeStatus(new WorldGridNodeStatusLock());    
    public static const OPEN:WorldGridNodeStatus = new WorldGridNodeStatus(new WorldGridNodeStatusLock());
    public static const DISPUTED:WorldGridNodeStatus = new WorldGridNodeStatus(new WorldGridNodeStatusLock());
  }
}
class WorldGridNodeStatusLock{function WorldGridNodeStatusLock():void{}}
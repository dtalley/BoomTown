package md.core {
  import flash.display.MovieClip;
  import flash.events.Event;
  
  public class Module extends MovieClip {
    
    protected var _id:String = "module";
    
    public function Module():void {
      
    }
    
    public function open():void {
      
    }
    
    public function close():void {
      var totalChildren:int = numChildren;
      for ( var i:int = 0; i < totalChildren; i++ ) {
        removeChildAt(0);
      }
      dispatchEvent( new Event( Event.CLOSE ) );
    }
    
    public function get id():String {
      return _id;
    }
    
  }
  
}
package com.boomtown.core {
  import com.kuro.kuroexpress.KuroExpress;
  import com.kuro.kuroexpress.XMLManager;
  import com.magasi.events.MagasiErrorEvent;
  import com.magasi.events.MagasiRequestEvent;
  import com.magasi.util.ActionRequest;
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.events.EventDispatcher;
  import flash.net.URLLoader;
  import flash.net.URLRequest;
  import flash.net.URLVariables;
  
  /**
   * ...
   * @author ...
   */
  public class Commander extends EventDispatcher {
    
    private var _complete:Boolean = true;
    
    private var _id:String;
    private var _name:String;
    private var _experience:uint;
    private var _balance:uint;
    
    private var _faction:Faction;
    private var _rank:Rank;
    private var _commandCenter:CommandCenter;
    
    public function Commander():void {
      
    }
    
    public function init( user_id:String ):void {
      var commander:Sprite = ActionRequest.sendRequest( "commanders", "get_commander", { user_id:user_id } );
      commander.addEventListener( MagasiRequestEvent.MAGASI_REQUEST, commanderLoaded );
      commander.addEventListener( MagasiErrorEvent.USER_ERROR, userError );
    }
    
    private function userError( e:MagasiErrorEvent ):void {
      if ( e.object == "commanders" && e.func == "get_commander" ) {
        KuroExpress.broadcast( this, "An error occured trying to retrieve the commander for this user.\n\n" + e.title + "\n" + e.body, 0xFF0000 );
        _complete = false;
      }
    }
    
    private function commanderLoaded( e:MagasiRequestEvent ):void {      
      if ( e.data.commanders.commander.length() == 0 ) {
        _complete = false;
      }
      if ( _complete ) {
        KuroExpress.broadcast( this, "The commander's information was successfully loaded.", 0x00FF00 );
        
        var factionXML:XMLList = e.data.commanders.commander.faction;
        if( factionXML ) {
          _faction = new Faction( {
            association: factionXML.association.toString(),
            id: factionXML.id.toString(),
            title: factionXML.title.toString(),
            name: factionXML.name.toString(),
            description: factionXML.description.toString(),
            population: uint( factionXML.population.toString() ),
            acronym: factionXML.acronym.toString(), 
            maxDropships: uint( factionXML.dropships.max.toString() ),
            currentDropships: uint( factionXML.dropships.current.toString() )
          } );
        } else {
          _complete = false;
        }
        
        var baseXML:XMLList = e.data.commanders.commander.base;
        if( baseXML ) {
          _commandCenter = new CommandCenter( {
            association: baseXML.association.toString(),
            id: baseXML.id.toString(),
            title: baseXML.title.toString(),
            name: baseXML.name.toString(),
            bandwidth: uint( baseXML.bandwidth.toString() )
          } );
        } else {
          _complete = false;
        }
        
        var rankXML:XMLList = e.data.commanders.commander.rank;
        if( rankXML ) {
          var rank:Object = {
            association: rankXML.association.toString(),
            id: rankXML.id.toString(),
            title: rankXML.title.toString(),
            name: rankXML.name.toString(),
            level: uint( baseXML.level.toString() )
          };
          if ( rankXML.next ) {
            var next:Object = {
              id: rankXML.next.id.toString(),
              title: rankXML.next.title.toString(),
              name: rankXML.next.name.toString(),
              level: uint( rankXML.next.level.toString() )
            }
            rank.next = new Rank( next );
          }
          if ( rankXML.previous ) {
            var previous:Object = {
              id: rankXML.previous.id.toString(),
              title: rankXML.previous.title.toString(),
              name: rankXML.previous.name.toString(),
              level: uint( rankXML.previous.level.toString() )
            }
            rank.previous = new Rank( previous );
          }
          _rank = new Rank( rank );
        } else {
          _complete = false;
        }
        
        _id = e.data.commanders.commander.id.toString();
        _name = e.data.commanders.commander.name.toString();
        _experience = uint( e.data.commanders.commander.experience.toString() );
        _balance = uint( e.data.commanders.commander.balance.toString() );
      }
      
      dispatchEvent( new Event( Event.COMPLETE ) );
    }
    
    public function get id():String {
      return _id;
    }
    
    public function get name():String {
      return _name;
    }
    
    public function get experience():uint {
      return _experience;
    }
    
    public function get balance():uint {
      return _balance;
    }
    
    public function get faction():Faction {
      return _faction;
    }
    
    public function get commandCenter():CommandCenter {
      return _commandCenter;
    }
    
    public function get rank():Rank {
      return _rank;
    }
    
    public function get complete():Boolean {
      return _complete;
    }
    
  }
  
}
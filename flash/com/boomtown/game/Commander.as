package com.boomtown.game {
  import com.adobe.images.JPGEncoder;
  import com.boomtown.events.CommanderEvent;
  import com.boomtown.events.PromptEvent;
  import com.boomtown.prompts.ChoicePrompt;
  import com.boomtown.prompts.PromptManager;
  import com.boomtown.prompts.SimplePrompt;
  import com.kuro.kuroexpress.KuroExpress;
  import com.kuro.kuroexpress.PostGenerator;
  import com.kuro.kuroexpress.XMLManager;
  import com.magasi.events.MagasiActionEvent;
  import com.magasi.events.MagasiErrorEvent;
  import com.magasi.events.MagasiRequestEvent;
  import com.magasi.util.ActionRequest;
  import flash.display.Bitmap;
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.events.EventDispatcher;
  import flash.events.ProgressEvent;
  import flash.external.ExternalInterface;
  import flash.net.URLLoader;
  import flash.net.URLRequest;
  import flash.net.URLVariables;
  import flash.system.JPEGLoaderContext;
  import flash.utils.ByteArray;
  
  public class Commander extends EventDispatcher {
    
    private var _complete:Boolean = true;
    private var _initialized:Boolean = false;
    
    private var _id:String;
    private var _uid:String;
    private var _name:String;
    private var _experience:uint;
    private var _balance:uint;
    private var _token:String;
    
    private var _faction:Faction;
    private var _rank:Rank;
    private var _commandCenter:CommandCenter;
    
    private var _image:Bitmap;
    private var _imageData:ByteArray;
    
    public function Commander( token:String ):void {
      _token = token;
    }
    
    public function init( user_id:String ):void {
      if( user_id ) {
        _uid = user_id;
      }
      if ( !_token ) {
        refreshToken();
      } else {
        _initialized = true;
        var commander:Sprite = ActionRequest.sendRequest( { commanders_action:"get_commander", user_id:_uid } );
        commander.addEventListener( MagasiRequestEvent.MAGASI_REQUEST, commanderLoaded );
        commander.addEventListener( MagasiErrorEvent.USER_ERROR, userError );
      }
    }
    
    private function userError( e:MagasiErrorEvent ):void {
      if ( e.object == "commanders" && e.func == "get_commander" ) {
        KuroExpress.broadcast( "An error occured trying to retrieve the commander for this user.\n\n" + e.title + "\n" + e.body, 
          { obj:this, label:"Commander::userError()", color:0xFF0000 } );
        _complete = false;
      }
    }
    
    private function commanderLoaded( e:MagasiRequestEvent ):void {      
      if ( e.data.commanders.commander.length() == 0 ) {
        _complete = false;
      }
      if ( _complete ) {
        KuroExpress.broadcast( "The commander's information was successfully loaded.", 
          { obj:this, label:"Commander::commanderLoaded()", color:0x00FF00 } );
        
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
          KuroExpress.broadcast( "No faction was found for the commander.", 
            { obj:this, label:"Commander::commanderLoaded()" } );
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
          KuroExpress.broadcast( "No base was found for the commander.", 
            { obj:this, label:"Commander::commanderLoaded()" } );
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
          KuroExpress.broadcast( "No base was found for the commander.", 
            { obj:this, label:"Commander::commanderLoaded()" } );
          _complete = false;
        }
        
        if ( 
          e.data.commanders.commander.id &&
          e.data.commanders.commander.name &&
          e.data.commanders.commander.experience &&
          e.data.commanders.commander.balance
        ) {
          _id = e.data.commanders.commander.id.toString();
          _name = e.data.commanders.commander.name.toString();
          _experience = uint( e.data.commanders.commander.experience.toString() );
          _balance = uint( e.data.commanders.commander.balance.toString() );
        } else {
          KuroExpress.broadcast( "Not all of the information was provided for the commander", 
            { obj:this, label:"Commander::commanderLoaded()" } );
          _complete = false;
        }
      }
      
      dispatchEvent( new Event( Event.COMPLETE ) );
    }
    
    private var tokenRefreshEnabled:Boolean = false;
    public function refreshToken():void {
      if ( !tokenRefreshEnabled ) {
        tokenRefreshEnabled = true;
        ExternalInterface.addCallback( "tokenRefreshed", tokenRefreshed );
      }
      if ( ExternalInterface.call( "refreshToken" ) == null ) {
        _token = XMLManager.getFile("settings").default_token.toString();
        if( !_initialized ) {
          init(null);
        }
        KuroExpress.broadcast( "No external interface available.", 
          { obj:this, label:"Commander::refreshToken()" } );
      } else {
        KuroExpress.broadcast( "Refreshing the current commander's token.", 
          { obj:this, label:"Commander::refreshToken()" } );
      }
    }
    
    private function tokenRefreshed( token:String ):void {
      _token = token;
      if( !_initialized ) {
        init(null);
      }
      dispatchEvent( new CommanderEvent( CommanderEvent.TOKEN_REFRESHED ) );
      KuroExpress.broadcast( "The current commander's token has been refreshed to:\n" + _token, 
        { obj:this, label:"Commander::tokenRefreshed()" } );
    }
    
    public function verify():Boolean {
      if ( !_uid ) {
        KuroExpress.broadcast( "No user id saved.", 
          { obj:this, label:"Commander::verify()", color:0xFF0000 } );
        return false;
      } else if ( !_token ) {
        KuroExpress.broadcast( "No access token saved.", 
          { obj:this, label:"Commander::verify()", color:0xFF0000 } );
        return false;
      } else if ( !_imageData ) {
        KuroExpress.broadcast( "No image data saved.", 
          { obj:this, label:"Commander::verify()", color:0xFF0000 } );
        return false;
      } else if ( !_faction ) {
        KuroExpress.broadcast( "No faction saved.", 
          { obj:this, label:"Commander::verify()", color:0xFF0000 } );
        return false;
      } else if ( !_commandCenter ) {
        KuroExpress.broadcast( "No command center saved.", 
          { obj:this, label:"Commander::verify()", color:0xFF0000 } );
        return false;
      } else if ( !_name ) {
        KuroExpress.broadcast( "No name saved.", 
          { obj:this, label:"Commander::verify()", color:0xFF0000 } );
        return false;
      }
      return true;
    }
    
    public function save():void {
      PromptManager.issuePrompt( "saveCommander", new ChoicePrompt( "Are you sure this is the commander you want to create?", "YES", "NO" ) );
      PromptManager.addEventListener( PromptEvent.PROMPT_ACCEPTED, submit );
    }
    
    private function submit( e:PromptEvent ):void {
      PromptManager.removeEventListener( PromptEvent.PROMPT_ACCEPTED, submit );
      KuroExpress.broadcast( "Commander::save(): Sending data to server.", 
        { obj:this, label:"Commander::submit()" } );
      var loader:Sprite = ActionRequest.sendRequest( {
        commanders_action: "save_commander",
        user_id: _uid,
        access_token: _token,
        commander_image: PostGenerator.formatFile( _uid + ".jpg", _imageData ),
        faction_id: _faction.id,
        base_id: _commandCenter.id,
        commander_name: _name
      });
      KuroExpress.addFullListener( loader, MagasiErrorEvent.SYSTEM_ERROR, error, loader );
      KuroExpress.addFullListener( loader, MagasiErrorEvent.USER_ERROR, error, loader );
      KuroExpress.addFullListener( loader, MagasiActionEvent.MAGASI_ACTION, saved, loader );
    }
    
    private function error( loader:Sprite, e:MagasiErrorEvent ):void {
      KuroExpress.removeListener( loader, MagasiErrorEvent.SYSTEM_ERROR, error );
      KuroExpress.removeListener( loader, MagasiErrorEvent.USER_ERROR, error );
      KuroExpress.removeListener( loader, MagasiActionEvent.MAGASI_ACTION, saved );
      KuroExpress.broadcast( "There was a problem saving the commander.\n\n" + e.title + "\n" + e.body, 
        { obj:this, label:"Commander::error()", color:0xFF0000 } );
    }
    
    private function saved( loader:Sprite, e:MagasiActionEvent ):void {
      KuroExpress.removeListener( loader, MagasiErrorEvent.SYSTEM_ERROR, error );
      KuroExpress.removeListener( loader, MagasiErrorEvent.USER_ERROR, error );
      KuroExpress.removeListener( loader, MagasiActionEvent.MAGASI_ACTION, saved );
      if ( e.extension == "commanders" && e.action == "save_commander" && e.success ) {
        dispatchEvent( new CommanderEvent( CommanderEvent.COMMANDER_SAVED ) );
      }
    }
    
    public function get id():String {
      return _id;
    }
    
    public function get uid():String {
      return _uid;
    }
    
    public function get name():String {
      return _name;
    }
    
    public function set name( val:String ):void {
      _name = val;
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
    
    public function set faction( val:Faction ):void {
      _faction = val;
    }
    
    public function get commandCenter():CommandCenter {
      return _commandCenter;
    }
    
    public function set commandCenter( val:CommandCenter ):void {
      _commandCenter = val;
    }
    
    public function get rank():Rank {
      return _rank;
    }
    
    public function set rank( val:Rank ):void {
      _rank = val;
    }
    
    public function get complete():Boolean {
      return _complete;
    }
    
    public function get token():String {
      return _token;
    }
    
    public function get image():Bitmap {
      return _image;
    }
    
    public function set image( val:Bitmap ):void {
      _image = val;
    }
    
    public function get imageData():ByteArray {
      return _imageData;
    }
    
    public function set imageData( val:ByteArray ):void {
      _imageData = val;
    }
    
  }
  
}
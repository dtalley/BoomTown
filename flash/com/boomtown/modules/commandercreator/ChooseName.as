package com.boomtown.modules.commandercreator {
  import com.adobe.images.JPGEncoder;
  import com.adobe.serialization.json.JSON;
  import com.boomtown.core.Commander;
  import com.boomtown.events.CommanderEvent;
  import com.boomtown.gui.StandardButton;
  import com.boomtown.loader.GraphicLoader;
  import com.boomtown.modules.commandercreator.events.CreatorScreenEvent;
  import com.boomtown.modules.commandercreator.events.PhotoBrowserEvent;
  import com.kuro.kuroexpress.PostGenerator;
  import com.kuro.kuroexpress.PrecisionTextField;
  import com.kuro.kuroexpress.KuroExpress;
  import com.kuro.kuroexpress.XMLManager;
  import com.magasi.events.MagasiActionEvent;
  import com.magasi.events.MagasiRequestEvent;
  import com.magasi.util.ActionRequest;
  import flash.display.Bitmap;
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.events.IOErrorEvent;
  import flash.events.MouseEvent;
  import flash.external.ExternalInterface;
  import flash.net.FileFilter;
  import flash.net.FileReference;
  import flash.net.URLLoader;
  import flash.net.URLRequest;
  import flash.text.TextField;
  
  public class ChooseName extends CreatorScreen {
    
    public function ChooseName( commander:Commander ):void {     
      super( commander );
    }
    
    private var _title:TextField;
    private var _card:Sprite;
    private var _name:PrecisionTextField;
    private var _nameHolder:Sprite;
    private var _gallery:PhotoBrowser;
    private var _editor:PhotoEditor;
    
    private var _photosButton:StandardButton;
    private var _uploadButton:StandardButton;
    private var _save:StandardButton;
    
    private var _thumbHeight:Number = 180;
    
    override public function open():void {
      _title = KuroExpress.createTextField( { font:"BorisBlackBloxx", size:22, color:0xFFFFFF } );
      _title.text = "STEP 3: COMMANDER PROFILE";
      addChild( _title );
      _title.x = 50;
      _title.y = 50;
      
      _card = new Sprite();
      _editor = new PhotoEditor( 250, 250 );
      _card.addChild( _editor );
      addChild( _card );
      _card.x = _title.x;
      _card.y = Math.round( _title.y + _title.height + 20 );
      
      if ( _commander.image ) {
        _editor.load( _commander.image );
      }
      
      _nameHolder = new Sprite();
      _name = new PrecisionTextField( { font:"BorisBlackBloxx", size:26, color:0x000000, restrict:"a-zA-Z0-9_\\-" } );
      _name.applyInput( 300 );
      var namebg:Sprite = new Sprite();
      namebg.graphics.beginFill( 0xFFFFFF );
      _name.text = "XXXXX";
      namebg.graphics.drawRect( 0, 0, _name.width + 10, _name.height + 10 );
      _name.text = "";
      var namelabel:TextField = KuroExpress.createTextField( { font:"BorisBlackBloxx", size:14, color:0xFFFFFF } );
      namelabel.text = "Commander Name";
      var namedesc:TextField = KuroExpress.createTextField( { font:"BorisBlackBloxx", size:10, color:0xFFFFFF, width:namebg.width, wordWrap:true } );
      namedesc.text = "Must be at least 3 characters, and can only contain letters, numbers, underscores, and dashes.";
      _nameHolder.addChild( namebg );
      _nameHolder.addChild( _name );
      _nameHolder.addChild( namelabel );
      _nameHolder.addChild( namedesc );
      namebg.y = namelabel.height;
      _name.x = namebg.x + 5;
      _name.y = namebg.y + 5;
      namedesc.y = namebg.y + namebg.height;
      addChild( _nameHolder );
      _nameHolder.x = _card.x + _card.width + 20;
      _nameHolder.y = _card.y;
      _name.addEventListener( Event.CHANGE, nameChanged );
      
      if ( _commander.name ) {
        _name.text = _commander.name;
      }
      
      _photosButton = new StandardButton( "Use a Photo From Facebook" );
      addChild( _photosButton );
      _photosButton.x = _card.x + _card.width + 10;
      _photosButton.y = _card.y + _card.height - _photosButton.height;
      _uploadButton = new StandardButton( "Upload a Picture" );
      addChild( _uploadButton );
      _uploadButton.x = _photosButton.x + _photosButton.width + 20;
      _uploadButton.y = _photosButton.y;
      
      _photosButton.addEventListener( MouseEvent.CLICK, useFacebookPhoto );
      _uploadButton.addEventListener( MouseEvent.CLICK, uploadPhoto );
      
      _save = new StandardButton( "Confirm" );
      addChild( _save );
      _save.x = stage.stageWidth - _save.width - 50;
      _save.y = stage.stageHeight - _save.height - 20;
      _save.addEventListener( MouseEvent.CLICK, saveCommander );
      
      if ( _commander.name && _commander.image ) {
        _saved = true;
      }
    }
    
    private function saveCommander( e:MouseEvent ):void {
      dispatchEvent( new CreatorScreenEvent( CreatorScreenEvent.SAVE_COMMANDER ) );
    }
    
    private function nameChanged( e:Event ):void {
      _saved = false;
    }
    
    private function uploadPhoto( e:MouseEvent ):void {
      var file:FileReference = new FileReference();
      file.browse( [new FileFilter("Image Files (JPG, GIF, or PNG)", "*.jpg;*.gif;*.png" )] );
      KuroExpress.addListener( file, Event.SELECT, fileSelected, file );
    }
    
    private function fileSelected( file:FileReference ):void {
      if( file.size < 250000 ) {
        KuroExpress.removeListener( file, Event.SELECT, fileSelected );
        file.load();
        KuroExpress.addListener( file, Event.COMPLETE, fileLoaded, file );
      } else {
        KuroExpress.broadcast( this, "Chosen file is too large.  Must be 250Kb or less.", 0xFF0000 );
      }
    }
    
    private function fileLoaded( file:FileReference ):void {
      KuroExpress.removeListener( file, Event.COMPLETE, fileLoaded );
      var request:Sprite = ActionRequest.sendRequest( {
        commanders_action: "upload_image",
        user_id: _commander.uid,
        commander_image: PostGenerator.formatFile( _commander.uid + "_" + file.name, file.data )
      });
      request.addEventListener( MagasiActionEvent.MAGASI_ACTION, fileUploaded );
    }
    
    private function fileUploaded( e:MagasiActionEvent ):void {
      if( e.extension == "commanders" && e.action == "upload_image" ) {
        e.target.removeEventListener( MagasiActionEvent.MAGASI_ACTION, fileUploaded );
        _editor.load( XMLManager.getFile("settings").site_path + "uploads/temp_images/" + e.extra.filename.toString() );
        _saved = false;
      }
    }
    
    private var facebookPhotoEnabled:Boolean = false;
    private function useFacebookPhoto( e:MouseEvent ):void {
      _photosButton.disable();
      if ( !facebookPhotoEnabled ) {
        facebookPhotoEnabled = true;
        ExternalInterface.addCallback( "enablePhotos", enablePhotos );
      }
      if ( ExternalInterface.call( "requestPermissions", "user_photos" ) == null ) {
        enablePhotos(true);
      }
    }
    
    private function enablePhotos( enabled:Boolean ):void {
      if ( enabled ) {        
        var loadingText:TextField = KuroExpress.createTextField( { font:"BorisBlackBloxx", size:24, color:0xFFFFFF } );
        loadingText.text = "Examining albums...";
        addChild( loadingText );
        loadingText.x = _card.x;
        loadingText.y = _card.y + _card.height + 20;
        
        KuroExpress.addListener( _commander, CommanderEvent.TOKEN_REFRESHED, tokenReady, loadingText );
        _commander.refreshToken();
      }
    }
    
    private function tokenReady( ltext:TextField ):void {
      KuroExpress.removeListener( _commander, CommanderEvent.TOKEN_REFRESHED, tokenReady );
      
      var request:URLRequest = new URLRequest( "https://graph.facebook.com/me/albums?access_token=" + _commander.token );
      var loader:URLLoader = new URLLoader();
      KuroExpress.addListener( loader, Event.COMPLETE, albumsLoaded, loader, ltext );
      KuroExpress.addListener( loader, IOErrorEvent.IO_ERROR, albumsError, loader, ltext );
      loader.load( request );
    }
    
    private function albumsError( loader:URLLoader, ltext:TextField ):void {
      KuroExpress.removeListener( loader, Event.COMPLETE, albumsLoaded );
      KuroExpress.removeListener( loader, IOErrorEvent.IO_ERROR, albumsError );
      KuroExpress.broadcast( this, "ChooseName::albumsError(): There was an error loading the user's albums.", 0xFF0000 );
      ltext.text = "Error loading albums";
      _photosButton.enable();
    }
    
    private function albumsLoaded( loader:URLLoader, ltext:TextField ):void {
      KuroExpress.removeListener( loader, Event.COMPLETE, albumsLoaded );
      KuroExpress.removeListener( loader, IOErrorEvent.IO_ERROR, albumsError );
      
      removeChild( _photosButton );
      
      var data:Object = JSON.decode( loader.data );
      var total:int = data.data.length;
      var id:String = null;
      KuroExpress.broadcast( this, "ChooseName::albumsLoaded(): Found " + total + " photos from which to choose." );
      for ( var i:int = 0; i < total; i++ ) {
        if ( data.data[i].type == "profile" ) {
          id = data.data[i].id;
        }
      }
      if ( id ) {
        createGallery( id, ltext );
        ltext.text = "Loading images...";
      } else {
        ltext.text = "No albums found.  Upload an image.";
      }
    }
    
    private function createGallery( id:String, ltext:TextField ):void {
      KuroExpress.broadcast( this, "ChooseName::createGallery(): Creating the photo browser now." );
      _gallery = new PhotoBrowser( id, _commander.token, stage.stageWidth, 140 );
      KuroExpress.addListener( _gallery, Event.COMPLETE, galleryLoaded, ltext );
    }
    
    private function galleryLoaded( ltext:TextField ):void {
      KuroExpress.broadcast( this, "ChooseName::galleryLoaded(): Photo browser has successfully loaded the photo list." );
      KuroExpress.removeListener( _gallery, Event.COMPLETE, galleryLoaded );
      removeChild( ltext );
      addChild( _gallery );
      _gallery.y = _card.y + _editor.height + 20;
      _gallery.addEventListener( PhotoBrowserEvent.PHOTO_CLICKED, photoClicked );
    }
    
    private function photoClicked( e:PhotoBrowserEvent ):void {
      _saved = false;
      _editor.load( e.photo );
    }
    
    override public function verify():Boolean {
      if ( !_name.text || _name.text.length < 3 || !_editor.photo ) {
        if ( !_name.text ) {
          KuroExpress.broadcast( this, "ChooseName::verify(): Name field is blank", 0xFF0000 );
        } else if ( _name.text.length < 3 ) {
          KuroExpress.broadcast( this, "ChooseName::verify(): Name field is too short", 0xFF0000 );
        } else if ( !_editor.photo ) {
          KuroExpress.broadcast( this, "ChooseName::verify(): No image provided", 0xFF0000 );
        }
        return false;
      }
      return true;
    }
    
    override public function save():void {
      if( _name.text ) {
        _commander.name = _name.text;
      }
      if( _editor.photo ) {
        _commander.image = _editor.photo;
      }
      var encoder:JPGEncoder = new JPGEncoder(80);
      encoder.addEventListener( Event.COMPLETE, imageEncoded );
      encoder.encode( _commander.image.bitmapData );
    }
    
    private function imageEncoded( e:Event ):void {
      e.target.removeEventListener( Event.COMPLETE, imageEncoded );
      _commander.imageData = JPGEncoder( e.target ).imageData;
      super.save();
    }
    
    override public function close():void {
      if ( _gallery ) {
        _gallery.destroy();
        _gallery.removeEventListener( PhotoBrowserEvent.PHOTO_CLICKED, photoClicked );
      }
      if ( _editor ) {
        _editor.destroy();
      }
      _name.removeEventListener( Event.CHANGE, nameChanged );
      _save.removeEventListener( MouseEvent.CLICK, saveCommander );
      _photosButton.removeEventListener( MouseEvent.CLICK, useFacebookPhoto );
      _uploadButton.removeEventListener( MouseEvent.CLICK, uploadPhoto );
      super.close();
      closed();
    }
    
  }
  
}
package com.boomtown.modules.commandercreator {
  import com.boomtown.core.CommandCenter;
  import com.boomtown.core.Commander;
  import com.kuro.kuroexpress.KuroExpress;
  import com.kuro.kuroexpress.XMLManager;
  import com.magasi.events.MagasiRequestEvent;
  import com.magasi.util.ActionRequest;
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.text.TextField;
  
  public class ChooseCommandCenter extends CreatorScreen {
    
    public function ChooseCommandCenter( commander:Commander ):void {      
      super( commander );
    }
    
    private var _title:TextField;
    
    private var _commandCenters:Object;
    
    override public function open():void {
      _title = KuroExpress.createTextField( { font:"BorisBlackBloxx", size:22, color:0xFFFFFF } );
      _title.text = "STEP 2: HEADQUARTERS ASSIGNMENT";
      addChild( _title );
      _title.x = 50;
      _title.y = 50;
      
      _commandCenters = XMLManager.getFile("commandCenters");
      if ( _commandCenters ) {
        createSelection();
      } else {
        var loader:Sprite = ActionRequest.sendRequest( {
          bases_action: "list_bases"
        });
        KuroExpress.addFullListener( loader, MagasiRequestEvent.MAGASI_REQUEST, commandCentersLoaded, loader );
      }
    }
    
    private function commandCentersLoaded( loader:Sprite, e:MagasiRequestEvent ):void {
      KuroExpress.removeListener( loader, MagasiRequestEvent.MAGASI_REQUEST, commandCentersLoaded );
      XMLManager.addFile( "commandCenters", e.data.bases.base_list );
      _commandCenters = XMLManager.getFile("commandCenters");      
      createSelection();
    }
    
    private var _selections:Array;
    private var _selected:CommandCenterChoice;
    private function createSelection():void {
      _selections = [];
      var total:uint = _commandCenters.base.length();
      for ( var i:int = 0; i < total; i++ ) {
        var data:XML = _commandCenters.base[i];
        var commandCenter:CommandCenter = new CommandCenter();
        commandCenter.update( { id: data.id.toString() } );
        commandCenter.update( { title: data.title.toString() } );
        commandCenter.update( { name: data.name.toString() } );
        commandCenter.update( { description: data.description.toString() } );
        
        var selection:CommandCenterChoice = new CommandCenterChoice( commandCenter, 320, 400 );
        addChild( selection );
        if ( i > 0 ) {
          selection.x = _selections[i - 1].x + _selections[i - 1].width + 20;
        } else {
          selection.x = 20;
        }
        selection.y = _title.y + _title.height + 20;
        _selections.push( selection );
        
        KuroExpress.addListener( selection, Event.SELECT, commandCenterSelected, selection );
        
        if ( _commander.commandCenter && commandCenter.id == _commander.commandCenter.id ) {
          _selected = selection;
          _selected.select();
          _saved = true;
        }
      }
    }
    
    private function commandCenterSelected( faction:CommandCenterChoice ):void {
      if ( _selected ) {
        _selected.deselect();
      }
      _selected = faction;
      _selected.select();
      _saved = false;
    }
    
    override public function verify():Boolean {
      if ( !_selected ) {
        KuroExpress.broadcast( this, "ChooseCommandCenter::verify(): No selection made.", 0xFF0000 );
        return false;
      }
      return true;
    }
    
    override public function save():void {
      if( _selected ) {
        _commander.commandCenter = _selected.commandCenter;
      }
      super.save();
    }
    
    override public function close():void {
      var total:uint = _selections.length;
      for ( var i:int = 0; i < total; i++ ) {
        KuroExpress.removeListener( _selections[i], Event.SELECT, commandCenterSelected );
      }
      super.close();
      closed();
    }
    
  }
  
}

import com.boomtown.core.CommandCenter;
import com.boomtown.gui.StandardButton;
import com.kuro.kuroexpress.KuroExpress;
import com.kuro.kuroexpress.XMLManager;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFormatAlign;

class CommandCenterChoice extends Sprite {
  
  private var _commandCenter:CommandCenter;
  private var _width:Number;
  private var _height:Number;
  
  private var _title:TextField;
  private var _description:TextField;
  private var _select:StandardButton;
  
  public function CommandCenterChoice( commandCenter:CommandCenter, width:Number, height:Number ):void {
    _commandCenter = commandCenter;
    _width = width;
    _height = height;
    
    addEventListener( Event.ADDED_TO_STAGE, init );
  }
  
  private function init( e:Event ):void {
    removeEventListener( Event.ADDED_TO_STAGE, init );    
    draw();
    
    _title = KuroExpress.createTextField( { font:"BorisBlackBloxx", size:16, color:0xFFFFFF, width:_width - 40, wordWrap:true, align:TextFormatAlign.CENTER } );
    _title.text = _commandCenter.title;
    addChild( _title );
    _title.x = 20;
    _title.y = 20;
    
    _description = KuroExpress.createTextField( { font:"BorisBlackBloxx", size:10, color:0xFFFFFF, width:_width - 40, wordWrap:true } );
    _description.text = _commandCenter.description;
    addChild( _description );
    _description.x = 20;
    _description.y = _title.y + _title.height + 40;
    
    _select = new StandardButton( "SELECT", { 
      width: _width - 40,
      height: 50
    } );
    addChild( _select );
    _select.x = _width / 2 - _select.width / 2;
    _select.y = _height - _select.height - 20;
    _select.addEventListener( MouseEvent.CLICK, selectClicked );
  }
  
  private function selectClicked( e:MouseEvent ):void {
    dispatchEvent( new Event( Event.SELECT ) );
  }
  
  private function draw( selected:Boolean = false ):void {
    var dark:uint = 0x0044AA;
    var medium:uint = 0x0088FF;
    
    graphics.clear();
    graphics.beginFill( selected ? medium : dark );
    graphics.drawRect( 0, 0, _width, _height );
    graphics.endFill();
    if ( selected ) {
      graphics.beginFill( dark );
      graphics.drawRect( 5, 5, _width - 10, _height - 10 );
      graphics.endFill();
    }
  }
  
  public function select():void {
    draw(true);
    _select.disable();
  }
  
  public function deselect():void {
    draw();
    _select.enable();
  }
  
  override public function get width():Number {
    return _width;
  }
  
  override public function get height():Number {
    return _height;
  }
  
  public function get commandCenter():CommandCenter {
    return _commandCenter;
  }
  
}
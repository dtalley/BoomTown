package com.boomtown.modules.commandercreator {
  import com.boomtown.core.Commander;
  import com.boomtown.core.Faction;
  import com.kuro.kuroexpress.KuroExpress;
  import com.kuro.kuroexpress.text.FontMapper;
  import com.kuro.kuroexpress.XMLManager;
  import com.magasi.events.MagasiRequestEvent;
  import com.magasi.util.ActionRequest;
  import flash.display.Sprite;
  import flash.events.Event;
  import flash.net.URLRequest;
  import flash.text.TextField;
  
  public class ChooseFaction extends CreatorScreen {
    
    public function ChooseFaction( commander:Commander ):void {      
      super( commander );
    }
    
    private var _title:TextField;
    
    private var _factions:Object;
    
    override public function open():void {
      _title = KuroExpress.createTextField( { font:FontMapper.font("mainFont"), size:22, color:0xFFFFFF } );
      _title.text = "STEP 1: FACTION ALLEGIANCE";
      addChild( _title );
      _title.x = 50;
      _title.y = 50;
      
      _factions = XMLManager.getFile("factions");
      if ( _factions ) {
        createSelection();
      } else {
        var loader:Sprite = ActionRequest.sendRequest( {
          factions_action: "list_factions"
        });
        KuroExpress.addFullListener( loader, MagasiRequestEvent.MAGASI_REQUEST, factionsLoaded, loader );
      }
    }
    
    private function factionsLoaded( loader:Sprite, e:MagasiRequestEvent ):void {
      KuroExpress.removeListener( loader, MagasiRequestEvent.MAGASI_REQUEST, factionsLoaded );
      XMLManager.addFile( "factions", e.data.factions.faction_list );
      _factions = XMLManager.getFile("factions");      
      createSelection();
    }
    
    private var _selections:Array;
    private var _selected:FactionChoice;
    private function createSelection():void {
      _selections = [];
      var total:uint = _factions.faction.length();
      for ( var i:int = 0; i < total; i++ ) {
        var data:XML = _factions.faction[i];
        var faction:Faction = new Faction();
        faction.update( { id: data.id.toString() } );
        faction.update( { title: data.title.toString() } );
        faction.update( { name: data.name.toString() } );
        faction.update( { description: data.description.toString() } );
        faction.update( { acronym: data.acronym.toString() } );
        faction.update( { population: uint( data.population.toString() ) } );
        
        var selection:FactionChoice = new FactionChoice( faction, 220, 400 );
        addChild( selection );
        if ( i > 0 ) {
          selection.x = _selections[i - 1].x + _selections[i - 1].width + 20;
        } else {
          selection.x = 20;
        }
        selection.y = _title.y + _title.height + 20;
        _selections.push( selection );
        
        KuroExpress.addListener( selection, Event.SELECT, factionSelected, selection );
        
        if ( _commander.faction && faction.id == _commander.faction.id ) {
          _selected = selection;
          _selected.select();
          _saved = true;
        }
      }
    }
    
    private function factionSelected( faction:FactionChoice ):void {
      if ( _selected ) {
        _selected.deselect();
      }
      _selected = faction;
      _selected.select();
      _saved = false;
    }
    
    override public function verify():Boolean {
      if ( !_selected ) {
        KuroExpress.broadcast( "No selection made.", 
          { obj:this, label:"ChooseFaction::verify()", color:0xFF0000 } );
        return false;
      }
      return true;
    }
    
    override public function save():void {
      if( _selected ) {
        _commander.faction = _selected.faction;
      }
      super.save();
    }
    
    override public function close():void {
      var total:uint = _selections.length;
      for ( var i:int = 0; i < total; i++ ) {
        KuroExpress.removeListener( _selections[i], Event.SELECT, factionSelected );
      }
      super.close();
      closed();
    }
    
  }
  
}

import com.boomtown.core.Faction;
import com.boomtown.gui.StandardButton;
import com.kuro.kuroexpress.KuroExpress;
import com.kuro.kuroexpress.XMLManager;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFormatAlign;

class FactionChoice extends Sprite {
  
  private var _faction:Faction;
  private var _width:Number;
  private var _height:Number;
  
  private var _title:TextField;
  private var _acronym:TextField;
  private var _description:TextField;
  private var _select:StandardButton;
  
  public function FactionChoice( faction:Faction, width:Number, height:Number ):void {
    _faction = faction;
    _width = width;
    _height = height;
    
    addEventListener( Event.ADDED_TO_STAGE, init );
  }
  
  private function init( e:Event ):void {
    removeEventListener( Event.ADDED_TO_STAGE, init );
    
    var dark:uint = uint( XMLManager.getFile("settings").primary_faction_colors[_faction.name].dark );
    var medium:uint = uint( XMLManager.getFile("settings").primary_faction_colors[_faction.name].medium );
    var light:uint = uint( XMLManager.getFile("settings").primary_faction_colors[_faction.name].light );
    var alternate:uint = uint( XMLManager.getFile("settings").primary_faction_colors[_faction.name].alternate );
    
    draw();
    
    _title = KuroExpress.createTextField( { font:"BorisBlackBloxx", size:16, color:0xFFFFFF, width:_width - 40, wordWrap:true, align:TextFormatAlign.CENTER } );
    _title.text = _faction.title;
    addChild( _title );
    _title.x = 20;
    _title.y = 20;
    
    _acronym = KuroExpress.createTextField( { font:"BorisBlackBloxx", size:12, color:light } );
    _acronym.text = _faction.acronym;
    addChild( _acronym );
    _acronym.x = _width / 2 - _acronym.width / 2;
    _acronym.y = _title.y + _title.height + 10;
    
    _description = KuroExpress.createTextField( { font:"BorisBlackBloxx", size:10, color:0xFFFFFF, width:_width - 40, wordWrap:true } );
    _description.text = _faction.description;
    addChild( _description );
    _description.x = 20;
    _description.y = _acronym.y + _acronym.height + 40;
    
    _select = new StandardButton( "SELECT", { 
      color:medium,
      overColor:light,
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
    var dark:uint = uint( XMLManager.getFile("settings").primary_faction_colors[_faction.name].dark );
    var medium:uint = uint( XMLManager.getFile("settings").primary_faction_colors[_faction.name].medium );
    
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
  
  public function get faction():Faction {
    return _faction;
  }
  
}
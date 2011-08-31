package com.kuro.kuroexpress.assets {
  import flash.display.Bitmap;
  import flash.utils.getDefinitionByName;
	
  public class KuroAssets {
    
    public static function getAsset( id:String ):Class {
			var assetClass:Class = getDefinitionByName( id ) as Class;
			return assetClass;
		}
		
		public static function createAsset( id:String ):Object {
			var assetClass:Class = getDefinitionByName( id ) as Class;
			return new assetClass();
		}
    
    public static function createBitmap( id:String ):Bitmap {
      var assetClass:Class = getDefinitionByName( id ) as Class;
      return new Bitmap( new assetClass( 0, 0 ) );
    }
    
  }

}
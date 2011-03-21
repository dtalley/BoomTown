<?php

	class lang {
		
		private static $phrases;
		private static $language;
		private static $root;
		private static $additions = array();
		
		public static function initialize( $root, $language ) {
			self::$root = $root;
			self::change( $language );
		}
		
		public static function change( $language ) {
			self::$language = $language;
			$language_file = self::$root . "/" . self::$language . ".xml";
			self::$phrases = @simplexml_load_file( $language_file );
			if( !self::$phrases ) {
				sys::message( SYSTEM_ERROR, "Language Error", "The main language file could not be located ($language_file).", __FILE__, __LINE__, __FUNCTION__, __CLASS__ );
			}
			$additions = self::$additions;
			self::$additions = array();
			if( count( $additions ) > 0 ) {
				$total_additions = count( $additions );
				for( $i = 0; $i < $total_additions; $i++ ) {
					self::add( $additions[$i] );
				}
			}
		}
		
		public static function add( $dir ) {
			$language_file = $dir . "/" . self::$language . ".xml";
			if( file_exists( $language_file ) ) {
				$new_language = @simplexml_load_file( $language_file );
				foreach( $new_language->children() as $child ) {
					sys::append_xml( self::$phrases, $child );
				}
				self::$additions[] = $dir;
			}
		}
		
		public static function get_phrase() {
			$path = sys::input( "path", "" );
			if( $path ) {
				$vars = explode( ",", sys::input( "vars", "" ) );
				$var_list = "";
				if( count( $vars ) ) {
					for( $i = 0; $i < count( $vars ); $i++ ) {
						$var_list .= ", '" . $vars[$i] . "'";
					}
				}
				$evaluate = "action::add( \"phrase\", self::phrase( \$path$var_list ) );";
				eval( $evaluate );
			}
		}
		
		public static function phrase( $path ) {
			$result = @self::$phrases->xpath( "/phrases/" . $path );
			if( !is_array( $result ) || !isset( $result[0] ) ) {
				$result = array($path);
			}
			$result[0] = str_replace( "%lb", LINE_BREAK, $result[0] );
			for( $i = 1; $i < func_num_args(); $i++ ) {
				$arg_string = func_get_arg($i);
				$result[0] = str_replace( "%$i", $arg_string, $result[0] );
			}
      $result[0] = str_replace( "%lt", "<", $result[0] );
      $result[0] = str_replace( "%gt", ">", $result[0] );
			return $result[0];
		}
		
	}

?>
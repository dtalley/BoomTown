<?php

	class tpl {
		
		private static $root;
		private static $template;

    private static $restricted_page = false;
		
		public static function initialize( $style, $template ) {
			self::$root = $style;
			self::$template = $template;
			if( strlen( $template ) > 0 && substr( $template, -1 ) != "/" ) {
				self::$template .= "/";
			}
			if( !defined( "TEMPLATE_INITIALIZED" ) ) {
				action::start( "template" );
					action::add( "style_dir", RELATIVE_DIR . "/" . str_replace( ROOT_DIR . "/", "", self::$root ) );
					action::add( "template_dir", RELATIVE_DIR . "/" . str_replace( ROOT_DIR . "/", "", self::$root ) . "/" . self::$template );
				action::end();
			}
			define( "TEMPLATE_INITIALIZED", true );
		}
		
		public static function revert() {
			self::$template = "";
		}

    public static function set_restricted_page() {
      self::$restricted_page = true;
    }
		
		public static function load( $id, $recursive = 0, $skip_page = false ) {
      //Check for the comprehensive template, and create it if it doesn't exist
      if( !xsl::comprehensive_exists( self::$template . $id, self::$root ) ) {
        if( $recursive < 5 ) {
          $xsl = xsl::load_xsl( self::$template . $id, self::$root );
          xsl::create_comprehensive( self::$template . $id, self::$root, $xsl );
          usleep(30000);
          return self::load( $id, $recursive + 1 );
        } else {
          sys::message(
            SYSTEM_ERROR,
            lang::phrase( "error/template/could_not_create_comprehensive/title" ),
            lang::phrase( "error/template/could_not_create_comprehensive/body", self::$template . $id )
          );
        }
      //Check for the page template, and create it if it doesn't exist
      } else if( !xsl::page_exists( self::$template . $id, self::$root ) || $skip_page ) {
        if( $recursive < 5 ) {
          $xsl = xsl::load_comprehensive( self::$template . $id, self::$root );
          $page_needed = xsl::create_page( $xsl );
          if( $page_needed && !$skip_page ) {
            return self::load( $id, $recursive + 1 );
          } else {
            return xsl::apply( action::response(), $xsl );
          }
        } else {
          sys::message(
            SYSTEM_ERROR,
            lang::phrase( "error/template/could_not_create_page/title" ),
            lang::phrase( "error/template/could_not_create_page/body", self::$template . $id )
          );
        }
      //Check all of the page template's dependencies, and refresh them if they are out of date
      } else {
        if( $recursive < 5 ) {
          $xsl = xsl::load_page();
          $output = xsl::apply( action::response(), $xsl, true );
          if( is_array( $output ) ) {
            xsl::refresh_dependencies( self::$template . $id, self::$root, $output, $xsl );
            return self::load( $id, $recursive + 1 );
          }
          if( self::$restricted_page ) {
            unlink( xsl::get_page_file() );
          }
          return $output;
        } else {
          sys::message(
            SYSTEM_ERROR,
            lang::phrase( "error/template/could_not_refresh_dependencies/title" ),
            lang::phrase( "error/template/could_not_refresh_dependencies/body", self::$template . $id )
          );
        }
      }
		}

    public static function check_dependencies( $names, $date ) {
      if( $names && !is_array( $names ) ) {
        $names = array( $names );
      }
      $stale_dependencies = array();
      if( !$names || count( $names ) == 0 ) {
        return $stale_dependencies;
      }
      $benchmark = $date;
      db::open( TABLE_DEPENDENCIES );
        db::where_in( "dependency_name", $names );
      while( $row = db::result() ) {
        $updated = strtotime( $row['dependency_updated'] );
        if( $updated > $benchmark ) {
          $stale_dependencies[] = $row['dependency_name'];
        }
      }
      return $stale_dependencies;
    }

    public static function update_dependency( $name ) {
      db::open( TABLE_DEPENDENCIES );
        db::where( "dependency_name", $name );
      $dependency = db::result();
      db::open( TABLE_DEPENDENCIES );
        db::set( "dependency_updated", gmdate( "Y-m-d H:i:s" ) );
      if( $dependency ) {
        db::where( "dependency_name", $name );
        if( !db::update() ) {
          sys::message(
            SYSTEM_ERROR,
            lang::phrase( "error/template/actions/update_dependency/could_not_update/title" ),
            lang::phrase( "error/template/actions/update_dependency/could_not_update/body" ),
            __FILE__, __LINE__, __FUNCTION__, __CLASS__
          );
        }
      } else {
        db::set( "dependency_name", $name );
        if( !db::insert() ) {
          sys::message(
            SYSTEM_ERROR,
            lang::phrase( "error/template/actions/update_dependency/could_not_create/title" ),
            lang::phrase( "error/template/actions/update_dependency/could_not_create/body" ),
            __FILE__, __LINE__, __FUNCTION__, __CLASS__
          );
        }
      }
    }

    public static function delete_dependency( $name ) {
      db::open( TABLE_DEPENDENCIES );
        db::where( "dependency_name", $name );
      if( !db::delete() ) {
        sys::message(
          SYSTEM_ERROR,
          lang::phrase( "error/template/actions/delete_dependency/could_not_delete/title" ),
          lang::phrase( "error/template/actions/delete_dependency/could_not_delete/body" ),
          __FILE__, __LINE__, __FUNCTION__, __CLASS__
        );
      }
    }

    public static function get_style_dir() {
      return action::get( "template/style_dir" ) . "";
    }
		
	}

?>
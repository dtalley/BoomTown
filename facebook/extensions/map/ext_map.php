<?php
    class map {
		
      public static function hook_account_initialized() {
        $extension_actions = sys::input( "map_action", false, SKIP_GET );
        $actions = array(
          "get_territory"
        );
        if( !is_array( $extension_actions ) ) {
          $extension_actions = array( $extension_actions );
        }
        foreach( $extension_actions as $action ) {
          if( in_array( $action, $actions ) ) {
            call_user_func( "self::$action" );
          }
        }
      }

      private static function get_territory() {
        $territory_x = sys::input( "territory_x", null );
        $territory_y = sys::input( "territory_y", null );
        if( $territory_x == null || $territory_y == null ) {
          sys::message(
            USER_ERROR,
            lang::phrase( "map/error/incomplete_map_coordinates/title" ),
            lang::phrase( "map/error/incomplete_map_coordinates/body" ),
            NULL, NULL, __FUNCTION__, __CLASS__
          );
        }        
        db::open( TABLE_TERRITORIES );
          db::where( "territory_x", $territory_x );
          db::where( "territory_y", $territory_y );
          db::open( TABLE_TERRITORY_STATUSES );
            db::link( "territory_status_id" );
          db::close();
          db::open( TABLE_FACTIONS, LEFT );
            db::link( "faction_id" );
          db::close();
        $territory = db::result();
        if( !$territory ) {
          sys::message(
            USER_ERROR,
            lang::phrase( "map/error/territory_not_found/title" ),
            lang::phrase( "map/error/territory_not_found/body" ),
            NULL, NULL, __FUNCTION__, __CLASS__
          );
        }
        action::resume( "map/territory" );
          action::add( "id", $territory['territory_id'] );
          action::add( "x", $territory['territory_x'] );
          action::add( "y", $territory['territory_y'] );
          action::start( "status" );
            action::add( "id", $territory['territory_status_id'] );
            action::add( "name", $territory['territory_status_name'] );
          action::end();
          if( $territory['faction_name'] ) {
            action::start( "faction" );
              action::add( "id", $territory['faction_id'] );
              action::add( "name", $territory['faction_id'] );
              action::add( "title", $territory['faction_title'] );
              action::add( "description", $territory['faction_description'] );
              action::add( "acronym", $territory['faction_acronym'] );
              action::add( "population", $territory['faction_population'] );
            action::end();
          }
        action::end();
      }

      
		
    }
?>
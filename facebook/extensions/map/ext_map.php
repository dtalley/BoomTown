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
        
      }
		
    }
?>
<?php
    class bases {
		
      public static function hook_account_initialized() {
        $extension_actions = sys::input( "bases_action", false, SKIP_GET );
        $actions = array(
          "list_bases"
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

      private static function list_bases() {
        action::resume( "bases/base_list" );
          db::open( TABLE_BASES );
          while( $row = db::result() ) {
            action::start( "base" );
              action::add( "id", $row['base_id'] );
              action::add( "title", $row['base_title'] );
              action::add( "name", $row['base_name'] );
              action::add( "description", $row['base_description'] );
            action::end();
          }
        action::end();
      }
		
    }
?>
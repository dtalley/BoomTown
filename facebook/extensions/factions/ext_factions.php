<?php
    class factions {
		
      public static function hook_account_initialized() {
        $extension_actions = sys::input( "factions_action", false, SKIP_GET );
        $actions = array(
          "list_factions"
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

      private static function list_factions() {
        action::resume( "factions/faction_list" );
          db::open( TABLE_FACTIONS );
          while( $row = db::result() ) {
            action::start( "faction" );
              action::add( "id", $row['faction_id'] );
              action::add( "title", $row['faction_title'] );
              action::add( "name", $row['faction_name'] );
              action::add( "description", $row['faction_description'] );
              action::add( "acronym", $row['faction_acronym'] );
              action::add( "population", $row['faction_population'] );
            action::end();
          }
        action::end();
      }
		
    }
?>
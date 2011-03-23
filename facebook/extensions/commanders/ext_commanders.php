<?php
    class commanders {
		
      public static function hook_account_initialized() {
        $commanders_action = sys::input( "commanders_action", false, SKIP_GET );
        $actions = array(
          
        );
        if( !is_array( $commanders_action ) ) {
          $commanders_action = array( $commanders_action );
        }
        foreach( $commanders_action as $action ) {
          if( in_array( $action, $actions ) ) {
            call_user_func( "self::$action" );
          }
        }
      }

      public static function get_commander( $commander_id = 0, $user_id = 0 ) {
        if( !$commander_id ) {
          $commander_id = sys::input( "commander_id", 0 );
        }
        if( !$user_id ) {
          $user_id = sys::input( "user_id", 0 );
        }
        if( $commander_id || $user_id ) {
          db::open( TABLE_COMMANDERS );
            if( $commander_id ) {
              db::where( "commander_id", $commander_id );
            }
            if( $user_id ) {
              db::where( "user_id", $user_id );
            }
            db::open( TABLE_COMMAND_FACTIONS, LEFT );
              db::link( "commander_id" );
              db::where( "command_faction_active", true );
              db::open( TABLE_FACTIONS );
                db::link( "faction_id" );
              db::close();
            db::close();
            db::open( TABLE_COMMAND_BASES, LEFT );
              db::link( "commander_id" );
              db::where( "command_base_active", true );
              db::open( TABLE_BASES );
                db::link( "base_id" );
              db::close();
            db::close();
            db::open( TABLE_COMMAND_RANKS );
              db::link( "commander_id" );
              db::where( "command_rank_active", true );
              $alias = db::open( TABLE_RANKS );
                db::link( "rank_id" );
                db::open( TABLE_RANKS, LEFT );
                  db::select_as( "next_rank_id" );
                  db::select( "rank_id" );
                  db::select_as( "next_rank_level" );
                  db::select( "rank_level" );
                  db::select_as( "next_rank_title" );
                  db::select( "rank_title" );
                  db::select_as( "next_rank_name" );
                  db::select( "rank_name" );
                  db::where( "rank_order", $alias . ".rank_order + 1", NULL, NULL, false );
                db::close();
                db::open( TABLE_RANKS, LEFT );
                  db::select_as( "previous_rank_id" );
                  db::select( "rank_id" );
                  db::select_as( "previous_rank_level" );
                  db::select( "rank_level" );
                  db::select_as( "previous_rank_title" );
                  db::select( "rank_title" );
                  db::select_as( "previous_rank_name" );
                  db::select( "rank_name" );
                  db::where( "rank_order", $alias . ".rank_order - 1", NULL, NULL, false );
                db::close();
              db::close();
            db::close();
          $commander = db::result();
          if( !$commander ) {
            sys::message(
              USER_ERROR,
              lang::phrase( "commanders/error/invalid_commander_id/title" ),
              lang::phrase( "commanders/error/invalid_commander_id/body" ),
              __FILE__, __LINE__, __FUNCTION__, __CLASS__
            );
          }
          action::resume( "commanders" );
            action::start( "commander" );
              action::add( "id", $commander_id );
              action::add( "name", $commander['commander_name'] );
              action::add( "experience", $commander['commander_experience'] );
              action::add( "balance", $commander['commander_balance'] );
              action::start( "faction" );
                action::add( "association", $commander['command_faction_id'] );
                action::add( "id", $commander['faction_id'] );
                action::add( "title", $commander['faction_title'] );
                action::add( "name", $commander['faction_name'] );
                action::add( "description", $commander['faction_description'] );
                action::add( "population", $commander['faction_population'] );
                action::add( "acronym", $commander['faction_acronym'] );
                action::start( "dropships" );
                  action::add( "max", $commander['command_faction_dropship_max'] );
                  action::add( "current", $commander['command_faction_dropships'] );
                action::end();
              action::end();
              action::start( "base" );
                action::add( "association", $commander['command_base_id'] );
                action::add( "id", $commander['base_id'] );
                action::add( "title", $commander['base_title'] );
                action::add( "name", $commander['base_name'] );
                action::add( "bandwidth", $commander['command_base_bandwidth'] );
              action::end();
              action::start( "rank" );
                action::add( "association", $commander['command_rank_id'] );
                action::add( "id", $commander['rank_id'] );
                action::add( "title", $commander['rank_title'] );
                action::add( "name", $commander['rank_name'] );
                action::add( "level", $commander['rank_level'] );
                action::add( "order", $commander['rank_order'] );
                if( $commander['next_rank_id'] ) {
                  action::start( "next" );
                    action::add( "id", $commander['next_rank_id'] );
                    action::add( "title", $commander['next_rank_title'] );
                    action::add( "name", $commander['next_rank_name'] );
                    action::add( "level", $commander['next_rank_level'] );
                  action::end();
                }
                if( $commander['previous_rank_id'] ) {
                  action::start( "previous" );
                    action::add( "id", $commander['previous_rank_id'] );
                    action::add( "title", $commander['previous_rank_title'] );
                    action::add( "name", $commander['previous_rank_name'] );
                    action::add( "level", $commander['previous_rank_level'] );
                  action::end();
                }
              action::end();
            action::end();
          action::end();
        } else {
          sys::message(
            USER_ERROR,
            lang::phrase( "commanders/error/missing_commander_id/title" ),
            lang::phrase( "commanders/error/missing_commander_id/body" ),
            NULL, NULL, __FUNCTION__, __CLASS__
          );
        }
      }
		
    }
?>
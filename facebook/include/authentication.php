<?php

define( "GLOBAL_PERMISSIONS", "global" );
define( "TARGET_PERMISSIONS", "target" );

class auth {
	
  public static function hook_account_initialized() {
    if( !defined( "AUTH_ACCOUNT_INITIALIZED" ) && !(int)action::get( "request/feed" ) ) {
      define( "AUTH_ACCOUNT_INITIALIZED", true );
      $cache_id = "uid" . action::get( "user/id" );
      action::resume( "authentication" );
      action::end();
      //sys::query( "get_permission_tiers" );
      if( !CACHE_ENABLED || !$tier_list = cache::get( $cache_id, "authentication/get_permission_tiers" ) ) {
        sys::hook( "get_permission_tiers" );
        $tier_list = action::xpath( "authentication/tier_list" );
        if( CACHE_ENABLED && $tier_list ) {
          cache::set( $tier_list->ownerDocument->saveXML($tier_list), -1, $cache_id, "authentication/get_permission_tiers" );
        }
      } else {
        action::merge( simplexml_load_string( $tier_list ), "authentication" );
      }
      self::calculate_user_permissions();

      $authentication_action = sys::input( "authentication_action", false, SKIP_GET );
      $actions = array(
        "update_permissions",
        "clear_permissions"
      );
      if( in_array( $authentication_action, $actions ) ) {
        $evaluate = "self::$authentication_action();";
        eval( $evaluate );
      }
    }
  }

  private static function calculate_user_permissions() {
    $total_tiers = action::total( "authentication/tier_list/tier" );
    $highest_level = 0;
    $tiers = array();
    $cache_id = "";
    for( $i = 0; $i < $total_tiers; $i++ ) {
      $total_targets = action::total( "authentication/tier_list/tier[" . ( $i + 1 ) . "]/target_list/target" );
      if( $total_targets > 0 ) {
        $level = (int)action::get( "authentication/tier_list/tier/level", $i );
        if( $level > $highest_level ) {
          $highest_level = $level;
        }
        $tier = array(
          "name" => action::get( "authentication/tier_list/tier/name", $i ),
          "table" => action::get( "authentication/tier_list/tier/permission_table", $i ),
          "column" => action::get( "authentication/tier_list/tier/id_column", $i ),
          "targets" => array()
        );
        for( $j = 0; $j < $total_targets; $j++ ){
          array_push( $tier['targets'], action::get( "authentication/tier_list/tier[" . ( $i + 1 ) . "]/target_list/target", $j ) );
        }
        if( !isset( $tiers[$level] ) ) {
          $tiers[$level] = array();
        }
        array_push( $tiers[$level], $tier );
        if( $cache_id ) {
          $cache_id .= ".";
        }
        $cache_id .= $tier['name'] . implode( "", $tier['targets'] );
      }
    }
    if( !CACHE_ENABLED || !$permission_list = cache::get( $cache_id, "authentication/get_permissions" ) ) {
      $permission_groups = array();
      for( $i = $highest_level; $i > 0; $i-- ) {
        if( isset( $tiers[$i] ) && $tiers[$i] ) {
          $total_tiers = count( $tiers[$i] );
          $new_level = true;
          for( $j = 0; $j < $total_tiers; $j++ ) {
            $tier = $tiers[$i][$j];
            db::open( $tier['table'] );
              db::where_in( $tier['column'], $tier['targets'] );
              db::open( TABLE_PERMISSION_GROUPS );
                db::select( "permission_group_name", "permission_group_type" );
                db::link( "permission_group_id" );
                db::open( TABLE_PERMISSIONS );
                  db::select( "permission_id", "permission_name", "permission_bit" );
                  db::link( "permission_group_id" );
                db::close();
              db::close();
            while( $row = db::result() ) {
              if( !isset( $permission_groups[$row['permission_group_name']] ) ) {
                $permission_groups[$row['permission_group_name']] = array();
              }
              if( !isset( $permission_groups[$row['permission_group_name']][$row['permission_group_type']] ) ) {
                $permission_groups[$row['permission_group_name']][$row['permission_group_type']] = array();
              }
              if( $row['permission_group_type'] == "target" ) {
                if( !isset( $permission_groups[$row['permission_group_name']][$row['permission_group_type']][$row['permission_group_target']] ) ) {
                  $permission_groups[$row['permission_group_name']][$row['permission_group_type']][$row['permission_group_target']] = array();
                }
                $permission_groups[$row['permission_group_name']][$row['permission_group_type']][$row['permission_group_target']]['group_type'] = $row['permission_group_type'];
                $cper = NULL;
                if( isset( $permission_groups[$row['permission_group_name']][$row['permission_group_type']][$row['permission_group_target']][$row['permission_name']] ) ) {
                  $cper = $permission_groups[$row['permission_group_name']][$row['permission_group_type']][$row['permission_group_target']][$row['permission_name']];
                }
              } else {
                $permission_groups[$row['permission_group_name']][$row['permission_group_type']]['no_target'] = 1;
                $permission_groups[$row['permission_group_name']][$row['permission_group_type']]['group_type'] = $row['permission_group_type'];
                $cper = NULL;
                if( isset( $permission_groups[$row['permission_group_name']][$row['permission_group_type']][$row['permission_name']] ) ) {
                  $cper = $permission_groups[$row['permission_group_name']][$row['permission_group_type']][$row['permission_name']];
                }
              }
              if( isset( $row[$tier['table'].''] ) ) {
                $row['permission_bit'] -= 1;
                if( $cper == NULL ) {
                  $cper = ( $row[$tier['table'].''] & pow( 2, $row['permission_bit'] ) ) > 0 ? 1 : 0;
                  $new_level = false;
                } else {
                  if( $new_level ) {
                    $cper &= ( $row[$tier['table'].''] & pow( 2, $row['permission_bit'] ) ) > 0 ? 1 : 0;
                    $new_level = false;
                  } else {
                    $cper |= ( $row[$tier['table'].''] & pow( 2, $row['permission_bit'] ) ) > 0 ? 1 : 0;
                  }
                }
              }
              if( $row['permission_group_type'] == "target" ) {
                $permission_groups[$row['permission_group_name']][$row['permission_group_type']][$row['permission_group_target']][$row['permission_name']] = $cper;
              } else {
                $permission_groups[$row['permission_group_name']][$row['permission_group_type']][$row['permission_name']] = $cper;
              }
            }
          }
        }
      }
      action::resume( "authentication/permissions" );
        foreach( $permission_groups as $group => $types ) {
          action::start( $group );
            foreach( $types as $type => $permissions ) {
              action::start( $type );
                if( isset( $permissions['no_target'] ) && $permissions['no_target'] == 1 ) {
                  foreach( $permissions as $name => $permission ) {
                    if( $name != "no_target" && $name != "group_type" ) {
                      action::add( $name, $permission );
                    }
                  }
                } else {
                  foreach( $permissions as $target => $perms ) {
                    action::start( $group . "-" . $target );
                      foreach( $perms as $name => $permission ) {
                        if( $name != "group_type" ) {
                          action::add( $name, $permission );
                        }
                      }
                    action::end();
                  }
                }
              action::end();
            }
          action::end();
        }
      action::end();
      $permission_list = action::xpath( "authentication/permissions" );
      if( CACHE_ENABLED && $permission_list ) {
        cache::set( $permission_list->ownerDocument->saveXML($permission_list), -1, $cache_id, "authentication/get_permissions" );
      }
    } else {
      action::merge( simplexml_load_string( $permission_list ), "authentication" );
    }
  }
	
	private static function update_permissions() {
		$permission_group_id = (int) sys::input( "permission_group_id", 0 );
		if( !$permission_group_id ) {
			sys::message( USER_ERROR, lang::phrase( "authentication/error/title" ), lang::phrase( "authentication/error/missing_group_id" ) );
		}
		$permission_group_target = (int) sys::input( "permission_group_target", 0 );
		$permission_target = (int) sys::input( "permission_target", 0 );
		if( !$permission_group_id ) {
			sys::message( USER_ERROR, lang::phrase( "authentication/error/title" ), lang::phrase( "authentication/error/missing_target" ) );
		}
		$total_permissions = (int) sys::input( "total_permissions", 0 );
		$permissions = 0;
    $defaults = 0;
		for( $i = 1; $i <= $total_permissions; $i++ ) {
			$bit = (int) sys::input( "bit-" . $i, 0 );
			if( !$bit ) {
				sys::message( 
          USER_ERROR,
          lang::phrase( "authentication/error/actions/update_permissions/missing_bit/title" ),
          lang::phrase( "authentication/error/actions/update_permissions/missing_bit/body" )
        );
			}
			$value = (int) sys::input( "value-" . $i, 0 );
			if( $value == 1 ) {
				$permissions = $permissions | pow( 2, $bit-1 );
			} else if( $value == 0 ) {
        $defaults = $defaults | pow( 2, $bit-1 );
      }
		}
		$total_tiers = action::total( "authentication/tier_list/tier" );
		$permission_tier_name = sys::input( "permission_tier_name", "" );
		for( $i = 0; $i < $total_tiers; $i++ ) {
			if( action::get( "authentication/tier_list/tier/name", $i ) == $permission_tier_name ) {
				$permission_table = action::get( "authentication/tier_list/tier/permission_table", $i ).'';
				$item_table = action::get( "authentication/tier_list/tier/item_table", $i ).'';
				$id_column = action::get( "authentication/tier_list/tier/id_column", $i ).'';
				$name_column = action::get( "authentication/tier_list/tier/name_column", $i ).'';
				
				db::open( $permission_table );
					db::where( $id_column, $permission_target );
					db::where( "permission_group_id", $permission_group_id );
					if( $permission_group_target ) {
						db::where( "permission_group_target", $permission_group_target );
					}
				$permission_info = db::result();
        db::clear_result();
				
				db::open( $permission_table );
					db::set( $permission_table, $permissions );
          db::set( "permission_defaults", $defaults );
          if( $permission_info ) {
            db::where( $id_column, $permission_target );
            db::where( "permission_group_id", $permission_group_id );
            if( $permission_group_target ) {
              db::where( "permission_group_target", $permission_group_target );
            }
            if( !db::update() ) {
              sys::message( SYSTEM_ERROR, lang::phrase( "error/authentication/update_permissions/title" ), lang::phrase( "error/authentication/update_permissions/body", db::error() ), __FILE__, __LINE__, __FUNCTION__, __CLASS__ );
            }
            cache::flush();
          } else {
            db::set( $id_column, $permission_target );
            db::set( "permission_group_id", $permission_group_id );
            if( $permission_group_target ) {
              db::set( "permission_group_target", $permission_group_target );
            }
            if( !db::insert() ) {
              sys::message( SYSTEM_ERROR, lang::phrase( "error/authentication/create_permissions/title" ), lang::phrase( "error/authentication/create_permissions/body", db::error() ), __FILE__, __LINE__, __FUNCTION__, __CLASS__ );
            }
            cache::flush();
          }
				action::resume( "authentication/authentication_action" );
					action::add( "success", 1 );
					action::add( "message", lang::phrase( "authentication/update_permissions/success" ) );
				action::end();
				break;
			}
		}
	}

  private static function clear_permissions() {
		$permission_group_id = (int) sys::input( "permission_group_id", 0 );
		if( !$permission_group_id ) {
			sys::message( USER_ERROR, lang::phrase( "authentication/error/title" ), lang::phrase( "authentication/error/missing_group_id" ) );
		}
		$permission_group_target = (int) sys::input( "permission_group_target", 0 );
		$permission_target = (int) sys::input( "permission_target", 0 );
		if( !$permission_group_id ) {
			sys::message( USER_ERROR, lang::phrase( "authentication/error/title" ), lang::phrase( "authentication/error/missing_target" ) );
		}
		$total_permissions = (int) sys::input( "total_permissions", 0 );
		$permissions = 0;
		for( $i = 1; $i <= $total_permissions; $i++ ) {
			$bit = (int) sys::input( "bit-" . $i, 0 );
			if( !$bit ) {
				sys::message( USER_ERROR, lang::phrase( "authentication/error/title" ), lang::phrase( "authentication/error/missing_bit" ) );
			}
			$value = (int) sys::input( "value-" . $i, 0 );
			if( $value ) {
				$permissions = $permissions | pow( 2, $bit-1 );
			}
		}
		$total_tiers = action::total( "authentication/master_tier_list/tier" );
		$permission_tier_name = sys::input( "permission_tier_name", "" );
		for( $i = 0; $i < $total_tiers; $i++ ) {
			if( action::get( "authentication/master_tier_list/tier/name", $i ) == $permission_tier_name ) {
				$permission_table = action::get( "authentication/master_tier_list/tier/permission_table", $i ).'';
				$item_table = action::get( "authentication/master_tier_list/tier/item_table", $i ).'';
				$id_column = action::get( "authentication/master_tier_list/tier/id_column", $i ).'';
				$name_column = action::get( "authentication/master_tier_list/tier/name_column", $i ).'';

				db::open( $permission_table );
					db::where( $id_column, $permission_target );
					db::where( "permission_group_id", $permission_group_id );
					if( $permission_group_target ) {
						db::where( "permission_group_target", $permission_group_target );
					}
				if( !db::delete() ) {
          sys::message( 
            SYSTEM_ERROR,
            lang::phrase( "error/authentication/update_permissions/title" ),
            lang::phrase( "error/authentication/update_permissions/body", db::error() ),
            __FILE__, __LINE__, __FUNCTION__, __CLASS__
          );
        }
				action::resume( "authentication/authentication_action" );
					action::add( "action", "clear_permissions" );
          action::add( "success", 1 );
					action::add( "message", lang::phrase( "authentication/clear_permissions/success" ) );
				action::end();
				break;
			}
		}
    cache::clear( "", "authentication/get_permission_tiers" );
    cache::clear( "", "authentication/get_permissions" );
	}

	public static function authenticate_all_with_permission( $main_type, $main_group, $main_target, $main_permission, $add_type, $add_group, $add_target ) {
    db::open( TABLE_PERMISSION_GROUPS );
      db::where( "permission_group_name", $add_group );
      db::where( "permission_group_type", $add_type );
        db::open( TABLE_PERMISSIONS );
          db::link( "permission_group_id" );
    $authentication = 0;
    $add_group_id = 0;
    while( $row = db::result() ) {
      $add_group_id = $row['permission_group_id'];
      $authentication = $authentication | pow( 2, $row['permission_bit'] - 1 );
    }
    $total_tiers = action::total( "authentication/master_tier_list/tier" );
    for( $i = 0; $i < $total_tiers; $i++ ) {
      $table = action::get( "authentication/master_tier_list/tier/permission_table", $i );
      $column = action::get( "authentication/master_tier_list/tier/id_column", $i );
      db::open( $table );
        if( $main_target ) {
          db::where( "permission_group_target", $main_target );
        }
        db::open( TABLE_PERMISSION_GROUPS );
          db::link( "permission_group_id" );
          db::where( "permission_group_name", $main_group );
          db::where( "permission_group_type", $main_type );
          db::open( TABLE_PERMISSIONS );
            db::link( "permission_group_id" );
            db::where( "permission_name", $main_permission );
          db::close();
        db::close();
      while( $row = db::result() ) {
        db::open( $table );
          db::set( "permission_group_id", $add_group_id );

          db::set( $column, $row[$column.''] );
          if( $add_target ) {
            db::set( "permission_group_target", $add_target );
          }
          db::set( $table, $authentication );
        if( !db::insert() ) {
          sys::message(
            SYSTEM_ERROR,
            lang::phrase( "error/authentication/authenticate_all_with_permission/title" ),
            lang::phrase( "error/authentication/authenticate_all_with_permission/body", db::error() ),
            __FILE__, __LINE__, __FUNCTION__, __CLASS__
          );
        }
      }
    }
  }

  public static function authenticate_tier( $tier, $target, $add_type, $add_group, $add_target ) {
    
  }

  public static function test( $group, $permission = "", $type = "global", $target = NULL ) {
    if( !action::get( "authentication/permissions" ) ) {
      self::hook_account_initialized();
    }
    if( $permission ) {
      $perm = (int)action::get( "authentication/permissions/" . $group . "/" . $type . "/" . ( $target ? $group . "-" . $target . "/" : "" ) . $permission );
      if( $perm ) {
        return true;
      } else {
        return false;
      }
    } else {
      $path = "authentication/permissions/" . $group . "/" . $type . ( $target ? "/" . $group . "-" . $target : "" );
      $perms = action::xpath( $path );
      $permissions = array();
      foreach( $perms->childNodes as $child ) {
        $permissions[$child->nodeName.''] = (int)$child->textContent;
      }      
      return $permissions;
    }
    $tiers = array();
		$total_tiers = action::total( "authentication/tier_list/tier" );
		$highest_tier = 0;
		for( $i = 0; $i < $total_tiers; $i++ ) {
      $level = (int)action::get( "authentication/tier_list/tier/level", $i );
      if( $level > $highest_tier ) {
        $highest_tier = $level;
      }
      if( !isset( $tiers[$level] ) ) {
        $tiers[$level] = array();
      }
      $tier = array(
        "name" => action::get( "authentication/tier_list/tier/name", $i ),
        "table" => action::get( "authentication/tier_list/tier/permission_table", $i ),
        "column" => action::get( "authentication/tier_list/tier/id_column", $i ),
        "targets" => array()
      );
      $total_targets = action::total( "authentication/tier_list/tier[" . ( $i + 1 ) . "]/target_list/target" );
      for( $j = 0; $j < $total_targets; $j++ ){
        array_push( $tier['targets'], action::get( "authentication/tier_list/tier[" . ( $i + 1 ) . "]/target_list/target", $j ) );
      }
      array_push( $tiers[$level], $tier );
		}
    $permissions = array();
    for( $i = $highest_tier; $i >= 0; $i-- ) {
      if( isset( $tiers[$i] ) ) {
        $authenticated = array();
        $total_steps = count( $tiers[$i] );
        for( $j = 0; $j < $total_steps; $j++ ) {
          $total_targets = count( $tiers[$i][$j]["targets"] );
          for( $h = 0; $h < $total_targets; $h++ ) {
            db::open( $tiers[$i][$j]["table"] );
              db::where( $tiers[$i][$j]["column"], $tiers[$i][$j]["targets"][$h] );
              if( $target ) {
                db::where( "permission_group_target", $target );
              }
              db::open( TABLE_PERMISSION_GROUPS );
                db::link( "permission_group_id" );
                db::where( "permission_group_name", $group );
                db::where( "permission_group_type", $type );
                db::open( TABLE_PERMISSIONS );
                  db::link( "permission_group_id" );
                  if( $permission ) {
                    db::where( "permission_name", $permission );
                  }
                db::close();
              db::close();
            while( $row = db::result() ) {
              $outcome = $row[$tiers[$i][$j]['table'].''] & pow( 2, ( $row['permission_bit'] - 1 ) );
              $default = $row['permission_defaults'] & pow( 2, ( $row['permission_bit'] - 1 ) );
              if( $outcome ) {
                $outcome /= $outcome;
              }
              if( !$default ) {
                if( $outcome ) {
                  $permissions[$row['permission_name']] = 1;
                  $authenticated[$row['permission_name']] = true;
                } else if( !isset( $authenticated[$row['permission_name']] ) ) {
                  $permissions[$row['permission_name']] = 0;
                }
              }
            }
          }
        }
      }
    }
    if( $permission ) {
      action::resume( "authentication/" . $group . "/" . $type . ( $target ? "-" . $target : "" ) );
        action::add( $permission, $permissions[$permission.''] );
      action::end();
    }
    if( $permission && ( !isset( $permissions[$permission.''] ) || !$permissions[$permission.''] ) ) {
      return false;
    } else {
      return $permissions;
    }
  }

  public static function list_permission_groups() {
    action::resume( "authentication/permission_group_list" );
      db::open( TABLE_PERMISSION_GROUPS );
        db::where( "permission_group_type", GLOBAL_PERMISSIONS );
      while( $row = db::result() ) {
        action::start( "permission_group" );
          action::add( "name", $row['permission_group_name'] );
          action::add( "title", lang::phrase( $row['permission_group_name'] . "/title" ) );
          action::add( "type", $row['permission_group_type'] );
        action::end();
      }
    action::end();
  }
	
	public static function list_items() {
    $permission_group_name = sys::input( "permission_group_name", 0 );
    $permission_group_target = sys::input( "permission_group_target", 0 );
    $permission_tier_name = sys::input( "permission_tier_name", 0 );
    if( !$permission_tier_name ) {
    	sys::message( USER_ERROR, lang::phrase( "authentication/error/title" ), lang::phrase( "authentication/error/missing_tier_name" ) );
    }
	  if( !$permission_group_name ) {
	  	sys::message( USER_ERROR, lang::phrase( "authentication/error/title" ), lang::phrase( "authentication/error/missing_group_name" ) );
    }
    echo "<!-- Fetching permissions for " . $permission_group_name . " / " . $permission_group_target . " / " . $permission_tier_name . " -->\n";
    $page = sys::input( "page", 1 );
    $letter = sys::input( "letter", "" );
    $per_page = sys::input( "per_page", 12 );
    
		$total_tiers = action::total( "authentication/master_tier_list/tier" );
    echo "<!-- Total tiers: " . $total_tiers . " -->\n";
		for( $i = 0; $i < $total_tiers; $i++ ) {
			if( action::get( "authentication/master_tier_list/tier/name", $i ).'' == $permission_tier_name ) {
				$item_table = action::get( "authentication/master_tier_list/tier/item_table", $i );
				$id_column = action::get( "authentication/master_tier_list/tier/id_column", $i ).'';
				$name_column = action::get( "authentication/master_tier_list/tier/name_column", $i ).'';
				
				db::open( $item_table );
					db::select_as( "total_items" );
					db::select_count( $id_column );
					if( $letter ) {
	          db::start_block();
	            db::where_like( $name_column, "$letter%" );
	            db::where_or();
	            db::where_like( $name_column, strtoupper($letter) . "%" );
	            db::where_and();
	          db::end_block();
	        }
	      $count = db::result();
        db::clear_result();
	      $total_items = $count['total_items'];
				
				action::resume( "authentication" );
					action::add( "items_per_page", $per_page );
					action::add( "total_items", $total_items );
					action::add( "total_pages", ceil( $total_items / $per_page ) );
					action::add( "page", $page );
					action::start( "tier" );
						action::add( "name", $permission_tier_name );
						action::add( "title", action::get( "authentication/master_tier_list/tier/title", $i ).'' );
					action::end();
					action::start( "group" );
						action::add( "name", $permission_group_name );
						action::add( "title", lang::phrase( "authentication/" . $permission_group_name . "/title" ) );
						if( $permission_group_target ) {
							action::add( "target", $permission_group_target );
						}
					action::end();
				 	action::start( "item_list" );
					  db::open( $item_table );
							if( $letter ) {
			          db::start_block();
			            db::where_like( $name_column, "$letter%" );
			            db::where_or();
			            db::where_like( $name_column, strtoupper($letter) . "%" );
			            db::where_and();
			          db::end_block();
			        }
			        db::limit( $per_page*($page-1), $per_page );
			        db::order( $name_column, "ASC" );
					  while( $row = db::result() ) {
					  	action::start( "item" );
					  	 action::add( "id", $row[$id_column] );
					  	 action::add( "name", $row[$name_column] );
					  	action::end();
					  }
					action::end();
					if( $letter ) {
						action::add( "letter", $letter );
					}
					action::start( "letter_list" );
						for( $i = 0; $i < 26; $i++ ) {
							action::start( "letter" );
								action::add( "character", chr(97+$i) );
							action::end();
						}
					action::end();
				action::end();
				break;
			}
		}
	}

  public static function list_tiers() {
    $permission_group_name = sys::input( "permission_group_name", "" );
    $permission_group_target = sys::input( "permission_group_target", 0 );
    if( $permission_group_name ) {
      action::resume( "authentication" );
        action::start( "group" );
          action::add( "name", $permission_group_name );
          action::add( "title", lang::phrase( "authentication/" . $permission_group_name . "/title" ) );
          if( $permission_group_target ) {
            action::add( "target", $permission_group_target );
          }
        action::end();
      action::end();
    }
    sys::query( "get_permission_tiers" );
  }
	
	public static function list_item_permissions() {
		if( action::total( "url_variables/var" ) < 3 || action::total( "url_variables/var" ) > 4 ) {
			return;
		}		
		$permission_group_target = "";
	  $permission_tier_name = action::get( "url_variables/var", 1 );
    if( !$permission_tier_name || (int) $permission_tier_name > 0 ) {
    	if( action::total( "url_variables/var" ) == 4 ) {
      	$permission_tier_name = action::get( "url_variables/var", 2 );
      	$permission_group_target = action::get( "url_variables/var", 1 );
    	}
    }
    if( !$permission_tier_name ) {
      $permission_tier_name = sys::input( "permission_tier_name", "" );
    }
    if( !$permission_tier_name ) {
    	sys::message( USER_ERROR, lang::phrase( "authentication/error/title" ), lang::phrase( "authentication/error/missing_tier_name" ) );
    }
		$permission_group_name = action::get( "url_variables/var", 0 );
		if( !$permission_group_name ) {
		  $permission_group_name = sys::input( "permission_group_name", "" );
		}		
	  if( !$permission_group_name ) {
	  	sys::message( USER_ERROR, lang::phrase( "authentication/error/title" ), lang::phrase( "authentication/error/missing_group_name" ) );
    }
    $permission_target = action::get( "url_variables/var", 2 );
    if( !$permission_target || (int) $permission_target == 0 ) {
    	if( $permission_group_target ) {
    		$permission_target = action::get( "url_variables/var", 3 );
    	} else {
    		return;
    	}
    }
    
		$total_tiers = action::total( "authentication/master_tier_list/tier" );
		for( $i = 0; $i < $total_tiers; $i++ ) {
			if( action::get( "authentication/master_tier_list/tier/name", $i ).'' == $permission_tier_name ) {
				$permission_table = action::get( "authentication/master_tier_list/tier/permission_table", $i ).'';
				$item_table = action::get( "authentication/master_tier_list/tier/item_table", $i ).'';
				$id_column = action::get( "authentication/master_tier_list/tier/id_column", $i ).'';
				$name_column = action::get( "authentication/master_tier_list/tier/name_column", $i ).'';
				action::resume( "authentication" );
					action::start( "tier" );
						action::add( "name", $permission_tier_name );
						action::add( "title", action::get( "authentication/master_tier_list/tier/title", $i ).'' );
					action::end();
					action::start( "item" );
					 	action::start( "permission_list" );
						  db::open( TABLE_PERMISSION_GROUPS );
						  	db::where( "permission_group_name", $permission_group_name );
                if( $permission_group_target ) {
                  db::where( "permission_group_type", "target" );
                } else {
                  db::where( "permission_group_type", "global" );
                }
						  	db::open( TABLE_PERMISSIONS );
						  		db::link( "permission_group_id" );
						  		db::order( "permission_bit", "ASC" );
						  	db::close();
						  	db::open( $item_table, LEFT );
						  		db::select( $id_column, $name_column );
						  		db::where( $id_column, $permission_target );
						  	db::close();
						  	db::open( $permission_table, LEFT );
						  		db::select( $permission_table, 'permission_defaults' );
						  		db::link( "permission_group_id" );
						  		db::where( $id_column, $permission_target );
									if( $permission_group_target ) {
						  			db::where( "permission_group_target", $permission_group_target );
						  		}
						  	db::close();
						  $previous_row = array();
						  $total_permissions = 0;
						  while( $row = db::result() ) {
						  	$set = 0;
                $default = 0;
						  	$bit = $row['permission_bit'];
						  	if( isset( $row[$permission_table] ) ) {
							  	$permissions = $row[$permission_table];
								  if( $permissions && ( $permissions & pow( 2, ( $bit - 1 ) ) ) > 0 ) {
										$set = 1;
									}
						  	}
                if( isset( $row['permission_defaults'] ) ) {
                  $defaults = $row['permission_defaults'];
                  if( $defaults && ( $defaults & pow( 2, ( $bit - 1 ) ) ) > 0 ) {
                    $default = 1;
                  }
                }
						  	action::start( "permission" );
						  		action::add( "bit", $bit );
						  		action::add( "id", $row['permission_id'] );
						  		action::add( "name", $row['permission_name'] );
						  		action::add( "title", lang::phrase( "authentication/" . $permission_group_name . "/" . $row['permission_name'] . "/title" ) );
						  		action::add( "description", lang::phrase( "authentication/" . $permission_group_name . "/" . $row['permission_name'] . "/description" ) );
						  		action::add( "set", $set );
                  action::add( "default", $default );
                  action::add( "clear", isset( $row['permission_defaults'] ) ? 0 : 1 );
						  	action::end();
						  	$previous_row = $row;
						  	$total_permissions++;
						  }
						action::end();
						action::add( "name", $previous_row[$name_column] );
						action::add( "id", $previous_row[$id_column] );
						action::add( "total", $total_permissions );
					action::end();
					action::start( "group" );
						action::add( "name", $permission_group_name );
						action::add( "title", lang::phrase( "authentication/" . $permission_group_name . "/title" ) );
						action::add( "id", $previous_row['permission_group_id'] );
						if( $permission_group_target ) {
							action::add( "target", $permission_group_target );
						}
					action::end();
				action::end();
				break;
			}
		}
	}

  public static function deny( $group, $permission ) {
    sys::message(
      AUTHENTICATION_ERROR,
      lang::phrase( "authentication/denied" ),
      lang::phrase( "authentication/$group/$permission/denied" )
    );
  }
	
}

?>
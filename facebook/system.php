<?php

	class sys {
		
		public static function message( $code, $title, $message, $file = "", $line = 0, $function = "", $class = "" ) {
      self::hook( "terminating_message" );
			if( !defined( "TEMPLATE_INITIALIZED" ) || $code == SYSTEM_ERROR || $code == MAINTENANCE_ERROR ) {
        if( (int)self::setting( "global", "maintenance_mode" ) == 1 && $code != MAINTENANCE_ERROR ) {
          $title = "Under Construction";
          $message = sys::setting( "global", "maintenance_message" );
          $file = "";
          $line = "";
          $function = "";
          $class = "";
        }
        action::flush();
        action::resume( "message" );
          action::add( "code", $code );
          action::add( "title", $title );
          action::add( "body", $message );
          action::add( "file", $file );
          action::add( "line", $line );
          action::add( "function", $function );
          action::add( "class", $class );
        action::end();
        if( $code == NOTFOUND_ERROR || $code == AUTHENTICATION_ERROR ) {
          header( "HTTP/1.0 404 Not Found" );
        } else if( $code == SYSTEM_ERROR || $code == MAINTENANCE_ERROR || $code == APPLICATION_ERROR ) {
          header( "HTTP/1.1 503 Service Unavailable" );
        }
				header( "Content-type: text/xml" );
				$response = action::response();
				$response_split = explode( "\n", $response->saveXML() );
				array_splice( $response_split, 1, 0, "<?xml-stylesheet type=\"text/xsl\" href=\"" . RELATIVE_DIR . "/" . ( $code == MAINTENANCE_ERROR ? 'maintenance' : 'error' ) . ".xsl\"?>" );
				echo implode( "\n", $response_split );
			} else {
        if( $code == NOTFOUND_ERROR ) {
          header( "HTTP/1.0 404 Not Found" );
        }
        action::resume( "message" );
          action::add( "title", $title );
          action::add( "body", $message );
        action::end();
				tpl::revert();
				echo tpl::load( "message", 0, true );
			}
			exit();
		}

    public static function action( $extension, $action, $success ) {
      action::resume( $extension . "/actions" );
        action::start( "action" );
          action::add( "name", $action );
          action::add( "title", lang::phrase( $extension . "/actions/" . $action . "/title" ) );
          action::add( "success", $success );
          action::add( "message", lang::phrase( $extension . "/actions/" . $action . "/" . ( $success ? "success" : "failure" . ( $message ? $message . "/" : "" ) ) . "/body" ) );
        action::end();
      action::end();
    }

    public static function check_return_page( $text = null ) {
      $return_page = sys::input( "return_page", false );
      $return_text = sys::input( "return_text", false );
      if( $return_page ) {
        if( is_bool( action::get( "request/return_page" ) ) ) {
          action::resume( "request" );
            action::add( "return_page", $return_page );
            if( $return_text ) {
              action::add( "return_text", lang::phrase( $return_text ) );
            } else if( $text ) {
              action::add( "return_text", lang::phrase( $text ) );
            } else {
              action::add( "return_text", lang::phrase( "main/return_previous" ) );
            }
          action::end();
        }
      }
    }

    public static function replace_return_page( $return_page = '', $return_text = '' ) {
      if( $return_page ) {
        if( !is_bool( action::get( "request/return_page" ) ) ) {
          action::remove( "request/return_page" );
        }
        action::resume( "request" );
          action::add( "return_page", $return_page );
        action::end();
      }
      if( $return_text ) {
        if( !is_bool( action::get( "request/return_text" ) ) ) {
          action::remove( "request/return_text" );
        }
        action::resume( "request" );
          action::add( "return_text", $return_text );
        action::end();
      }
    }
		
		public static function setting( $group, $code ) {
      if( !is_bool( action::get( "settings/" . $group . "/" . $code ) ) ) {
        return action::get( "settings/" . $group . "/" . $code );
      } else if( !is_bool( action::get( "settings/" . $code ) ) ) {
        return action::get( "settings/" . $code );
      } else {
        $setting = NULL;
        if( DATABASE_ENABLED ) {
          db::open( TABLE_SETTINGS );
            db::where( "setting_name", $code );
            db::open( TABLE_SETTING_GROUPS );
              db::link( "setting_group_id" );
              db::where( "setting_group_name", $group );
          $setting = db::result();
          db::clear_result();
        } else {
          echo "Setting " . $group . "/" . $code . " could not be found.";
          exit();
        }
        if( $setting ) {
          if( $setting['setting_type'] ) {
            $return_code = "\$return_value = (" . $setting['setting_type'] . ") \$setting['setting_value'];";
          } else {
            $return_code = "\$return_value = \$setting['setting_value'];";
          }
          eval( $return_code );
          return $return_value;
        } else {
          sys::message(
            SYSTEM_ERROR,
            lang::phrase( "main/settings_error/title" ),
            lang::phrase( "main/setting_not_found", $group, $code ),
            __FILE__,
            __LINE__,
            __FUNCTION__,
            __CLASS__
          );
        }
      }
		}
		
		public static function require_extensions( $extensions ) {
			if( !is_array( $extensions ) ) {
				$extensions = array( $extensions );
			}
			$total_extensions = count( $extensions );
			$active_extensions = self::get_extensions();
			$total_active_extensions = count( $active_extensions );
			for( $i = 0; $i < $total_extensions; $i++ ) {
				$extension_found = false;
				for( $j = 0; $j < $total_active_extensions; $j++ ) {
					if( $extensions[$i] == $active_extensions[$j] ) {
						$extension_found = true;
					}
				}
				if( !$extension_found ) {
					sys::message( APPLICATION_ERROR, lang::phrase( "main/extension_missing/title" ), lang::phrase( "main/extension_missing/body", $extensions[$i] ), __FILE__, __LINE__, __FUNCTION__, __CLASS__ );
				}
			}
		}
		
		public static function get_extensions() {
			$active_extensions = array();
      $total_extensions = action::total( "extension_list/extension" );
      for( $i = 0; $i < $total_extensions; $i++ ) {
        $active_extensions[] = action::get( "extension_list/extension/name", $i );
      }
			return $active_extensions;
		}
		
		public static function list_extensions() {
      if( !action::get( "extension_list" ) ) {
        action::start( "extension_list" );
          db::open( TABLE_EXTENSIONS );
            db::where( "extension_active", true );
            db::order( "extension_name", "ASC" );
          while( $row = db::result() ) {
            action::start( "extension" );
              action::add( "name", $row['extension_name'] );
              action::add( "utility", $row['extension_utility'] );
              action::add( "active", $row['extension_active'] );
              action::start( "installed" );
                $timestamp = strtotime( $row['extension_installed'] );
                action::add( "period", self::create_duration( $timestamp, time() ) );
                action::add( "datetime", self::create_datetime( $timestamp ) );
              action::end();
            action::end();
          }
        action::end();
      }
		}
		
		public static function list_settings() {
			$previous_group = "";
			action::start( "setting_list" );
				db::open( TABLE_SETTING_GROUPS );
					db::order( "setting_group_name", "ASC" );
					db::open( TABLE_SETTINGS );
						db::link( "setting_group_id" );
						db::order( "setting_name", "ASC" );
					db::close();
				while( $row = db::result() ) {
					if( $previous_group != $row['setting_group_name'] ) {
						if( $previous_group ) {
							action::end();
						}
						action::start( "setting_group" );
							action::add( "name", $row['setting_group_name'] );
							action::add( "title", lang::phrase( "settings/" . $row['setting_group_name'] . "/title" ) );
					}
					action::start( "setting" );
						action::add( "name", $row['setting_name'] );
						$setting_title = lang::phrase( "settings/" . $row['setting_group_name'] . "/" . $row['setting_name'] . "/title" );
						if( !$setting_title ) {
							$setting_title = $row['setting_name'];
						}
						action::add( "title", $setting_title );
						$setting_description = lang::phrase( "settings/" . $row['setting_group_name'] . "/" . $row['setting_name'] . "/description" );
						if( !$setting_description ) {
							$setting_description = lang::phrase( "settings/no_description" );
						}
						action::add( "description", $setting_description );
						action::add( "type", $row['setting_type'] );
						action::add( "value", $row['setting_value'] );
					action::end();
					$previous_group = $row['setting_group_name'];
				}
				action::end();
			action::end();
		}
		
		public static function hook( $id ) {
			if( !defined( "HOOK_" . strtoupper( $id ) ) ) {
				define( "HOOK_" . strtoupper( $id ), true );
        $args = func_get_args();
				self::mass_call( $id, "hook", $args );
			}
		}

    public static function query( $id ) {
      $args = func_get_args();
      self::mass_call( $id, "query", $args );
    }

    private static function mass_call( $id, $type = 'hook', $arguments = array() ) {
      $active_extensions = self::get_extensions();
      array_unshift( $active_extensions, "account" );
      array_unshift( $active_extensions, "auth" );
      array_unshift( $active_extensions, "preferences" );
      array_unshift( $active_extensions, "assoc" );
      array_unshift( $active_extensions, "tpl" );
      $total_extensions = count( $active_extensions );
      array_splice( $arguments, 0, 1 );
      for( $i = 0; $i < $total_extensions; $i++ ) {
        $method_list = get_class_methods( $active_extensions[$i] );
        $total_methods = count( $method_list );
        for( $j = 0; $j < $total_methods; $j++ ) {
          if( $method_list[$j] == $type . "_" . $id ) {
            $extension = $active_extensions[$i];
            $function = $type . "_" . $id;
            call_user_func_array( $extension . "::" . $function, $arguments );
          }
        }
      }
    }
		
		public static function append_xml( &$xml_to, &$xml_from ) {
			$node1 = dom_import_simplexml($xml_to);
			$dom_sxe = dom_import_simplexml($xml_from);
			$node2 = $node1->ownerDocument->importNode($dom_sxe, true);
      $node1->appendChild($node2);
			$xml_to = simplexml_import_dom( $node1 );
		}

    public static function remove_xml( &$xml_parent, &$xml_child ) {
      $child = dom_import_simplexml( $xml_child );
      $child->parentNode->removeChild( $child );
      //$xml_parent = simplexml_import_dom( $child->ownerDocument );
    }

    public static function replace_xml( &$xml_parent, $value ) {
      $parent = dom_import_simplexml( $xml_parent );
      $value = "<value>" . $value . "</value>";
      $child = dom_import_simplexml( simplexml_load_string( $value ) );
      foreach( $parent->childNodes as $child ) {
        $parent->removeChild( $child );
      }
      $child = $parent->ownerDocument->importNode( $child, true );
      $parent->appendChild( $child );
      $xml_parent = simplexml_import_dom( $parent );
    }
		
		public static function input( $id, $default, $skip = 0 ) {
			if( !( $skip & SKIP_POST ) && isset( $_POST[$id] ) ) {
				return ( get_magic_quotes_gpc() ) ? stripslashes( $_POST[$id] ) : $_POST[$id];
			}
			if( !( $skip & SKIP_GET ) && isset( $_GET[$id] ) ) {
				return ( get_magic_quotes_gpc() ) ? stripslashes( $_GET[$id] ) : $_GET[$id];
			}
			return $default;
		}
		
		public static function file( $id ) {
			if( isset( $_FILES[$id] ) ) {
				return $_FILES[$id];
			}
			return false;
		}
		
		public static function copy_file( $id, $folder, $name = '' ) {
			if( $file = self::file( $id ) ) {
				$new_file = $folder;
				if( strlen( $name ) > 0 ) {
					$new_file .= "/" . $name;
				} else {
					$new_file .= "/" . $file['name'];
				}
				if( move_uploaded_file( $file['tmp_name'], $new_file ) ) {
					return true;
				}
			}
			return false;		
		}
		
		public static function cookie( $id ) {
			if( isset( $_COOKIE[$id] ) ) {
				return $_COOKIE[$id];
			}
			return false;
		}

    public static function create_tag( $title ) {
      $tag = strtolower( str_replace( " ", "-", $title ) );
      $tag = preg_replace( "/[^\w\d\-]/", "", $tag );
      $tag = preg_replace( "/[-]+/", "-", $tag );
      return $tag;
    }
		
		public static function random_chars( $length ) {
			$sequence = "";
			while( strlen( $sequence ) < $length ) {
				$rand = rand( 0, 61 );
				if( $rand < 10 ) {
					$rand += 58-10;
				} else if( $rand < 36 ) {
					$rand += 91-36;
				} else if( $rand < 62 ) {
					$rand += 123-62;
				}
				$sequence .= chr( $rand );
			}
			return $sequence;
		}

    public static function create_datetime( $time ) {
      return gmdate( "Y-m-d" , $time ) . "T" . gmdate( "H:i:s", $time ) . "Z";
    }

    public static function create_duration( $time1, $time2 ) {
      $duration = abs( $time2 - $time1 );
      if( $duration < 0 ) {
        return "P0Y0M0DT0H2M0S";
      }
      $year = 60 * 60 * 24 * 365;
      $years = floor( $duration / $year );
      $duration %= $year;

      $month = 60 * 60 * 24 * 30;
      $months = floor( $duration / $month );
      $duration %= $month;

      $day = 60 * 60 * 24;
      $days = floor( $duration / $day );
      $duration %= $day;

      $hour = 60 * 60;
      $hours = floor( $duration / $hour );
      $duration %= $hour;

      $minute = 60;
      $minutes = floor( $duration / $minute );
      $duration %= $minute;

      $seconds = $duration;

      return "P" . $years . "Y" . $months . "M" . $days . "DT" . $hours . "H" . $minutes . "M" . $seconds . "S";
    }
		
		public static function redirect( $url ) {
			header( "Location: " . $url );
			exit();
		}

    public function xml_escape( $text ) {
      $text = str_replace( "&", "&amp;", $text );
      $text = str_replace( "<", "&lt;", $text );
      $text = str_replace( ">", "&gt;", $text );
      return $text;
    }

    public static function clean_xml( $text ) {
      /*$config = array(
        'output-xml' => true,
        'input-xml' => true,
        'wrap' =>    '0'
      );
      $tempstring = "";
      while( strlen( $tempstring ) < 20 ) {
        $tempstring .= chr( rand( 65, 90 ) );
      }
      $text = preg_replace( "/&([\w#].*);/", "", $text );
      $text = preg_replace( "/\<[#\$!?\-]/", "", $text );
      $text = preg_replace( "/[#\$!?\-]>/", "", $text );
      $text = preg_replace( "/> /", ">[$tempstring]", $text );
      $text = preg_replace( "/[\n]/", "$tempstring", $text );
      $tidy = new tidy();
      $tidy->parseString("<$tempstring" . "-tag>" . $text . "</$tempstring" . "-tag>", $config, 'utf8');
      $tidy->cleanRepair();
      $return = tidy_get_output($tidy);
      $return = str_replace( "<$tempstring" . "-tag>", "", $return );
      $return = str_replace( "</$tempstring" . "-tag>", "", $return );
      $return = preg_replace( "/[\n\r]/", "", $return );
      $return = str_replace( "[$tempstring]", " ", $return );
      $return = str_replace( "$tempstring", "\r\n", $return );
      return $return;*/
      return $text;
    }

    private static $timezone = NULL;
    public static function timezone( $timezone ) {
      if( self::$timezone == NULL && $timezone != NULL ) {
        /*date_default_timezone_set( DEFAULT_TIMEZONE );
        $dst = date("I",time());
        date_default_timezone_set( "UTC" );
        if( $dst ) {
          $timezone = (int)$timezone;
          $timezone += 1;
        }*/
        self::$timezone = (int)$timezone;
        return (int)$timezone;
      } else {
        return self::$timezone;
      }
    }
		
	}

?>
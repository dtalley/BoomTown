<?php

	class action {
		
		private static $actionxml;
    private static $xpath;
		private static $currentxml;
		private static $currentlevel = 0;
		private static $openxml;
		private static $openlevel;
		
		private static $called = array();
		
		public static function call( $extension, $action ) {
			$extension .= '';
			$action .= '';
			if( !isset( self::$called[$extension] ) ) {
				self::$called[$extension] = array();
			}
			if( !isset( self::$called[$extension][$action] ) ) {
				self::$called[$extension][$action] = true;
				sys::hook( "action_called", $extension, $action );
        $total_args = func_num_args();
        $arg_list = array();
        for( $i = 2; $i < $total_args; $i++ ) {
          $arg_list[] = func_get_arg( $i );
        }
        call_user_func_array( $extension . "::" . $action, $arg_list );
			}
		}

    public static function xpath( $string, $offset = -1 ) {
      if( !self::$actionxml ) {
				self::flush();
			}
      $response = self::$xpath->query( "/response" . ( $string ? "/" . $string : "" ) );
      $node = NULL;
      $total_nodes = 0;
      if( $response ) {
        $return = array();
        foreach( $response as $node ) {
          if( $offset >= 0 && $total_nodes == $offset ) {
            return $node;
          }
          $total_nodes++;
          $return[] = $node;
        }
        if( count( $return ) > 1 ) {
          return $return;
        } else if( count( $return ) == 1 ) {
          return $return[0];
        }
      }
      return false;
    }

		public static function get( $path, $offset = -1 ) {
      if( !self::$actionxml ) {
				self::flush();
			}
      $response = self::$xpath->query( "/" . ($path?"response/":"") . $path );
      $nodes = array();
      $total_nodes = 0;
      foreach( $response as $node ) {
        if( $offset >= 0 && $total_nodes == $offset ) {
          return $node->textContent;
        }
        $nodes[] = $node->textContent;
        $total_nodes++;
      }
      if( count( $nodes ) > 0 ) {
        return $nodes[count($nodes)-1];
      }
			return false;
		}

    public static function set( $path, $value, $offset = -1 ) {
      if( !self::$actionxml ) {
				self::flush();
			}
      if( !self::get( $path ) ) {
        self::resume( $path );
        self::end();
      }
      if( $offset >= 0 && self::total( $path ) < $offset + 1 ) {
        $split = explode( "/", $path );
        $child = array_pop( $split );
        $parent = implode( "/", $split );
        self::resume( $parent );
          for( $i = 0; $i < ( $offset + 1 ) - self::total( $path ); $i++ ) {
            self::start( $child );
            self::end();
          }
        self::end();
      }
      $response = self::get( $path, $offset );
      $response->removeChild( $response->firstChild );
      $response->appendChild( new DOMText( self::escale( $value ) ) );
    }

    public static function remove( $path, $offset = -1 ) {
      if( !self::$actionxml ) {
				self::flush();
			}
      $response = self::xpath( $path, $offset );
      if( !is_bool( $response ) ) {
        $response->parentNode->removeChild( $response );
      }
    }

    public static function merge( $xml, $path, $offset = -1 ) {
      if( !self::$actionxml ) {
				self::flush();
			}
      if( $path ) {
        self::resume( $path );
        self::end();
      }
      $response = self::xpath( $path, $offset );
      $to_add = dom_import_simplexml( $xml );
      $to_add = self::$actionxml->importNode( $to_add, true );
      if( !is_bool( $response ) ) {
        $response->appendChild( $to_add );
      } else if( !$path ) {
        self::$actionxml->documentElement->appendChild( $to_add );
      }
    }

    public static function sequence( $path, $var, $default ) {
      /*$total = self::total( $path );
      for( $i = 0; $i < $total; $i++ ) {
        if( self::get( $path, $i ) == $var ) {
          return self::get( $path, $i+1 );
        }
      }
      return $default;*/
      return $default;
    }
		
		public static function total( $path ) {
      if( !self::$actionxml ) {
				self::flush();
			}
      $response = self::$xpath->evaluate( "/" . ($path ? "response/" : "") . $path );
			if( $response ) {
				return $response->length;
			}
			return 0;
		}
		
		public static function start( $name, $root = false ) {
			if( !self::$actionxml ) {
				self::flush();
			}
			self::$currentlevel++;
      self::$currentxml[self::$currentlevel] = self::$actionxml->createElement( $name );
      if( $root ) {
        self::$actionxml->documentElement->appendChild( self::$currentxml[self::$currentlevel] );
      } else {
        self::$currentxml[self::$currentlevel-1]->appendChild( self::$currentxml[self::$currentlevel] );
      }
		}
		
		public static function resume( $path, $offset = -1 ) {
			if( !self::$actionxml ) {
				self::flush();
			}
			$response = self::xpath( $path, $offset );
			if( is_bool( $response ) ) {
				$path_exists = false;
				$path_split = explode( "/", $path );
				$length = count( $path_split );
				$total = $length;
				while( !$path_exists && $length > 0 ) {
					$new_path = "";
					for( $i = 0; $i < $length; $i++ ) {
						if( $i > 0 ) {
							$new_path .= "/";
						}
						$new_path .= $path_split[$i];
					}
					if( $new_path ) {
						$response = self::xpath( $new_path );
					}
					if( $response ) {
						$path_exists = true;
					} else {
						$length--;
					}
					$total = count( $path_split ) - $length;
				}
				$end_add = 0;
				if( !is_bool( $response ) ) {
					self::$currentlevel++;
					self::$currentxml[self::$currentlevel] = $response;
					$end_add = 1;
				}
				for( $i = $length; $i < count( $path_split ); $i++ ) {
          if( $i == 0 ) {
            self::start( $path_split[$i], true );
          } else {
            self::start( $path_split[$i] );
          }
				}
				for( $i = 0; $i < $total + $end_add; $i++ ) {
					self::end();
				}
				$response = self::xpath( $path );
			}
			if( !is_bool( $response ) ) {
				self::$currentlevel++;
				self::$currentxml[self::$currentlevel] = $response;
			} else {
				sys::message( SYSTEM_ERROR, lang::phrase( "main/invalid_path_error/title" ), lang::phrase( "main/invalid_path_error/body", $path ), __FILE__, __LINE__, __FUNCTION__, __CLASS__ );
			}
		}
		
		public static function add( $name, $value = "" ) {
			if( !self::$actionxml ) {
				self::flush();
			}
      $add = self::$currentxml[self::$currentlevel]->ownerDocument->createElement( $name );
      $add->appendChild( new DOMText( self::escape( $value ) ) );
      self::$currentxml[self::$currentlevel]->appendChild( $add );
		}
		
		private static function escape( $value ) {
			/*$value = str_replace( "&lt;", "\$#60;", $value );
			$value = str_replace( "&gt;", "\$#62;", $value );
			$value = str_replace( "&", "&amp;", $value );
			$value = str_replace( "\$#", "&#", $value );
			$value = str_replace( "'", "&#39;", $value );
			$value = str_replace( "\"", "&#34;", $value );*/
      return $value;
		}
		
		public static function end() {
			if( !self::$actionxml ) {
				self::flush();
			}
			self::$currentlevel--;
			if( self::$currentlevel < 0 ) { 
				self::$currentlevel = 0;
			}
		}
		
		public static function flush() {
			self::$actionxml = new DOMDocument();
      self::$actionxml->loadXML( "<?xml version=\"1.0\" encoding=\"UTF-8\"?><response></response>" );
      self::$xpath = new DOMXPath( self::$actionxml );
			self::$currentxml = array( self::$actionxml->documentElement );
			self::$currentlevel = 0;
		}

    public static function clear() {
      self::$actionxml = NULL;
      while( self::$currentlevel > 0 ) {
        self::$currentxml[self::$currentlevel] = NULL;
        self::$currentlevel--;
      }
      self::$currentxml = NULL;
      self::$currentlevel = NULL;
    }

    public static function close() {
      self::$currentlevel = 0;
    }
		
		public static function response() {
			return self::$actionxml;
		}
		
	}

?>
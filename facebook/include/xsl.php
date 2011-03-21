<?php

	class xsl {

    private static $locators_parsed = false;
    private static $locators_saved = false;
    private static $locator_id = "";
    private static $locator_nodes = 0;
    private static $locator_keys = 0;
    private static $locator_values = 0;
    private static $locator_keys_used = array();

    private static $verification = array();

    public static function comprehensive_exists( $id, $root ) {
      $cache_file = self::get_comprehensive_file( $id, $root );
      $counter = 0;
      while( $counter < 10 && file_exists( $cache_file . ".tmp" ) ) {
        usleep(10000);
        $counter++;
      }
      if( $counter >= 10 ) {
        sys::message(
          SYSTEM_ERROR,
          lang::phrase( "error/xsl/comprehensive_file_blocked/title" ),
          lang::phrase( "error/xsl/comprehensive_file_blocked/body", $page_file ),
          __FILE__, __LINE__, __FUNCTION__, __CLASS__
        );
      }
      return file_exists( $cache_file );
    }
		
		public static function load_xsl( $id, $root ) {
      if( substr( $root, -1 ) != "/" ) {
        $root .= "/";
      }
			$template_file = $root . $id . ".xsl";
      if( file_exists( $template_file ) ) {
        $_xsl = simplexml_load_file( $template_file );
      } else {
        sys::message(
          SYSTEM_ERROR,
          lang::phrase( "error/xsl/template_not_found/title" ),
          lang::phrase( "error/xsl/template_not_found/body", $template_file ),
          __FILE__, __LINE__, __FUNCTION__, __CLASS__
        );
      }
      if( $_xsl ) {
        return $_xsl;
      } else {
        sys::message(
          SYSTEM_ERROR,
          lang::phrase( "error/xsl/could_not_load_base_template/title" ),
          lang::phrase( "error/xsl/could_not_load_base_template/body", $id ),
          __FILE__, __LINE__, __FUNCTION__, __CLASS__
        );
      }
		}

    public static function create_comprehensive( $id, $root, &$xsl, $create_file = true ) {
      $requirements = array();
      $removals = array();
      foreach( $xsl->children( "magasi", true ) as $node ) {
        if( $node->getName() == "require" ) {
          if( !in_array( $node."", $requirements ) ) {
            self::require_template( $id, $root, $xsl, $node."" );
            $requirements[] = $node."";
          }
          $removals[] = dom_import_simplexml( $node );
        }
      }
      $total_removals = count( $removals );
      for( $i = 0; $i < $total_removals; $i++ ) {
        $removals[$i]->parentNode->removeChild( $removals[$i] );
      }
      $total_dependencies = 0;
      foreach( $xsl->xpath( "//magasi:*" ) as $node ) {
        foreach( $node->dependency as $dependency ) {
          $total_dependencies++;
        }
      }
      if( $create_file ) {
        $output = $xsl->asXML();
        if( $total_dependencies == 0 ) {
          $output = str_replace( "prexsl:", "xsl:", $output );
          $output = preg_replace( "/{{(.*?)}}/si", "\{$1\}", $output );
        }
        $output = self::minify_markup( $output );
        $cache_file = self::get_comprehensive_file( $id, $root );
        $file = fopen( $cache_file . ".tmp", 'w' );
        if( $file ) {
          fwrite( $file, $output );
          fclose( $file );
        }
        if( file_exists( $cache_file ) ) {
          unlink( $cache_file );
        }
        rename( $cache_file . ".tmp", $cache_file );
      }
    }

    private static function minify_markup( $output ) {
      $output = preg_replace( "/>(\s+)</si", "><", $output );
      $output = preg_replace( "/>(\s+)([^\s<])/si", "> $2", $output );
      $output = preg_replace( "/([^\s>])(\s+)</si", "$1 <", $output );
      $output = preg_replace( "/\n/si", "", $output );
      $output = preg_replace( "/\r/si", "", $output );
      $output = preg_replace( "/\r\n/si", "", $output );
      $output = preg_replace( "/\t/si", "", $output );
      $output = preg_replace( "/\/\*(.*?)\*\//si", "", $output );
      $output = preg_replace( "/\<!--(.*?)-->/si", "", $output );
      $output = preg_replace( "/(\s*){(\s+)/si", "{ ", $output );
      $output = preg_replace( "/(\s+)}(\s*)/si", " }", $output );
      $output = preg_replace( "/(\s*);(\s+)/si", "; ", $output );
      return $output;
    }

    public static function require_template( $id, $root, &$xsl, $require ) {
      $file = $root . "/" . $require . ".xsl";
      if( file_exists( $file ) ) {
        $addition = simplexml_load_file( $file );        
        self::create_comprehensive( $id, $root, $addition, false );        
        foreach( $addition->children( "magasi", true ) as $node ) {
          sys::append_xml( $xsl, $node );
        }
        foreach( $addition->children( "xsl", true ) as $node ) {
          sys::append_xml( $xsl, $node );
        }
      } else {
        sys::message(
          SYSTEM_ERROR,
          lang::phrase( "error/xsl/invalid_requirement/title" ),
          lang::phrase( "error/xsl/invalid_requirement/body", $id, $require )
        );
      }
		}

    public static function load_comprehensive( $id, $root ) {
      $cache_file = self::get_comprehensive_file( $id, $root );
      if( file_exists( $cache_file ) ) {
        $_xsl = simplexml_load_file( $cache_file );
      } else {
        sys::message(
          SYSTEM_ERROR,
          lang::phrase( "error/xsl/comprehensive_template_not_found/title" ),
          lang::phrase( "error/xsl/comprehensive_template_not_found/body", $id ),
          __FILE__, __LINE__, __FUNCTION__, __CLASS__
        );
      }
      if( $_xsl ) {
        return $_xsl;
      } else {
        sys::message(
          SYSTEM_ERROR,
          lang::phrase( "error/xsl/could_not_load_comprehensive_template/title" ),
          lang::phrase( "error/xsl/could_not_load_comprehensive_template/body", $cache_file ),
          __FILE__, __LINE__, __FUNCTION__, __CLASS__
        );
      }
		}

    public static function get_comprehensive_file( $id, $root ) {
      $file_id = str_replace( "/", ".", $id );
      $style_id = str_replace( "/", ".", $root );
      $file_name = preg_replace( "/^(\.+)/si", "", $style_id ) . ( $style_id ? "." : "" ) . preg_replace( "/^(\.+)/si", "", $file_id );
      $file_name = preg_replace( "/[^\w\d\-.]/si", "", $file_name );
      $cache_file = "cache/templates/tpl_" . $file_name . ".xsl";
      return $cache_file;
    }

    public static function page_exists( $id, $root ) {
      $page_file = self::get_page_file();
      $counter = 0;
      while( $counter < 10 && file_exists( $page_file . ".tmp" ) ) {
        sleep(1);
        $counter++;
      }
      $exists = file_exists( $page_file );
      if( !$exists ) {
        return false;
      }
      $page_stat = stat( $page_file );
      $comprehensive_stat = stat( self::get_comprehensive_file( $id, $root ) );
      if( $comprehensive_stat['mtime'] > $page_stat['mtime'] ) {
        return false;
      }
      $counter = 0;
      while( $counter < 10 && file_exists( $page_file . ".tmp" ) ) {
        usleep(10000);
        $counter++;
      }
      if( $counter >= 10 ) {
        sys::message(
          SYSTEM_ERROR,
          lang::phrase( "error/xsl/page_file_blocked/title" ),
          lang::phrase( "error/xsl/page_file_blocked/body", $page_file ),
          __FILE__, __LINE__, __FUNCTION__, __CLASS__
        );
      }
      return true;
    }

    public static function get_page_file() {
      $self = trim( action::get( "request/self" ) );
      $vars = explode( "?", $self );
      $self = $vars[0];
      $vars = explode( "#", $self );
      $self = $vars[0];
      while( substr( $self, -1, 1 ) == "/" ) {
        $self = substr( $self, 0, strlen( $self ) - 1 );
      }
      while( substr( $self, 0, 1 ) == "/" ) {
        $self = substr( $self, 1, strlen( $self ) );
      }
      if( !$self ) {
        $self = "index";
      }
      $self = str_replace( "/", ".", $self );
      $self = str_replace( "?", "-_-", $self );
      $page_file = "cache/pages/" . $self . ".xsl";
      return $page_file;
    }

    public static function create_page( &$xsl, $create_file = true ) {
      $children = $xsl->xpath( "//magasi:*" );
      $cache = array();
      $requests = array();
      $associations = array();
      $inputs = array();
      $locators = array();
      $total_dependencies = 0;
      if( !$children ) {
        return false;
      }
      foreach( $children as $node ) {
        /**
         * Pull out all of the magasi:cache elements from the stylesheet.
         * We'll add them back in later.
         */
        if( $node->getName() == "cache" ) {
          $element = dom_import_simplexml( $node );
          $replacement = $element->cloneNode( true );
          $cache[$node['id'].''] = $replacement;

        /**
         * Pull out all of the magasi:request elements from the stylesheet that
         * have dependencies.  We'll add them back in later.
         */
        } else if( $node->getName() == "request" ) {
          $nodes = $node->xpath( "dependency" );
          $total_dependencies += count( $nodes );
          if( $nodes && count( $nodes ) > 0 ) {
            $requests[] = dom_import_simplexml( $node );
          }

        /**
         * Pull out all of the magasi:association elements from the stylesheet.
         * We'll add them into the page template later.
         */
        } else if( $node->getName() == "association" ) {
          $nodes = $node->xpath( "dependency" );
          $total_dependencies += count( $nodes );
          if( $nodes && count( $nodes ) > 0 ) {
            $associations[] = dom_import_simplexml( $node );
          }
        
        /**
         * Pull out all of the magasi:input elements from the stylesheet.
         * We'll add them into the page template later.
         */
        } else if( $node->getName() == "input" ) {
          $inputs[] = dom_import_simplexml( $node );
        }
      }
      
      /**
       * If none of the request elements on the page have a dependency, there's
       * no need to create a cached page and we can just use the comprehensive
       * template.
       */
      if( !$total_dependencies ) {
        return false;
      }

      /**
       * Parse the template and then convert all prexsl namespaced elements
       * into xsl namespaced elements, and convert all parsed magasi:cache
       * elements into magasi:output elements.
       */
      self::parse_xsl( $children );
      $processor = self::create_processor();
      $processor->importStylesheet( $xsl );
      $output = $processor->transformToXml( action::response() );
      $output = str_replace( "prexsl", "xsl", $output );
      $output = str_replace( "premagasi:", "magasi:", $output );
      $output = str_replace( "magasi:cache", "magasi:output", $output );
      $xsl = simplexml_load_string( $output );

      /**
       * Run through all of the stored locator values and add them as input
       * elements, so each page template will have all of the proper $_REQUEST
       * values already populated.
       */
      foreach( self::$locator_values as $key => $val ) {
        $text = "<magasi:input xmlns:magasi=\"http://www.magasi-php.com/magasi\">";
        $text .= "<" . $key . ">" . $val . "</" . $key . ">";
        $text .= "</magasi:input>";
        $txml = simplexml_load_string( $text );
        $inputs[] = dom_import_simplexml( $txml );
      }
      self::$locator_values = array();

      /**
       * Run through all of the newly converted magasi:output elements, find
       * their associated cache block stored in the cache variable, and inject
       * the cache block into the new template right before the output block.
       */
      $children = $xsl->xpath( "//magasi:*" );
      $output_replacements = array();
      foreach( $children as $node ) {
        if( $node->getName() == "output" ) {
          $output_replacements[] = dom_import_simplexml( $node );
        }
      }
      foreach( $output_replacements as $parsed ) {
        if( isset( $cache[$parsed->getAttribute("id")] ) ) {
          $cache_node = $cache[$parsed->getAttribute("id")];
          if( !$parsed->getAttribute("locator") || $parsed->getAttribute("locator")."" == self::$locator_id."" ) {
            $cache_copy = $parsed->ownerDocument->importNode( $cache_node, true );
            $parsed->parentNode->insertBefore( $cache_copy, $parsed );
          }
          $cache[$parsed->getAttribute("id")] = NULL;
        }
      }

      /**
       * Load a blank XSL template that we can use to build our individual page
       * template.
       */
      if( $create_file ) {
        $blank = DOMDocument::load( INCLUDE_DIR . "/xsl/blank.xsl" );
        $content = dom_import_simplexml( $xsl );
        $copy = $blank->importNode( $content, true );
        foreach( $blank->documentElement->childNodes as $child ) {
          if( $child->localName == "template" ) {

            /**
             * Inject all of the elements in our outputted template into the
             * blank template's main template block.
             */
            foreach( $content->childNodes as $node ) {
              $copy = $blank->importNode( $node, true );
              $child->appendChild( $copy );
            }

            /**
             * Run through all of the stored request elements, check to see if
             * they have locator flags, and if they do, check to make sure at
             * least one of them matches the page's locator id.  If the
             * request has locator flags, and none of them match, don't inject
             * it into the new template.
             */
            foreach( $requests as $request ) {
              self::parse_paths( simplexml_import_dom( $request ) );
              $locator_found = false;
              $total_locators = 0;
              foreach( $request->childNodes as $req ) {
                if( $req->localName == "locator" ) {
                  $total_locators++;
                  if( $req->textContent."" == self::$locator_id."" ) {
                    $locator_found = true;
                    break;
                  }
                }
              }
              if( !$total_locators || $locator_found ) {
                $copy = $blank->importNode( $request, true );
                $child->parentNode->insertBefore( $copy, $child );
              }
            }

            /**
             * Run through all of the stored association elements, check to see
             * if they have locator flags, and compare all of them to the page's
             * locator id.  If it matches, or if there are no flags, inject it
             * into the new template.
             */
            foreach( $associations as $association ) {
              self::parse_paths( simplexml_import_dom( $association ) );
              $locator_found = false;
              $total_locators = 0;
              foreach( $association->childNodes as $req ) {
                if( $req->localName == "locator" ) {
                  $total_locators++;
                  if( $req->textContent."" == self::$locator_id."" ) {
                    $locator_found = true;
                    break;
                  }
                }
              }
              if( !$total_locators || $locator_found ) {
                $copy = $blank->importNode( $association, true );
                $child->parentNode->insertBefore( $copy, $child );
              }
            }

            /**
             * Run through all of the stored input elements and inject them into
             * the new page template.
             */
            foreach( $inputs as $input ) {
              $copy = $blank->importNode( $input, true );
              $child->parentNode->insertBefore( $copy, $child );
            }

            $locator = DOMDocument::loadXML( "<magasi:locators xmlns:magasi=\"http://www.magasi-php.com/magasi\"><static>" . self::$locator_id . "</static></magasi:locators>" );
            $copy = $blank->importNode( $locator->documentElement, true );
            $child->parentNode->insertBefore( $copy, $child );
            break;
          }
        }        
        $output = $blank->saveXML();
        
        /**
         * Replace all of the improperly closed script tags, because apparently
         * browsers can't understand <script /> and need them all formatted
         * as <script></script>
         */
        $output = preg_replace( "/<script([^><]*?)\/>/si", "<script$1></script>", $output );
        $output = self::minify_markup( $output );
        
        $page_file = self::get_page_file();
        $file = fopen( $page_file . ".tmp", 'w' );
        if( $file ) {
          fwrite( $file, $output );
          fclose( $file );
        }
        if( file_exists( $page_file ) ) {
          unlink( $page_file );
        }
        rename( $page_file . ".tmp", $page_file );
      }
      return true;
    }

    /**
     * Pull out all of the magasi:path elements from an xml fragment and
     * replace them with their equivalent values from the current data set.
     */
    private static function parse_paths( $xsl ) {
      $paths = $xsl->xpath( "//magasi:path" );
      foreach( $paths as $path ) {
        $use_path = $path["value"] . "";
        $value = action::get( $use_path );
        $text = new DOMText( $value );
        $path_node = dom_import_simplexml( $path );
        $copy = $path_node->ownerDocument->importNode( $text, true );
        $path_node->parentNode->insertBefore( $copy, $path_node );
        $path_node->parentNode->removeChild( $path_node );
      }
    }

    public static function load_page() {
      $page_file = self::get_page_file();
      if( file_exists( $page_file ) ) {
        $_xsl = simplexml_load_file( $page_file );
      } else {
        sys::message(
          SYSTEM_ERROR,
          lang::phrase( "error/xsl/page_template_not_found/title" ),
          lang::phrase( "error/xsl/page_template_not_found/body", $id ),
          __FILE__, __LINE__, __FUNCTION__, __CLASS__
        );
      }
      if( $_xsl ) {
        return $_xsl;
      } else {
        sys::message(
          SYSTEM_ERROR,
          lang::phrase( "error/xsl/could_not_load_page_template/title" ),
          lang::phrase( "error/xsl/could_not_load_page_template/body", $cache_file ),
          __FILE__, __LINE__, __FUNCTION__, __CLASS__
        );
      }
		}

    private static function create_processor() {
      $processor = new XSLTProcessor();
      $processor->registerPHPFunctions( array(
        "xsl::convert_datetime",
        "xsl::convert_datetime_offset",
        "xsl::create_period",
        "xsl::create_cdata",
        "xsl::years_from_duration",
        "xsl::months_from_duration",
        "xsl::days_from_duration",
        "xsl::hours_from_duration",
        "xsl::minutes_from_duration",
        "xsl::seconds_from_duration",
        "xsl::get_root",
        "xsl::get_style_dir",
        "xsl::get_request_var",
        "xsl::file_exists",
        "xsl::filesize",
        "xsl::escape_xml",
        "xsl::url_encode",
        "xsl::phrase",
        "action::call",
        "xsl::match_path"
      ) );
      return $processor;
    }
		
		public static function parse_xsl( &$xsl, $check_dependencies = false ) {
      $associations = array();
      $requests = array();
      $loops = array();
      $dependencies = array();
      foreach( $xsl as $node ) {
        //LOOPS
        if( $node->getName() == "loop" ) {
          if( !$check_dependencies || isset( $node['static'] ) ) {
            $locators = array();
            foreach( $node->locator as $locator ) {
              $locators[] = $locator.'';
            }
            $extension = $node->extension;
            $action = $node->action;
            $key = $extension . "::" . $action;
            if( !isset( $loops[$key] ) ) {
              $loops[$key] = array();
              $loops[$key]['targets'] = array();
              $loops[$key]['extension'] = $extension;
              $loops[$key]['action'] = $action;
              $loops[$key]['locators'] = $locators;
              $loops[$key]['path'] = $node->path;
              $has_dependencies = false;
              if( $check_dependencies ) {
                if( $node->dependency ) {
                  $has_dependencies = true;
                }
              }
              $loops[$key]['dependencies'] = $has_dependencies;
            }
            if( $node->target ) {
              $loops[$key]['targets'][] = $node->target."";
            }
          }
        //ASSOCIATIONS
        } else if( $node->getName() == "association" ) {
          $locators = array();
          foreach( $node->locator as $locator ) {
            $locators[] = $locator.'';
          }
          $has_dependencies = false;
          if( $check_dependencies ) {
            if( $node->dependency ) {
              $has_dependencies = true;
            }
          }
          $associations[] = array(
            "locators" => $locators,
            "primary" => $node->primary,
            "secondary" => $node->secondary,
            "primary_path" => $node->primary_path,
            "secondary_path" => $node->secondary_path,
            "dependencies" => $has_dependencies
          );
        //LOCATORS
        } else if( $node->getName() == "locators" ) {
          self::parse_locators( $node );
        //REQUESTS
        } else if( $node->getName() == "request" ) {
          $locators = array();
          foreach( $node->locator as $locator ) {
            $locators[] = $locator.'';
          }
          $keys = array();
          foreach( $node->key as $key ) {
            $keys[] = $key.'';
          }
          $has_dependencies = false;
          if( $check_dependencies ) {
            if( $node->dependency ) {
              $has_dependencies = true;
            }
          }
          $requests[] = array(
            "priority" => $node->priority?(int)$node->priority:0,
            "extension" => $node->extension,
            "action" => $node->action,
            "locators" => $locators,
            "keys" => $keys,
            "dependencies" => $has_dependencies
          );
        //AUTHENTICATION
        } else if( $node->getName() == "authenticate" && action::get( "settings/enable_permissions" ) ) {
          if( !auth::test( $node->group, $node->permission ) && $node->type != "save" ) {
            $error_type = $node->type == "deny" ? SYSTEM_ERROR : AUTHENTICATION_ERROR;
            sys::message( 
              $error_type,
              lang::phrase( "authentication/denied" ),
              lang::phrase( "authentication/" . $node->group . "/" . $node->permission . "/denied" )
            );
          }
        //HOOKS
        } else if( $node->getName() == "hook" ) {
          sys::hook( $node.'' );
        //INPUT
        } else if( $node->getName() == "input" ) {
          foreach( $node->children() as $input ) {
            $_GET[$input->getName()] = $input.'';
          }
        //OUTPUT
        } else if( $node->getName() == "output" ) {
          if( $node['dependency'] ) {
            $dependencies[] = $node['dependency']."";
          }
        }
      }

      if( $check_dependencies ) {
        $page_stat = stat( self::get_page_file() );
        $stale_dependencies = tpl::check_dependencies( $dependencies, $page_stat['mtime'] );
        if( is_array( $stale_dependencies ) && count( $stale_dependencies ) > 0 ) {
          return $stale_dependencies;
        }
        $total_requests = count( $requests );
        for( $i = 0; $i < $total_requests; $i++ ) {
          if( $requests[$i]['dependencies'] ) {
            array_splice( $requests, $i, 1 );
            $i--;
            $total_requests--;
          }
        }
        foreach( $loops as $key => $loop ) {
          if( $loop['dependencies'] ) {
            $loops[$key] = NULL;
          }
        }
        $total_associations = count( $associations );
        for( $i = 0; $i < $total_associations; $i++ ) {
          if( $associations[$i]['dependencies'] ) {
            array_splice( $associations, $i, 1 );
            $i--;
            $total_associations--;
          }
        }
      }

      if( self::$locator_id && !self::$locators_saved ) {
        self::$locators_saved = true;
        action::resume( "template" );
          action::add( "locator", self::$locator_id );
          action::add( "nodes", self::$locator_nodes );
          action::add( "keys", self::$locator_keys );
          action::start( "variables" );
            if( self::$locator_values ) {
              foreach( self::$locator_values as $key => $val ) {
                $_GET[$key] = $val;
                action::add( $key, $val );
              }
            }
          action::end();
        action::end();
      }


      usort( $requests, "xsl::sort_requests" );
      $total_requests = count( $requests );
      for( $i = 0; $i < $total_requests; $i++ ) {
        $request = $requests[$i];
        $total_locators = count( $request['locators'] );
        $locators_found = 0;
        foreach( $request['locators'] as $locator ) {
          if( $locator == self::$locator_id.'' ) {
            $locators_found++;
          }
        }
        if( $total_locators && !$locators_found ) {
          continue;
        }
        $total_keys = count( $request['keys'] );
        $keys_found = 0;
        foreach( $request['keys'] as $key ) {
          foreach( self::$locator_keys_used as $used_key ) {
            if( $key == $used_key ) {
              $keys_found++;
            }
          }
        }
        if( $keys_found != $total_keys ) {
          continue;
        }
        action::call( $request['extension'], $request['action'] );
      }

      foreach( $associations as $association ) {
        $total_locators = count( $association['locators'] );
        $locators_found = 0;
        foreach( $association['locators'] as $locator ) {
          if( $locator == self::$locator_id.'' ) {
            $locators_found++;
          }
        }
        if( $total_locators && !$locators_found ) {
          continue;
        }
        assoc::append_associations( $association['primary'], $association['secondary'], $association['primary_path'], $association['secondary_path'] );
      }
      
      foreach( $loops as $loop ) {
        if( $loop == NULL ) {
          continue;
        }
        $total_locators = count( $loop['locators'] );
        $locators_found = 0;
        if( $total_locators ) {
          foreach( $loop['locators'] as $locator ) {
            if( $locator.'' == self::$locator_id.'' ) {
              $locators_found++;
            }
          }
          if( $total_locators && !$locators_found ) {
            continue;
          }
        }
        action::call( $loop['extension'], $loop['action'], $loop['path'], $loop['targets'] );
      }
		}
		
		private static function sort_requests( $a, $b ) {
			if( $a['priority'] > $b['priority'] ) {
				return -1;
			} else if( $a['priority'] == $b['priority'] ) {
        return 0;
      } else {
				return 1;
			}
		}

    private static function parse_locators( $xml ) {
      if( self::$locators_parsed ) {
        return;
      }
      self::$locators_parsed = true;
      $keys_counted = $keys_matched = $keys_required = 0;
      $nodes_counted = $nodes_matched = $nodes_required = 0;
      $total_vars = 0;
      foreach( $xml->locator as $locator ) {
        $id = $locator["id"];
        //Sort through the keys in the URI in reverse order
        //and determine which ones exist and which ones don't
        $keys_counted = $keys_matched = $keys_required = 0;
        $keys = array();
        $total_vars = action::total( "url_variables/var" );
        foreach( $locator->xpath( "key" ) as $key ) {
          /*if( $required = $key->xpath( "@required" ) ) {
            $keys_required++;
          }*/
          if( isset( $key['required'] ) ) {
            $keys_required++;
          }
          $type = $key['type'];
          $alias = $key['alias'];
          if( !$alias ) {
            $alias = $key;
          }
          for( $i = $total_vars-2; $i >= 0; $i-=2 ) {
            if( $key.'' == action::get( "url_variables/var", $i ) ) {
              $keys_matched++;
              self::$locator_keys_used[] = $key;
              if( $type == "int" ) {
                $keys[$alias.''] = (int)action::get( "url_variables/var", $i+1 );
              } else {
                $keys[$alias.''] = action::get( "url_variables/var", $i+1 );
              }
              break;
            }
          }
          $keys_counted++;
        }
        if( $keys_matched < $keys_required ) {
          continue;
        }
        //Sort through the nodes now that we know how many
        //keys are present and determine which URI nodes
        //match the current locator.
        $nodes_counted = $nodes_matched = $nodes_required = $vars_checked = $nodes_skipped = 0;
        $nodes = array();
        foreach( $locator->xpath( "node" ) as $node ) {
          $node_matched = false;
          $required = false;
          /*if( $required = $node->xpath( "@required" ) ) {
            $nodes_required++;
          }*/
          if( isset( $node['required'] ) ) {
            $nodes_required++;
          }
          if( $vars_checked < $total_vars - ( $keys_matched * 2 ) ) {
            $type = $node['type'];
            $value = action::get( "url_variables/var", $vars_checked );
            if( $value ) {
              if( $type ) {
                if( $type == "int" && ( (int)$value > 0 || $value.'' == "0" ) ) {
                  $nodes_matched++;
                  $node_matched = true;
                } else if( !$required ) {
                  $vars_checked--;
                  $nodes_skipped++;
                }
              } else {
                $node_matched = true;
                $nodes_matched++;
              }
            }
            if( $node_matched ) {
              $node_name = $node.'';
              $node_split = explode( ",", $node_name );
              $total_names = count( $node_split );
              for( $i = 0; $i < $total_names; $i++ ) {
                if( $type == "int" ) {
                  $nodes[$node_split[$i]] = (int)$value;
                } else {
                  $nodes[$node_split[$i]] = $value;
                }
              }
            }
          } else if( isset( $node['required'] ) ) {
            $nodes_matched--;
          }
          $vars_checked++;
          $nodes_counted++;
        }
        if( $nodes_matched < $nodes_required ) {
          continue;
        }
        $choose_locator = false;
        if( !self::$locator_id || $nodes_matched > self::$locator_nodes || ( $nodes_matched == self::$locator_nodes && $keys_matched > self::$locator_keys ) ) {
          $choose_locator = true;
        }
        if( $choose_locator ) {
          self::$locator_nodes = $nodes_matched;
          self::$locator_keys = $keys_matched;
          self::$locator_id = $id;
          self::$locator_values = array_merge( $nodes, $keys );
          break;
        }
      }
      foreach( $xml->static as $static ) {
        if( !self::$locator_id ) {
          self::$locator_id = $static."";
        }
      }
      if( $total_vars > $nodes_matched + ( $keys_matched * 2 ) ) {
        sys::message( NOTFOUND_ERROR, lang::phrase( "error/template/not_found/title" ), lang::phrase( "error/template/not_found/body" ) );
      }
      
    }

    public static function refresh_dependencies( $id, $root, $stale_dependencies, &$xsl ) {
      $requests = array();
      $associations = array();
      $loops = array();
      $caches = array();
      
      $children = $xsl->xpath( "//magasi:request | //magasi:loop | //magasi:association" );
      foreach( $children as $child ) {

        /**
         * Pull all of the requests out, and keep track of them if they
         * have any declared dependencies
         */
        if( $child->getName() == "request" ) {
          if( $child->dependency ) {
            $dependency_found = false;
            $request = array(
              "node" => dom_import_simplexml( $child ),
              "dependencies" => array()
            );
            foreach( $child->dependency as $dependency ) {
              if( in_array( $dependency."", $stale_dependencies ) ) {
                $dependency_found = true;
              }
              $request['dependencies'][] = $dependency."";
            }
            if( $dependency_found ) {
              $requests[] = $request;
            }
          }

        /**
         * Pull all of the loops out, and keep track of them if they
         * have any declared dependencies
         */
        } else if( $child->getName() == "loop" ) {
          if( $child->dependency ) {
            $dependency_found = false;
            $loop = array(
              "node" => dom_import_simplexml( $child ),
              "dependencies" => array()
            );
            foreach( $child->dependency as $dependency ) {
              if( in_array( $dependency."", $stale_dependencies ) ) {
                $dependency_found = true;
              }
              $loop['dependencies'][] = $dependency."";
            }
            if( $dependency_found ) {
              $loops[] = $loop;
            }
          }

        /**
         * Pull all of the associations out and keep track of them if they have
         * any declared dependencies
         */
        } else if( $child->getName() == "association" ) {
          if( $child->dependency ) {
            $dependency_found = false;
            $association = array(
              "node" => dom_import_simplexml( $child ),
              "dependencies" => array()
            );
            foreach( $child->dependency as $dependency ) {
              if( in_array( $dependency."", $stale_dependencies ) ) {
                $dependency_found = true;
              }
              $association['dependencies'][] = $dependency."";
            }
            if( $dependency_found ) {
              $associations[] = $association;
            }
          }
        }
      }
      
      /**
       * Pull all of the magasi:cache elements out and index them by their
       * declared ID.
       */
      $children = $xsl->xpath( "//magasi:cache" );
      foreach( $children as $child ) {
        $caches[$child['id'].""] = $child;
      }
      
      /**
       * Now we do a main run through of all of the magasi:output elements, and
       * replace them with the output of their corresponding magasi:cache
       * element if they are outdated.
       */
      $children = $xsl->xpath( "descendant::magasi:output" );
      $total_children = count( $children );
      for( $i = 0; $i < $total_children; $i++ ) {
        $child = $children[$i];
        // We only need to consider them if they have a dependency
        if( isset( $child['dependency'] ) ) {
          $dependency = $child['dependency']."";
          // We also only need to consider them if they have a stale dependency
          if( in_array( $dependency, $stale_dependencies ) ) {
            $id = $child['id']."";
            if( isset( $caches[$id] ) ) {
             
              $domoutput = dom_import_simplexml( $child );
              $domcache = dom_import_simplexml( $caches[$id] );
              $domcache = $domcache->cloneNode( true );
             
              $output_subtrees = $child->xpath( "descendant::magasi:output" );
              foreach( $output_subtrees as $subtree ) {
                $subid = $subtree['id']."";
                if( isset( $caches[$subid] ) ) {
                  $caches[$subid] = NULL;
                }
              }
              /**
               * Pull the injections from the magasi:output element and inject
               * them as XSL variables into the magasi:cache element.
               */
              $injections = $child->xpath( "magasi:injection" );
              foreach( $injections as $injection ) {
                $cxml = "<xsl:variable xmlns:xsl=\"http://www.w3.org/1999/XSL/Transform\" name=\"" . $injection['name'] . "\">" . $injection . "</xsl:variable>";
                $sxml = simplexml_load_string( $cxml );
                $copy = $domcache->ownerDocument->importNode( dom_import_simplexml( $sxml ), true );
                $domcache->insertBefore( $copy, $domcache->firstChild );
              }

              $domcache->removeAttribute("dependency");
              /**
               * Load a blank XSL document that we can inject the magasi:cache
               * element into and parse it with the current data set.  This
               * makes it so that we only parse parts of a total template at
               * one time, instead of the entire thing.  Once it's parsed
               * we'll replace the magasi:output contents with the newly
               * generated contents from the magasi:cache element.
               */
              $domblank = DOMDocument::load( INCLUDE_DIR . "/xsl/blank.xsl" );
              $xmlblank = simplexml_import_dom( $domblank );
              foreach( $domblank->documentElement->childNodes as $template ) {
                if( $template->localName == "template" ) {
                  $copy = $domblank->importNode( $domcache, true );
                  $template->appendChild( $copy );
                }
              }
              $requirements = array();
              $dependencies = array();
              if( $caches[$id]['require'] ) {
                $require = $caches[$id]['require'];
                $reqsplit = explode( ",", $require."" );
                foreach( $reqsplit as $requirement ) {
                  if( !in_array( $requirement, $requirements ) ) {
                    $requirements[] = $requirement;
                  }
                }
              }
              $childcaches = $caches[$id]->xpath( "descendant::magasi:cache" );
              foreach( $childcaches as $childcache ) {
                if( $childcache['require'] ) {
                  if( !in_array( $childcache['require']."", $requirements ) ) {
                    $requirements[] = $childcache['require']."";
                  }
                }
                if( $childcache['dependency'] ) {
                  $dependencies[] = $childcache['dependency'];
                }
              }
              foreach( $requirements as $requirement ) {
                self::require_template( $id, $root, $xmlblank, $requirement."" );
              }
              $dependencies[] = $dependency;
              foreach( $requests as $request ) {
                if( in_array( $dependency, $request['dependencies'] ) ) {
                  $copy = $domblank->importNode( $request['node'], true );
                  $domblank->documentElement->appendChild( $copy );
                }
              }
              foreach( $loops as $loop ) {
                if( in_array( $dependency, $loop['dependencies'] ) ) {
                  $copy = $domblank->importNode( $loop['node'], true );
                  $domblank->documentElement->appendChild( $copy );
                }
              }
              foreach( $associations as $association ) {
                if( in_array( $dependency, $association['dependencies'] ) ) {
                  $copy = $domblank->importNode( $association['node'], true );
                  $domblank->documentElement->appendChild( $copy );
                }
              }
              /**
               * Now that all of our injections, requests, and loops have been
               * added to our cache block, we can parse it to populate the
               * necessary data
               */
              $parsable = simplexml_import_dom( $domblank );
              $parsables = $parsable->xpath( "//magasi:*" );
              self::parse_xsl( $parsables );

              /**
               * Now we can process our finalized cache block with the XSL
               * parser, and then replace the old output block with the
               * generated content.
               */
              $processor = self::create_processor();
              $processor->importStylesheet( $domblank );
              $content = $processor->transformToXml( action::response() );
              $content = str_replace( "prexsl", "xsl", $content );
              $content = str_replace( "premagasi:", "magasi:", $content );
              $content = str_replace( "magasi:cache", "magasi:output", $content );
              $cdom = DOMDocument::loadXML( $content );
              $removals = array();
              foreach( $domoutput->childNodes as $removal ) {
                $removals[] = $removal;
              }
              foreach( $removals as $removal ) {
                $domoutput->removeChild( $removal );
              }
              foreach( $cdom->documentElement->childNodes as $addition ) {
                $copy = $domoutput->ownerDocument->importNode( $addition, true );
                $domoutput->appendChild( $copy );
              }
            }
          }
        }
      }

      $output = $xsl->asXML();
      
      /**
       * Replace all of the improperly closed script tags, because apparently
       * browsers can't understand <script /> and need them all formatted
       * as <script></script>
       */
      $output = preg_replace( "/<script([^><]*?)\/>/si", "<script$1></script>", $output );
      $output = self::minify_markup( $output );

      $page_file = self::get_page_file();
      $file = fopen( $page_file . ".tmp", 'w' );
      if( $file ) {
        fwrite( $file, $output );
        fclose( $file );
      }
      if( file_exists( $page_file ) ) {
        unlink( $page_file );
      }
      rename( $page_file . ".tmp", $page_file );
    }
		
		public static function apply( $xml, $xsl, $check_dependencies = false ) {
      if( !$xml ) {
        return false;
      }
      if( !is_string( $xsl ) ) {
        $_xsl = $xsl;
      } else {
        $_xsl = simplexml_load_file( $xsl );
      }
      $namespaces = $_xsl->getNamespaces(true);
      $stale_dependencies = null;
      if( array_key_exists( "magasi", $namespaces ) ) {
        $children = $_xsl->xpath( "//magasi:*" );
        $stale_dependencies = self::parse_xsl( $children, $check_dependencies );
        if( is_array( $stale_dependencies ) && count( $stale_dependencies ) > 0 ) {
          return $stale_dependencies;
        }
        $removals = array();
        $replacements = array();
        foreach( $children as $child ) {
          if(
            $child->getName() == "cache" ||
            $child->getName() == "loop" ||
            $child->getName() == "injection"
          ) {
            $removals[] = dom_import_simplexml( $child );
          } else if( $child->getName() == "output" ) {
            $replacements[] = dom_import_simplexml( $child );
          }
        }
        foreach( $removals as $removal ) {
          $removal->parentNode->removeChild( $removal );
        }
        foreach( $replacements as $replacement ) {
          while( $replacement->firstChild != NULL ) {
            $removed = $replacement->removeChild( $replacement->firstChild );
            $replacement->parentNode->insertBefore( $removed, $replacement );
          }
          $replacement->parentNode->removeChild( $replacement );
        }
      }
      $proc = self::create_processor();
      $proc->importStylesheet( $_xsl );
      $parsed = $proc->transformToXML( $xml );
      //$parsed = str_replace( "&amp;", "&", $parsed );
			return $parsed;
		}
		
		public static function convert_datetime( $datetime, $format ) {
			$text = gmdate( $format, strtotime( $datetime ) );
			return self::return_as_node( $text );
		}

    public static function convert_datetime_offset( $datetime, $format ) {
      $time = strtotime( $datetime );
      $time += 60 * 60 * sys::timezone();
      $text = gmdate( $format, $time );
      return self::return_as_node( $text );
    }

    public static function create_period( $datetime ) {
      $timestamp = strtotime( $datetime );
      $difference = $odiff = time() - $timestamp;
      $year = 60 * 60 * 24 * 7 * 52;
      $month = 60 * 60 * 24 * 30;
      $week = 60 * 60 * 24 * 7;
      $day = 60 * 60 * 24;
      $hour = 60 * 60;
      $minute = 60;
      $years = floor( $difference / $year );
      $difference -= $years * $year;
      $months = floor( $difference / $month );
      $difference -= $months * $month;
      $weeks = floor( $difference / $week );
      $difference -= $weeks * $week;
      $days = floor( $difference / $day );
      $difference -= $days * $day;
      $hours = floor( $difference / $hour );
      $difference -= $hours * $hour;
      $minutes = floor( $difference / $minute );
      $difference -= $minutes * $minute;
      $seconds = $difference;
      if( $odiff > $year ) {
        return self::return_as_node( $years . " " . lang::phrase( "main/period/year" . ( $years > 1 ? "s" : "" ) . "_ago" ) );
      } else if( $odiff > $month ) {
        return self::return_as_node( $months . " " . lang::phrase( "main/period/month" . ( $months > 1 ? "s" : "" ) . "_ago" ) );
      } else if( $odiff > $week ) {
        return self::return_as_node( $weeks . " " . lang::phrase( "main/period/week" . ( $weeks > 1 ? "s" : "" ) . "_ago" ) );
      } else if( $odiff > $day ) {
        return self::return_as_node( $days . " " . lang::phrase( "main/period/day" . ( $days > 1 ? "s" : "" ) . "_ago" ) );
      } else if( $odiff > $hour ) {
        return self::return_as_node( $hours . " " . lang::phrase( "main/period/hour" . ( $hours > 1 ? "s" : "" ) . "_ago" ) );
      } else if( $odiff > $minute ) {
        return self::return_as_node( $minutes . " " . lang::phrase( "main/period/minute" . ( $minutes > 1 ? "s" : "" ) . "_ago" ) );
      } else if( $odiff > 0 ) {
        return self::return_as_node( $seconds . " " . lang::phrase( "main/period/second" . ( $seconds > 1 ? "s" : "" ) . "_ago" ) );
      } else {
        return self::return_as_node( lang::phrase( "main/period/just_now" ) );
      }
    }
		
		public static function create_cdata( $text ) {
			$text = "<![CDATA[" . $text . "]]>";
			return self::return_as_node( $text );
		}

    public static function years_from_duration( $duration ) {
      $duration_split = explode( "T", $duration.'' );
      preg_match( "/(\\d*?)Y/", $duration_split[0], $match );
      return self::return_as_node( $match[1] );
    }

    public static function months_from_duration( $duration ) {
      $duration_split = explode( "T", $duration.'' );
      preg_match( "/(\\d*?)M/", $duration_split[0], $match );
      return self::return_as_node( $match[1] );
    }

    public static function days_from_duration( $duration ) {
      $duration_split = explode( "T", $duration.'' );
      preg_match( "/(\\d*?)D/", $duration_split[0], $match );
      return self::return_as_node( $match[1] );
    }

    public static function hours_from_duration( $duration ) {
      $duration_split = explode( "T", $duration.'' );
      preg_match( "/(\\d*?)H/", $duration_split[1], $match );
      return self::return_as_node( $match[1] );
    }

    public static function minutes_from_duration( $duration ) {
      $duration_split = explode( "T", $duration.'' );
      preg_match( "/(\\d*?)M/", $duration_split[1], $match );
      return self::return_as_node( $match[1] );
    }

    public static function seconds_from_duration( $duration ) {
      $duration_split = explode( "T", $duration.'' );
      preg_match( "/(\\d*?)S/", $duration_split[1], $match );
      return self::return_as_node( $match[1] );
    }

    public static function get_root() {
      return self::return_as_node( RELATIVE_DIR );
    }

    public static function get_style_dir() {
      return self::return_as_node( tpl::get_style_dir() );
    }

    public static function file_exists( $file ) {
      return self::return_as_node( file_exists( $file ) ? '1' : '0' );
    }

    public static function filesize( $file ) {
      return self::return_as_node( filesize( $file ) );
    }

    public static function remote_filesize( $file ) {
      return self::return_as_node( filesize( $file ) );
    }

    public static function phrase( $text ) {
      return self::return_as_node( lang::phrase( $text ) );
    }

    public static function escape_xml( $text ) {
      $node = $text[0];
      $doc = $node->ownerDocument;
      $text = '';
      foreach( $node->childNodes as $child ) {
        $text .= $doc->saveXML($child);
      }
      $text = str_replace( "/>", " />", $text );
      $text = str_replace( "<", "&amp;amp;lt;", $text );
      $text = str_replace( ">", "&amp;amp;gt;", $text );
      return self::return_as_node( $text );
    }

    public static function url_encode( $text ) {
      $text = urlencode( $text );
      return self::return_as_node( $text );
    }

    public static function match_path( $needle, $haystack ) {
      if( !is_bool( strpos( $haystack, $needle ) ) ) {
        return self::return_as_node(1);
      }
      return self::return_as_node(0);
    }

    public static function get_request_var( $name ) {
      $ret = sys::input( $name, "" );
      return self::return_as_node( $ret );
    }

		private static function return_as_node( $text ) {
      return new DOMText( $text );
		}
		
	}

?>
<?php

  require_once( CONTENT_DIR . "/cdn.php" );

  define("MAGASI_CF_VERSION", "0.1");
  define("USER_AGENT", sprintf("Magasi-CloudFiles/%s", MAGASI_CF_VERSION));
  define("ACCOUNT_CONTAINER_COUNT", "X-Account-Container-Count");
  define("ACCOUNT_BYTES_USED", "X-Account-Bytes-Used");
  define("CONTAINER_OBJ_COUNT", "X-Container-Object-Count");
  define("CONTAINER_BYTES_USED", "X-Container-Bytes-Used");
  define("METADATA_HEADER", "X-Object-Meta-");
  define("CDN_URI", "X-CDN-Management-Url");
  define("CDN_ENABLED", "X-CDN-Enabled");
  define("CDN_LOG_RETENTION", "X-Log-Retention");
  define("CDN_ACL_USER_AGENT", "X-User-Agent-ACL");
  define("CDN_ACL_REFERRER", "X-Referrer-ACL");
  define("CDN_TTL", "X-TTL");
  define("CDNM_URL", "X-CDN-Management-Url");
  define("STORAGE_URL", "X-Storage-Url");
  define("AUTH_TOKEN", "X-Auth-Token");
  define( "AUTH_USER_HEADER", "X-Auth-User" );
  define( "AUTH_KEY_HEADER", "X-Auth-Key" );

  class cdn implements IContent {

    private static $debug = true;
    private static $ssl_bundle;
    private static $connections = array(
      "GET_CALL"  => NULL, # GET objects/containers/lists
      "PUT_OBJ"   => NULL, # PUT object
      "HEAD"      => NULL, # HEAD requests
      "PUT_CONT"  => NULL, # PUT container
      "DEL_POST"  => NULL, # DELETE containers/objects, POST objects
    );
    private static $auth_token = null;
    private static $storage_url = null;
    private static $cdn_url = null;

    private static function authenticated() {
      if( ( self::$storage_url || self::$cdn_url ) && self::$auth_token ) {
        return true;
      }
      return false;
    }

    private static function authenticate() {
      if( self::authenticated() ) {
        return;
      }
      $user = action::get( "settings/cdn_username" );
      $key = action::get( "settings/cdn_api_key" );
      $host = action::get( "settings/cdn_host" );
      $path = "https://" . $host . "/v1.0";
      $headers = array(
        sprintf( "%s: %s", AUTH_USER_HEADER, $user ),
        sprintf( "%s: %s", AUTH_KEY_HEADER, $key )
      );
      $curl = curl_init();
      if( !self::$ssl_bundle ) {
        self::fetch_ssl_bundle();
      }
      if( self::$ssl_bundle ) {
        curl_setopt( $curl, CURLOPT_CAINFO, self::$ssl_bundle );
      }
      if( self::$debug ) {
        curl_setopt( $curl, CURLOPT_VERBOSE, true );
      }
      curl_setopt( $curl, CURLOPT_SSL_VERIFYPEER, true );
      curl_setopt( $curl, CURLOPT_RETURNTRANSFER, true );
      curl_setopt( $curl, CURLOPT_URL, $path );
      curl_setopt( $curl, CURLOPT_HTTPHEADER, $headers );
      curl_setopt( $curl, CURLOPT_HEADER, true );
      curl_setopt( $curl, CURLOPT_FOLLOWLOCATION, true );
      curl_setopt( $curl, CURLOPT_MAXREDIRS, 4 );
      curl_setopt( $curl, CURLOPT_USERAGENT, USER_AGENT );
      if( !$response = curl_exec( $curl ) ) {
        //Transaction failed
      }
      $curl_info = curl_getinfo( $curl );
      curl_close( $curl );
      $http_code = $curl_info['http_code'];
      $returned = self::parse_response( $response );
      self::$auth_token = $returned[AUTH_TOKEN];
      self::$cdn_url = $returned[CDN_URI];
      self::$storage_url = $returned[STORAGE_URL];
    }

    private static function make_path( $type = "STORAGE", $container = null, $object = null ) {
      $path = array();
      switch( $type ) {
        case "STORAGE":
          $path[] = self::$storage_url;
          break;
        case "CDN":
          $path[] = self::$cdn_url;
          break;
      }
      if( $container == "0" ) {
        $path[] = rawurldecode( $container );
      }
      if( $container ) {
        $path[] = rawurldecode( $container );
      }
      if( $object ) {
        $path[] = str_replace( "%2F", "/", rawurldecode( $object ) );
      }
      return implode( "/", $path );
    }

    private static function parse_response( $response ) {
      preg_match_all( "/HTTP\/1\.[01] (\d+) (.*)\r\n/", $response, $matches );
      $total_matches = count( $matches[1] );
      $hi = 0;
      $bi = 1;
      if( $total_matches > 1 ) {
        $hi = $total_matches - 1;
        $bi = $total_matches;
      }
      $docsplit = explode( "\r\n\r\n", $response );
      $docsplit[$hi] = str_replace( "\r\n", " ", $docsplit[$hi] );
      $returned = array();
      $random = sys::random_chars( 12 );
      if( preg_match_all( "/ ([^:\s]+): /", $docsplit[$hi], $matches ) ) {
        foreach( $matches[1] as $header ) {
          $docsplit[$hi] = str_replace( " " . $header . ": ", "[" . $random . "]", $docsplit[$hi] );
        }
        $split = explode( "[" . $random . "]", $docsplit[$hi] );
        array_shift( $split );
        foreach( $matches[1] as $key => $header ) {
          $returned[trim($header)] = trim($split[$key]);
        }
      }
      if( count( $docsplit ) > $total_matches ) {
        $returned['body'] = $docsplit[$bi];
      }
      return $returned;
    }

    private static function create_connection( $type, $force_new = false ) {
      if( !in_array( $type, self::$connections ) ) {
        //Invalid connection type
      }
      if( !self::$connections[$type] || $force_new ) {
        $curl = curl_init();
      } else {
        return;
      }
      if( self::$debug ) {
        curl_setopt( $curl, CURLOPT_VERBOSE, true );
      }
      if( !self::$ssl_bundle ) {
        self::fetch_ssl_bundle();
      }
      if( self::$ssl_bundle ) {
        curl_setopt( $curl, CURLOPT_CAINFO, self::$ssl_bundle );
      }
      curl_setopt( $curl, CURLOPT_SSL_VERIFYPEER, true );
      curl_setopt( $curl, CURLOPT_FOLLOWLOCATION, true );
      curl_setopt( $curl, CURLOPT_MAXREDIRS, 4 );
      curl_setopt( $curl, CURLOPT_HEADER, true );
      curl_setopt( $curl, CURLOPT_RETURNTRANSFER, true );
      //CURLOPT_HEADERFUNCTION
      if( $type == "GET_CALL" ) {
        //CURLOPT_WRITEFUNCTION
      } else if( $type == "PUT_OBJ" ) {
        curl_setopt( $curl, CURLOPT_PUT, true );
        //CURLOPT_READFUNCTION
      } else if( $type == "HEAD" ) {
        curl_setopt( $curl, CURLOPT_CUSTOMREQUEST, "HEAD" );
      } else if( $type == "PUT_CONT" ) {
        curl_setopt( $curl, CURLOPT_CUSTOMREQUEST, "PUT" );
        curl_setopt( $curl, CURLOPT_INFILESIZE, 0 );
        //curl_setopt( $curl, CURLOPT_NOBODY, true );
      } else if( $type == "DEL_POST" ) {
        //curl_setopt( $curl, CURLOPT_NOBODY, true );
      }
      self::$connections[$type] = $curl;
      return;
    }

    private static function fetch_ssl_bundle() {
      if( file_exists( CONTENT_DIR . "/cloudfiles/sslbundle.pem" ) ) {
        self::$ssl_bundle = CONTENT_DIR . "/cloudfiles/sslbundle.pem";
      }
    }

    private static function send_request( $type, $url, $headers, $method = "GET" ) {
      self::create_connection( $type );
      $headers = self::make_headers( $headers );
      if( gettype( self::$connections[$type] ) == "unknown type" ) {
        //Connection not open
      }
      switch( $method ) {
        case "DELETE":
          curl_setopt( self::$connections[$type], CURLOPT_CUSTOMREQUEST, "DELETE" );
          break;
        case "POST":
          curl_setopt( self::$connections[$type], CURLOPT_CUSTOMREQUEST, "POST" );
          break;
      }
      curl_setopt( self::$connections[$type], CURLOPT_HTTPHEADER, $headers );
      curl_setopt( self::$connections[$type], CURLOPT_URL, $url );
      if( !$response = curl_exec( self::$connections[$type] ) ) {
        
      }
      $curl_info = curl_getinfo( self::$connections[$type] );
      $http_code = $curl_info['http_code'];
      $returned = self::parse_response( $response );
      $returned['http_code'] = (int)$http_code;
      return $returned;
    }

    private static function make_headers( $headers = null ) {
      if( !$headers ) {
        $headers = array();
      }
      if( !isset( $headers[AUTH_TOKEN] ) ) {
        $headers[AUTH_TOKEN] = self::$auth_token;
      }
      if( !isset( $headers['user-agent'] ) ) {
        $headers['user-agent'] = USER_AGENT;
      }
      $formatted = array();
      foreach( $headers as $key => $val ) {
        $formatted[] = sprintf( "%s: %s", trim($key), trim($val) );
      }
      return $formatted;
    }

    public static function list_containers( $limit = null, $marker = null, $format = null ) {
      self::authenticate();
      if( !self::authenticated() ) {
        //Not authenticated
      }
      $type = "GET_CALL";
      $headers = self::make_headers();
      $url = self::make_path();
      $params = array();
      if( $limit ) { $params[] = "limit=" . $limit; }
      if( $marker ) { $params[] = "marker=" . $marker; }
      if( $format ) { $params[] = "format=" . $format; }
      if( count( $params ) > 0 ) {
        $url .= "?" . implode( "&", $params );
      }
      $response = self::send_request( $type, $url, $headers );
      if( !$response['http_code'] || $response['http_code'] != 200 ) {
        if( $response['http_code'] == 204 ) {
          //No containers found
        } else {
          //Invalid response
        }
      }
      return $response;
    }

    public static function account_information() {
      self::authenticate();
      if( !self::authenticated() ) {
        //Not authenticated
      }
      $type = "HEAD";
      $headers = self::make_headers();
      $url = self::make_path();
      $response = self::send_request( $type, $url, $headers );
      if( !$response['http_code'] || $response['http_code'] != 204 ) {
        if( $response['http_code'] == 401 ) {
          //Invalid account or auth key
        } else {
          //Invalid response
        }
      }
      // Returns:
      // X-Account-Container-Count
      // X-Account-Total-Bytes-Used
      return $response;
    }

    public static function container_information( $name ) {
      self::authenticate();
      if( !self::authenticated() ) {
        //Not authenticated
      }
      $type = "HEAD";
      $headers = self::make_headers();
      $url = self::make_path( "STORAGE", $name );
      $response = self::send_request( $type, $url, $headers );
      if( !$response['http_code'] || $response['http_code'] != 204 ) {
        if( $response['http_code'] == 404 ) {
          //Container not found
        } else {
          //Invalid response
        }
      }
      // Returns:
      // X-Container-Object-Count
      // X-Container-Bytes-Used
      return $response;
    }

    public static function add_container( $name, $cdn_enabled = true ) {
      self::authenticate();
      if( !self::authenticated() ) {
        //Not authenticated
      }
      $type = "PUT_CONT";
      $headers = self::make_headers();
      $url = self::make_path( "STORAGE", $name );
      $response = self::send_request( $type, $url, $headers );
      if( !$response['http_code'] || $response['http_code'] != 201 ) {
        if( $response['http_code'] == 202 ) {
          //Container already existed
        } else {
          //Invalid response
        }
      }
      return $response;
    }

    public static function delete_container( $name ) {
      self::authenticate();
      if( !self::authenticated() ) {
        //Not authenticated
      }
      $type = "DEL_POST";
      $headers = self::make_headers();
      $url = self::make_path( "STORAGE", $name );
      $response = self::send_request( $type, $url, $headers, "DELETE" );
      if( !$response['http_code'] || $response['http_code'] != 204 ) {
        if( $response['http_code'] == 404 ) {
          //Container did not exist
        } else if( $response['http_code'] == 409 ) {
          //Container is not empty
        } else {
          //Invalid response
        }
      }
    }

    public static function list_objects( $container, $limit = null, $marker = null, $prefix = null, $format = null, $path = null ) {
      self::authenticate();
      if( !self::authenticated() ) {
        //Not authenticated
      }
      $type = "GET_CALL";
      $headers = self::make_headers();
      $url = self::make_path( "STORAGE", $container );
      $params = array();
      if( $limit ) { $params[] = "limit=" . $limit; }
      if( $marker ) { $params[] = "marker=" . $marker; }
      if( $prefix ) { $params[] = "prefix=" . $prefix; }
      if( $format ) { $params[] = "format=" . $format; }
      if( $path ) { $params[] = "path=" . $path; }
      if( count( $params ) > 0 ) {
        $url .= "?" . implode( "&", $params );
      }
      $response = self::send_request( $type, $url, $headers );
      if( !$response['http_code'] || $response['http_code'] != 200 ) {
        if( $response['http_code'] == 204 ) {
          //Container is empty or does not exist
        } else if( $response['http_code'] == 404 ) {
          //Incorrect account
        } else {
          //Invalid response
        }
      }
      return $response;
    }

    public static function object_information( $container, $name ) {
      self::authenticate();
      if( !self::authenticated() ) {
        //Not authenticated
      }
      $type = "HEAD";
      $headers = self::make_headers();
      $url = self::make_path( "STORAGE", $container, $name );
      $response = self::send_request( $type, $url, $headers );
      if( !$response['http_code'] || $response['http_code'] != 204 ) {
        if( $response['http_code'] == 404 ) {
          //Object did not exist
        } else {
          //Invalid response
        }
      }
      // Return:
      // ETag MD5 hash
      // X-Object-Meta-XXX key/value pairs
      return $response;
    }

    public static function get_object( $container, $object ) {
      
      //add container and object onto url
      //type GET
      //200 Ok means success
      //404 Not Found means the object did not exist
      //Can use Range header to get parts of the file
      //Apparently is also supports If-Match, If-None-Match, If-Modified-Since, If-Unmodified-Since headers as well

    }

    public static function add_object( $container, $name, &$file, $verify = true, $extra = null ) {
      if( !is_resource( $file ) ) {
        //Invalid file
      }
      self::authenticate();
      if( !self::authenticated() ) {
        //Not authenticated
      }
      $type = "PUT_OBJ";
      self::create_connection( $type );
      $headers = array();
      if( $extra ) {
        foreach( $extra as $key => $val ) {
          $headers['X-Object-Meta-'.$key] = $val;
        }
      }
      $headers = self::make_headers( $headers );
      if( $verify ) {
        $headers[] = "ETag: " . self::compute_md5( $file );
      }
      $url = self::make_path( "STORAGE", $container, $name );
      $content_type = self::determine_content_type( $file );
      if( $content_type ) {
        $headers[] = "Content-Type: " . $content_type;
      } else {
        $headers[] = "Content-Type: application/octet-stream";
      }
      curl_setopt( self::$connections[$type], CURLOPT_INFILE, $file );
      $stats = fstat( $file );
      if( $stats ) {
        $filesize = (int)$stats['size'];
      }
      if( !$filesize ) {
        curl_setopt( self::$connections[$type], CURLOPT_UPLOAD, true );
        $headers[] = "Transfer-Encoding: chunked";
      } else {
        curl_setopt( self::$connections[$type], CURLOPT_INFILESIZE, $filesize );
      }
      $response = self::send_request( $type, $url, $headers );
      if( !$response['http_code'] || $response['http_code'] != 201 ) {
        if( $response['http_code'] == 412 ) {
          //Missing Content-Length or Content-Type header
        } else if( $response['http_code'] == 422 ) {
          //MD5 checksum did not match
        } else {
          //Invalid response code
        }
      } else {
        return true;
      }
      //return $response;
      //add container and object onto url
      //type PUT
      //can add X-Object-Mata-XXX to add metadata to object
      //Add md5 checksum in the ETag header for integrity
      //add Content-Length header
      //201 Created means success
      //412 Length Required means missing content-length or content-type header
      //422 Unprocessable Entity means md5 checksum failed
      //Can send "chunked" data with Transfer-Encoding: chunked      
    }

    public static function modify_object( $container, $name, $key, $value ) {
      
      //add container and object onto url
      //type POST
      //add X-Object-Meta-XXX to modify or add metadata, all this method is used for
      //will delete all existing metadata
      //202 Accepted means success
      //404 Not Found means object does not exist

    }

    public static function delete_object( $container, $name ) {
      self::authenticate();
      if( !self::authenticated() ) {
        //Not authenticated
      }
      $type = "DEL_POST";
      $headers = self::make_headers();
      $url = self::make_path( "STORAGE", $container, $name );
      $response = self::send_request( $type, $url, $headers, "DELETE" );
      if( !$response['http_code'] || $response['http_code'] != 204 ) {
        if( $response['http_code'] == 404 ) {
          //Object did not exist
        } else {
          //Invalid response
        }
      } else {
        return true;
      }
    }

    private static function determine_content_type( $data ) {
      if( function_exists( "finfo_open" ) ) {
        $local_magic = CONTENT_DIR . "/cloudfiles";
        $finfo = @finfo_open( FILEINFO_MIME, $local_magic );
        if( !$finfo ) {
          $finfo = @finfo_open( FILEINFO_MIME );
        }
        if( $finfo ) {
          if( is_file( (string) $data ) ) {
            $ct = @finfo_file( $finfo, $data );
          } else {
            $ct = @finfo_buffer( $finfo, $data );
          }
          if( $ct ) {
            $extra_content_type_info = strpos( $ct, "; " );
            if( $extra_content_type_info ) {
              $ct = substr( $ct, 0, $extra_content_type_info );
            }
          }
          if( $ct && $ct != "application/octet-stream" ) {
            @finfo_close( $finfo );
            return $ct;
          }
        }
      }
      if( is_file( (string) $data ) && function_exists( "mime_content_type" ) ) {
        return @mime_content_type( $data );
      }
      //Content type could not be determined
      return null;
    }

    private static function compute_md5( &$data ) {
      if( function_exists( "hash_init" ) && is_resource( $data ) ) {
        $ctx = hash_init( "md5" );
        while( !feof( $data ) ) {
          $buffer = fgets( $data, 65536 );
          hash_update( $ctx, $buffer );
        }
        $md5 = hash_final( $ctx, false );
        rewind( $data );
      } else if( (string)is_file( $data ) ) {
        $md5 = md5_file( $data );
      } else {
        $md5 = md5( $data );
      }
      return $md5;
    }

  }

?>

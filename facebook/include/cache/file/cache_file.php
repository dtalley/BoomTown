<?php

  require_once( CACHE_DIR . "/cache.php" );

  class cache implements ICache {

    public static function set( $output, $expiration = -1, $id = "", $directory = "" ) {
      if( $id ) {
        $cache_name = $id;
      } else {
        $cache_name = self::name();
      }
      if( $expiration < 0 ) {
        $expiration = 60 * 60 * 24 * 3;
      }
      $expiration = time() + $expiration;
      if( $directory && substr( $directory, -1 ) != "/" ) {
        $directory .= "/";
      }
      if( $directory && !file_exists( "cache/" . $directory ) ) {
        $dir_split = explode( "/", $directory );
        $total_folders = count( $dir_split );
        $current_folder = "cache/";
        for( $i = 0; $i < $total_folders; $i++ ) {
          if( !file_exists( $current_folder . $dir_split[$i] ) ) {
            mkdir( $current_folder . $dir_split[$i], 0755 );
          }
          $current_folder .= $dir_split[$i] . "/";
        }
      }
      $dom = DOMDocument::loadXML( $output );
      $output = simplexml_import_dom( $dom->documentElement );
      if( !file_exists( "cache/" . $directory . $cache_name . ".php.tmp" ) ) {
        $file = fopen( "cache/" . $directory . $cache_name . ".php.tmp", 'w' );
        fwrite( $file, "<cache><expiration>" . $expiration . "</expiration><data>" . $output->asXML() . "</data></cache>" );
        fclose( $file );
        if( file_exists( "cache/" . $directory . $cache_name . ".php" ) ) {
          unlink( "cache/" . $directory . $cache_name . ".php" );
        }
        rename( "cache/" . $directory . $cache_name . ".php.tmp", "cache/" . $directory . $cache_name . ".php" );
      }
    }

    public static function get( $id = "", $directory = "" ) {
      if( $id ) {
        $cache_name = $id;
      } else {
        $cache_name = self::name();
      }
      if( $directory && substr( $directory, -1 ) != "/" ) {
        $directory .= "/";
      }
      if( file_exists( "cache/" . $directory . $cache_name . ".php" ) ) {
        $xml = simplexml_load_file( "cache/" . $directory . $cache_name . ".php" );
        if( !$xml ) {
          echo "returning false";
          exit();
          return false;
        }
        $expiration = $xml->xpath( "/cache/expiration" );
        $expiration = (int)$expiration[0];
        if( $expiration < time() ) {
          return false;
        }
        $data = $xml->xpath( "/cache/data" );
        $data = $data[0];
        return $data->children()->asXML();
      } else {
        return false;
      }
    }

    public static function clear( $id = "", $directory = "" ) {
      if( $directory && substr( $directory, -1 ) != "/" ) {
        $directory .= "/";
      }
      if( file_exists( "cache/" . $directory . ( $id ? $id . ".php" : "" ) ) ) {
        if( $id ) {
          unlink( "cache/" . $directory . $id . ".php" );
        } else {
          $dir = opendir( "cache/" . $directory );
          while( ( $file = readdir( $dir ) ) !== false ) {
            if( $file != "." && $file != ".." ) {
              unlink( "cache/" . $directory . $file );
            }
          }
        }
      }
    }

    private static function name() {
      $directory = action::get( "request/template/directory" );
      if( strlen( $directory ) > 0 ) {
        $directory = substr( $directory, 1 );
        if( substr( $directory, -1 ) == "/" ) {
          $directory = substr( $directory, 0, strlen( $directory ) - 1 );
        }
        $directory .= ".";
      }
      $page = action::get( "request/template/page" );
      $cache_name = $directory . $page;
      $total_variables = action::total( "url_variables/var" );
      for( $i = 0; $i < $total_variables; $i++ ) {
        $cache_name .= "." . action::get( "url_variables/var", $i );
      }
      $total_additions = action::total( "cache/additions" );
      for( $i = 0; $i < $total_variables; $i++ ) {
        
      }
      return $cache_name;
    }

  }

?>

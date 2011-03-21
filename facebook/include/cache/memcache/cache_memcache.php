<?php

  require_once( CACHE_DIR . "/cache.php" );

  class cache implements ICache {

    public static function set( &$output, $expiration = -1, $id = "", $directory = "" ) {
      self::connect();
      if( $id ) {
        $cache_name = $id;
      } else {
        $cache_name = self::name();
      }
      if( $expiration < 0 ) {
        $expiration = 60 * 60 * 24 * 7 * 4;
      }
      $expiration = time() + $expiration;
      if( $directory && substr( $directory, -1 ) != "/" ) {
        $directory .= "/";
      }
      //echo "Directory being requested in cache: " . $directory . "<br />";
      $directory_split = explode( "/", $directory );
      $directory_path = "cache/";
      $total_directories = count( $directory_split );
      for( $i = 0; $i < $total_directories; $i++ ) {
        $directories = memcache_get( self::$connection, $directory_path . "directories" );
        if( !$directories ) {
          $directories = array();
        } else {
          $directories = unserialize( $directories );
          if( !is_array( $directories ) ) {
            $directories = array();
          }
        }
        if( strlen( $directory_split[$i] ) > 0 ) {
          $new_directory = $directory_split[$i] . "/";
          if( !in_array( $new_directory, $directories ) ) {
            array_push( $directories, $new_directory );
            //echo "Adding new directory to " . $directory_path . ": " . $new_directory . "<br />";
          }
          memcache_set( self::$connection, $directory_path . "directories", serialize( $directories ), false, 60 * 60 * 24 * 7 * 5 );
          $directory_path .= $new_directory;
        }
      }
      $files_path = $directory_path . "files";
      $files = memcache_get( self::$connection, $files_path );
      if( !$files ) {
        $files = array();
      } else {
        $files = unserialize( $files );
        if( !is_array( $files ) ) {
          $files = array();
        }
      }
      if( !in_array( $cache_name, $files ) ) {
        array_push( $files, $cache_name );
        //echo "Adding new file to " . $directory_path . ": " . $cache_name . "<br />";
        memcache_set( self::$connection, $files_path, serialize( $files ), false, 60 * 60 * 24 * 7 * 5 );
      }
      $cache_id = $directory_path . $cache_name;
      memcache_set( self::$connection, $cache_id, $output, false, $expiration );
    }

    public static function get( $id = "", $directory = "" ) {
      self::connect();
      if( $id ) {
        $cache_name = $id;
      } else {
        $cache_name = self::name();
      }
      if( $directory && substr( $directory, -1 ) != "/" ) {
        $directory .= "/";
      }
      $cache_id = "cache/" . $directory . $cache_name;
      return memcache_get( self::$connection, $cache_id );
    }

    public static function clear( $id = "", $directory = "" ) {
      self::connect();
      if( $directory && substr( $directory, -1 ) != "/" ) {
        $directory .= "/";
      }
      if( $directory && $id ) {
        $cache_id = "cache/" . $directory . $id;
        memcache_delete( self::$connection, $cache_id );
      } else if( $directory && !$id ) {
        $directory_name = "cache/" . $directory;
        self::clear_directory( $directory_name );
      }
    }

    private static function clear_directory( $name ) {
      $directories = memcache_get( self::$connection, $name . "directories" );
      if( $directories ) {
        $directories = unserialize( $directories );
        if( is_array( $directories ) ) {
          $total_directories = count( $directories );
          for( $i = 0; $i < $total_directories; $i++ ) {
            clear_directory( $name . $directories[$i] );
          }
        }
      }
      memcache_delete( self::$connection, $name . "directories" );
      $files = memcache_get( self::$connection, $name . "files" );
      if( $files ) {
        $files = unserialize( $files );
        if( is_array( $files ) ) {
          $total_files = count( $files );
          for( $i = 0; $i < $total_files; $i++ ) {
            memcache_delete( self::$connection, $name . $files[$i] );
          }
        }
      }
      memcache_delete( self::$connection, $name . "files" );
    }

    public static function flush() {
      memcache_flush( self::$connection );
      echo "<!-- Cache flushed. -->\n";
    }

    private static $connection = NULL;

    private static function connect() {
      if( self::$connection == NULL ) {
        self::$connection = memcache_connect( "localhost", 11211 );
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

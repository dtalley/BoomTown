<?php

  require_once( CACHE_DIR . "/cache.php" );

  class cache implements ICache {

    public static function set( &$output, $expiration, $id, $directory ) {
      return false;
    }

    public static function get( $id, $directory ) {
      return false;
    }

    public static function clear( $id, $directory ) {
      return false;
    }

    public static function flush() {
      return false;
    }

  }

?>

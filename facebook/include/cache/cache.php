<?php

  interface ICache {

    public static function set( &$output, $expiration, $id, $directory );
    public static function get( $id, $directory );
    public static function clear( $id, $directory );
    public static function flush();

  }

?>

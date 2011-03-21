<?php

	interface IDatabase {
		
		public static function connect( $db_host, $db_name, $db_username, $db_password, $debug = false );
		
		//Basic Interface
		public static function sql_query( $sql );
		public static function sql_numrows( $resource );
		public static function sql_fetchrow( $resource );
		public static function sql_insertid();
		public static function sql_affected();
		public static function sql_error();
		public static function sql_freeresult( $resource );
		
		//Intuitive Interface
		public static function clear();
		public static function open( $table, $join = NONE );
		public static function start_block();
		public static function end_block();
		public static function close();
		
		public static function where_and();
		public static function where_or();
		public static function where( $column, $value, $suffix = "", $function = "", $escape = true );
		public static function where_in( $column, $values );
		public static function where_between( $column, $values );
		public static function link( $column, $level = 1 );
		
		public static function select_as( $alias = "" );
		public static function select();
		public static function select_max( $column );
		public static function select_min( $column );
		
		public static function order( $column, $order );
		
		public static function group( $column );
		
		public static function limit( $start, $total );
		
		public static function set( $column, $value );
		
		public static function query();
		public static function insert();
		public static function update();
		public static function delete();
		
	}

?>
<?php

  require_once( DATABASE_DIR . "/database.php" );

	class db implements IDatabase {

    /**
     * Our connection variable and a method for allowing the outside
     * world to initiate a database connection
     * @var connection Our persistent connection to the MySQL database
     */
    private static $connection;
    public static function connect( $db_host, $db_name, $db_username, $db_password, $debug = false ) {
      $connstring = "host=" . $db_host . " dbname=" . $db_name . " user=" . $db_username . " password=" . $db_password;
      self::$connection = pg_connect( $connstring );
      /*self::$connection = mysql_connect( $db_host, $db_username, $db_password );
			if( !self::$connection || !mysql_select_db( $db_name, self::$connection ) ) {
				//sys::message( SYSTEM_ERROR, lang::phrase( "database/db_error/title" ), lang::phrase( "database/db_error/body" ), __FILE__, __LINE__, __FUNCTION__, __CLASS__ );
        return false;
			}
      return true;*/
		}

    /**
     * Our debug variable and a method for the outside world to enable debugging
     * @var debug True if we're in debug mode and should record queries, false otherwise
     */
    private static $debug = false;
    public static function enable_debugging() {
      self::$debug = true;
    }

    private static $top_query = NULL;
    private static $current_query = NULL;

    private static $union_order = NULL;
    private static $union_limit = NULL;

    private static $query_open = false;

    private static $current_result = -1;
		private static $result = array();

    public static function clear() {
      self::$top_query = NULL;
      self::$current_query = NULL;

      self::$union_order = NULL;
      self::$union_limit = NULL;

      self::$query_open = false;
    }

    public static function start_block() {
      if( self::$query_open ) {
        self::$current_query->start_block();
      }
    }

    public static function end_block() {
      if( self::$query_open ) {
        self::$current_query->end_block();
      }
    }

    public static function union( $union = ALL, $encased = false ) {
      if( self::$query_open ) {
        $new_query = new dbquery( self::$current_query->get_parent(), $union, $encased );
        self::$current_query->union( $new_query );
        self::$current_query = $new_query;
      }
    }

    public static function union_order( $column, $order ) {
			if( self::$union_order == NULL ) {
        self::$union_order = "";
      }
      if( strlen( self::$union_order ) > 0 ) {
				self::$union_order .= ", ";
			}
			self::$union_order .= $column . " " . strtoupper( $order );
		}

		public static function union_limit( $start, $total ) {
			self::$union_limit = ( $start > 0 ?  $start . ", " : "" ) . $total;
		}

    public static function open( $table, $join = NONE, $encased = false ) {
      if( !self::$query_open ) {
        self::$top_query = self::$current_query = new dbquery( NULL, NONE, $encased );
        self::$query_open = true;
      }
      return self::$current_query->open( $table, $join );
		}

    public static function open_subquery( $join = NONE ) {
      $new_query = new dbquery( self::$current_query );
      self::$current_query->open_subquery( $new_query, $join );
      self::$current_query = $new_query;
    }

    public static function open_blank() {
      if( !self::$query_open ) {
        self::$top_query = self::$current_query = new dbquery( NULL, NONE, $encased );
        self::$query_open = true;
      }
      self::$current_query->open_blank();
    }

		public static function close() {
			if( self::$query_open ) {
        self::$current_query->close();
      }
		}

    public static function close_subquery() {
      if( self::$query_open && self::$top_query != self::$current_query ) {
        self::$current_query = self::$current_query->get_parent();
      }
    }

		/* WHERE FUNCTIONS */

		public static function where_and() {
			if( self::$query_open ) {
        self::$current_query->where_and();
      }
		}

		public static function where_or() {
			if( self::$query_open ) {
        self::$current_query->where_or();
      }
		}

		public static function where_like( $column, $value ) {
			self::where( $column, $value, "LIKE" );
		}

		public static function where_in( $column, $values ) {
			$value_text = "( ";
			foreach( $values as $key => $val ) {
				if( $key > 0 ) {
					$value_text .= ", ";
				}
				if( !is_int( $val ) ) {
					$val = "'" . str_replace( "'", "\'", $val ) . "'";
				}
				$value_text .= $val;
			}
			$value_text .= " )";
			self::where( $column, $value_text, "IN", "", false );
		}

		public static function where_between( $column, $values ) {
			if( !is_int( $values[0] ) || !is_int( $values[1] ) ) {
				$values[0] = "'" . str_replace( "'", "\'", $values[0] ) . "'";
				$values[1] = "'" . str_replace( "'", "\'", $values[1] ) . "'";
			}
			self::where( $column, $values[0] . " AND " . $values[1], "BETWEEN", "", false );
		}

		public static function where_day( $column, $value ) {
			$day = (int) $value;
			if( is_int( $day ) ) {
				self::where( $column, $day, "", "DAY" );
			}
		}

		public static function where_month( $column, $value ) {
			$month = (int) $value;
			if( is_int( $month ) ) {
				self::where( $column, $month, "", "MONTH" );
			}
		}

		public static function where_year( $column, $value ) {
			$year = (int) $value;
			if( is_int( $year ) ) {
				self::where( $column, $year, "", "YEAR" );
			}
		}

    public static function where( $column, $value, $suffix = "", $function = "", $escape = true ) {
			if( self::$query_open ) {
        self::$current_query->where( $column, $value, $suffix, $function, $escape );
      }
		}

    public static function where_subquery_column( $value, $suffix = "", $function = "" ) {
      if( self::$query_open ) {
        $new_query = new dbquery( self::$current_query );
        self::$current_query->where_subquery_column( $new_query, $value, $suffix, $function );
        self::$current_query = $new_query;
      }
    }

    public static function where_subquery_value( $column, $suffix = "", $function = "" ) {
      if( self::$query_open ) {
        $new_query = new dbquery( self::$current_query );
        self::$current_query->where_subquery_value( $new_query, $column, $suffix, $function );
        self::$current_query = $new_query;
      }
    }

    public static function having( $column, $value, $suffix = "", $function = "", $escape = true ) {
      if( self::$query_open ) {
        self::$current_query->having( $column, $value, $suffix, $function, $escape );
      }
    }

		public static function link( $column, $level = 1 ) {
			if( self::$query_open ) {
        self::$current_query->link( $column, $level );
      }
		}

    public static function loose_link( $column1, $column2, $level = 1 ) {
			if( self::$query_open ) {
        self::$current_query->loose_link( $column1, $column2, $level );
      }
		}

		/* SELECT FUNCTIONS */

		public static function select_as( $alias = "" ) {
			if( self::$query_open ) {
        self::$current_query->select_as( $alias );
      }
		}

		public static function select() {
			if( self::$query_open ) {
        self::$current_query->select( func_get_args() );
      }
		}

    public static function select_manual() {
      if( self::$query_open ) {
        self::$current_query->select( func_get_args(), false );
      }
    }

    public static function select_none() {
      if( self::$query_open ) {
        self::$current_query->select_none();
      }
    }

		public static function select_count( $column ) {
			if( self::$query_open ) {
        self::$current_query->select_count( $column );
      }
		}

    public static function select_count_distinct( $column ) {
			if( self::$query_open ) {
        self::$current_query->select_count_distinct( $column );
      }
		}

    public static function select_count_all() {
			if( self::$query_open ) {
        self::$current_query->select_count_all();
      }
		}

    public static function select_sum( $column ) {
			if( self::$query_open ) {
        self::$current_query->select_sum( $column );
      }
		}

		public static function select_max( $column ) {
			if( self::$query_open ) {
        self::$current_query->select_max( $column );
      }
		}

		public static function select_min( $column ) {
			if( self::$query_open ) {
        self::$current_query->select_min( $column );
      }
		}

		public static function select_timestamp( $column ) {
			if( self::$query_open ) {
        self::$current_query->select_timestamp( $column );
      }
		}

    public static function select_subquery() {
      if( self::$query_open ) {
        $new_query = new dbquery( self::$current_query );
        self::$current_query->select_subquery( $new_query );
        self::$current_query = $new_query;
      }
    }

		/* ORDER, GROUP, AND LIMIT FUNCTIONS */

		public static function order( $column, $order, $use_alias = true ) {
			if( self::$query_open ) {
        self::$current_query->order( $column, $order, $use_alias );
      }
		}

		public static function group( $column, $use_alias = true ) {
			if( self::$query_open ) {
        self::$current_query->group( $column, $use_alias );
      }
		}

		public static function limit( $start, $total ) {
			if( self::$query_open ) {
        self::$current_query->limit( $start, $total );
      }
		}

    /* OPERATION FUNCTIONS */
		private static $total = 0;
    private static $total_time = 0;
    private static $log = array();
    private static $backtrace = array();
    private static $explain = array();
    private static $duration = array();
		public static function query() {
      if( self::$query_open ) {
        $sql = self::$top_query->select_sql();
        if( self::$union_order != NULL ) {
          $sql .= " ORDER BY " . self::$union_order;
        }
        if( self::$union_limit != NULL ) {
          $sql .= " LIMIT " . self::$union_limit;
        }
        self::clear();
        if( self::$debug ) {
          self::$total++;
          array_push( self::$log, $sql );
          array_push( self::$backtrace, debug_backtrace() );
          $explain_sql = "EXPLAIN " . $sql;
          if( $result = self::sql_query( $explain_sql ) ) {
            $explain_index = array();
            $explain_table = "";
            while( $row = pg_fetch_array( $result ) ) {
              $explain_index[] = $row;
            }
            $explain_table = self::convert_array_to_table( $explain_index );
            array_push( self::$explain, $explain_table );
          } else {
            array_push( self::$explain, null );
          }
        }
        if( self::$debug ) {
          $start = microtime(true);
        }
        if( !$result = pg_query( self::$connection, $sql ) ) {
          return false;
        }
        if( self::$debug ) {
          $end = microtime(true);
          array_push( self::$duration, round( ( $end - $start ), 6 ) );
        }
        self::$current_result++;
        self::$result[self::$current_result] = $result;
        /*while( $row = @mysql_fetch_array( $result ) ) {
          self::$result[self::$current_result][] = $row;
        }*/
        return true;
      }
		}

    private static function convert_array_to_table( $array ) {
      $column_widths = array();
      $total_elements = count( $array );
      $headers = array();
      for( $i = 0; $i < $total_elements; $i++ ) {
        $column = 0;
        foreach( $array[$i] as $key => $val ) {
          if( !is_int( $key ) ) {
            if( $i == 0 ) {
              $column_widths[$column] = strlen( $key );
              $headers[$key] = strtoupper( $key );
            }
            if( strlen( $val ) > $column_widths[$column] ) {
              $column_widths[$column] = strlen( $val );
            }
            $column++;
          }
        }
      }
      $table = "";
      array_unshift( $array, $headers );
      for( $i = 0; $i < $total_elements + 1; $i++ ) {
        $column = 0;
        foreach( $array[$i] as $key => $val ) {
          if( !is_int( $key ) ) {
            for( $j = 0; $j < $column_widths[$column]; $j++ ) {
              if( strlen( $val ) >= $j + 1 ) {
                $table .= substr( $val, $j, 1 );
              } else {
                $table .= " ";
              }
            }
            if( $column < count( $column_widths ) - 1 ) {
              $table .= " || ";
            }
            $column++;
          }
        }
        $table .= "\n";
      }
      return $table;
    }

    public static function query_count() {
      return self::$total;
    }

    public static function query_log() {
      return self::$log;
    }

    public static function query_backtrace() {
      return self::$backtrace;
    }

    public static function print_log() {
      if( self::$debug ) {
        $directory = action::get( "request/template/directory" );
        if( strlen( $directory ) > 0 ) {
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
        $file = fopen( "logs/mysql/" . $cache_name . ".log", 'w' );
        if( $file ) {
          self::$total_time = 0;
          $debug_index = array();
          for( $i = 0; $i < self::$total; $i++ ) {
            self::$total_time += self::$duration[$i];
            array_push( $debug_index, array(
              "log" => self::$log[$i],
              "backtrace" => self::$backtrace[$i],
              "explain" => self::$explain[$i],
              "duration" => self::$duration[$i]
            ) );
          }
          usort( $debug_index, "db::sort_debug_index" );
          $output = "";
          for( $i = 0; $i < self::$total; $i++ ) {
            $output .= $debug_index[$i]['log'] . "\n";
            $total_trace = count( $debug_index[$i]['backtrace'] );
            for( $j = 0; $j < $total_trace; $j++ ) {
              if( isset( $debug_index[$i]['backtrace'][$j]['class'] ) ) {
                $output .= $debug_index[$i]['backtrace'][$j]['class'] . "->" . $debug_index[$i]['backtrace'][$j]['function'] . " > ";
              }
            }
            $output .= "\n" . $debug_index[$i]['explain'];
            $output .= "Query took " . number_format( $debug_index[$i]['duration'], 6 ) . " seconds, or " . number_format( $debug_index[$i]['duration'] / self::$total_time * 100, 2 ) . "% of the total time.";
            $output .= "\n\n";
          }
          $output = "Total time: " . self::$total_time . " seconds.\n\n" . $output;
          $output = "Total queries: " . self::$total . "\n\n" . $output;
          $output = "Request URI: " . action::get( "request/self" ) . "\n\n" . $output;
          fwrite( $file, $output );
          fclose( $file );
        }
      }
    }

    public static function sort_debug_index( $a, $b ) {
      $a_percent = $a['duration'] / self::$total_time;
      $b_percent = $b['duration'] / self::$total_time;
      if( $a_percent > $b_percent ) {
        return -1;
      } else if( $a_percent < $b_percent ) {
        return 1;
      }
      return 0;
    }

    public static function result() {
			if( !isset( self::$result[self::$current_result+1] ) ) {
				self::query();
			}
			if( isset( self::$result[self::$current_result] ) ) {
				if( !$val = pg_fetch_array( self::$result[self::$current_result] ) ) {
          self::clear_result();
				}
				return $val;
			} else {
				self::clear_result();
				return false;
			}
		}

    public static function clear_result() {
      if( self::$current_result >= 0 ) {
        if( isset( self::$result[self::$current_result] ) ) {
          pg_free_result( self::$result[self::$current_result] );
        }
        self::$result[self::$current_result] = NULL;
        self::$current_result--;
      }
		}

		public static function affected() {
			if( !self::$result ) {
				self::query();
			}
			return count( self::$result );
		}

    public static function select_sql() {
      if( self::$query_open ) {
        return self::$top_query->select_sql();
      }
      return NULL;
    }

    public static function set( $column, $value, $escape = true ) {
			self::$current_query->set( $column, $value, $escape );
		}

		public static function insert() {
			$sql = self::$top_query->insert_sql();
			self::clear();
			if( !self::sql_query( $sql ) ) {
				return false;
			}
			return true;
		}

    public static function insert_sql() {
      if( self::$query_open ) {
        return self::$top_query->insert_sql();
      }
      return NULL;
    }

    public static function id() {
			return self::sql_insertid();
		}

    public static function update() {
			$sql = self::$top_query->update_sql();
			self::clear();
			if( !self::sql_query( $sql ) ) {
				return false;
			}
			return true;
		}

    public static function update_sql() {
      if( self::$query_open ) {
        return self::$top_query->update_sql();
      }
      return NULL;
    }

    public static function delete() {
			$sql = self::$top_query->delete_sql();
			self::clear();
			if( !self::sql_query( $sql ) ) {
				return false;
			}
			return true;
		}

    public static function delete_sql() {
      if( self::$query_open ) {
        return self::$top_query->delete_sql();
      }
      return NULL;
    }

    public static function error() {
			return self::sql_error();
		}

    public static function sql_query( $sql ) {
			return pg_query( self::$connection, $sql );
		}

		public static function sql_numrows( $resource ) {
			return pg_num_rows( $resource );
		}

		public static function sql_fetchrow( $resource ) {
			return pg_fetch_array( $resource );
		}

		public static function sql_insertid() {
			//return mysql_insert_id( self::$connection );
      return 0;
		}

		public static function sql_affected() {
			return pg_affected_rows( self::$connection );
		}

		public static function sql_error() {
			return pg_errormessage( self::$connection );
		}

		public static function sql_freeresult( $resource ) {
			return pg_free_result( $resource );
		}

  }

  class dbquery {

    private $parent = NULL;

    private $tables = array();
		private $selects = array();
		private $wheres = array();
		private $values = array();
		private $limit = NULL;
		private $order = NULL;
		private $group = NULL;

		private $current_table = NULL;
		private $where_or = false;
		private $table_level = 0;
		private $block_level = 0;
		private $current_alias = 0;
		private $current_block = 0;
    private $select_alias = NULL;

		private $index = array();
		private $children = array();
		private $level = 0;
		private $table = NULL;

    private $union = NONE;
    private $encased = false;
    private $union_query = NULL;

    public function dbquery( $parent = NULL, $union = NONE, $encased = false ) {
      $this->parent = $parent;
      $this->union = $union;
      $this->encased = $encased;
    }

    public function get_parent() {
      return $this->parent;
    }

    public function get_union() {
      return $this->union;
    }

    public function start_block() {
      $this->block_level++;
    }

    public function end_block() {
      $this->block_level--;
    }

    public function union( $query ) {
      $this->union_query = $query;
    }

    public function open( $table, $join, $query = NULL ) {
			$alias = $table . "_t" . $this->current_alias;
			$insert_array = array(
				"table" => $table,
				"alias" => $alias,
				"index" => $this->current_alias,
				"join" => $join,
				"wheres" => array(),
        "havings" => array(),
				"selects" => array(),
				"values" => array(),
        "subquery" => $query != NULL ? $query : false
			);
			$this->children[$this->current_alias] = array();
			if( $this->level > 0 ) {
				$insert_array['parent'] = $this->table;
				$this->children[$this->table['index']][] = $insert_array;
				$this->table = &$this->children[$this->table['index']][count($this->children[$this->table['index']])-1];
			} else {
				$this->index[] = $insert_array;
				$this->table = &$this->index[count($this->index)-1];
			}
			$this->level++;
			$this->current_alias++;
      return $alias;
		}

    public function open_blank() {
      $insert_array = array(
				"table" => "",
				"alias" => "",
				"index" => $this->current_alias,
				"join" => NONE,
				"wheres" => array(),
        "havings" => array(),
				"selects" => array(),
				"values" => array(),
        "subquery" => false
			);
      if( $this->level > 0 ) {
        $insert_array['parent'] = $this->table;
        $this->children[$this->table['index']][] = $insert_array;
        $this->table = &$this->children[$this->table['index']][count($this->children[$this->table['index']])-1];
      } else {
        $this->index[] = $insert_array;
        $this->table = &$this->index[count($this->index)-1];
      }
      $this->level++;
      $this->current_alias++;
    }

    public function open_subquery( $query, $join ) {
      $this->open( NULL, $join, $query );
    }

    public function close() {
			$this->level--;
			$this->table = &$this->table['parent'];
		}

		/* WHERE FUNCTIONS */

		public function where_and() {
			$this->where_or = false;
		}

		public function where_or() {
			$this->where_or = true;
		}

    public function where( $column, $value, $suffix, $function, $escape, $query = NULL ) {
			if( $escape ) {
				if( !is_int( $value ) ) {
					$value = "'" . str_replace( "'", "\'", $value ) . "'";
				}
			}
			$this->table['wheres'][] = array(
				"table" => $this->table['alias'],
				"column" => $column,
				"value" => $value,
				"or" => $this->where_or,
				"block" => $this->block_level,
				"suffix" => $suffix,
				"function" => $function,
        "subquery" => $query != NULL ? $query : false
			);
		}

    public function where_subquery_column( $query, $value, $suffix, $function ) {
      $this->where( NULL, $value, $suffix, $function, false, $query );
    }

    public function where_subquery_value( $query, $column, $suffix, $function ) {
      $this->where( $column, NULL, $suffix, $function, false, $query );
    }

    public function having( $column, $value, $suffix, $function, $escape, $query = NULL ) {
      if( $escape ) {
        if( !is_int( $value ) ) {
          $value = "'" . str_replace( "'", "\'", $value ) . "'";
        }
      }
      $this->table['havings'][] = array(
        "table" => $this->table['alias'],
        "column" => $column,
        "value" => $value,
        "or" => $this->where_or,
        "block" => $this->block_level,
        "suffix" => $suffix,
        "function" => $function
      );
    }

    public function link( $column, $level ) {
			$table = $this->table;
			for( $i = 0; $i < $level; $i++ ) {
				$table = $table['parent'];
			}
			$alias = $table['alias'];
			$this->where( $column, $alias . "." . $column, "", "", false );
		}

    public function loose_link( $column1, $column2, $level ) {
			$table = $this->table;
      $alias1 = $table['alias'];
			for( $i = 0; $i < $level; $i++ ) {
				$table = $table['parent'];
			}
			$alias2 = $table['alias'];
			$this->where( $alias1 . "." . $column1, $alias2 . "." . $column2, "", "", false );
		}

    public function select_as( $alias = "" ) {
			if( !$alias ) {
				if( $this->select_alias ) {
					$temp_alias = $this->select_alias;
					$this->select_alias = "";
					return " AS " . $temp_alias;
				}
			}
			return $this->select_alias = $alias;
		}

		public function select( $columns, $use_alias = true ) {
      $total_columns = count( $columns );
			for( $i = 0; $i < $total_columns; $i++ ) {
				$this->table['selects'][] = ( $use_alias ? $this->table['alias'] . "." : "" ) . $columns[$i] . $this->select_as();
			}
		}

    public function select_subquery( $query ) {
      $this->table['selects'][] = $query;
    }

    public function select_none() {
      $this->table['selects'] = array("");
    }

		public function select_count( $column ) {
			$this->table['selects'][] = "COUNT( " . $this->table['alias'] . "." . $column . " )" . $this->select_as();
		}

    public function select_count_distinct( $column ) {
			$this->table['selects'][] = "COUNT( DISTINCT " . $this->table['alias'] . "." . $column . " )" . $this->select_as();
		}

    public function select_count_all() {
			$this->table['selects'][] = "COUNT( * )" . $this->select_as();
		}

    public function select_sum( $column ) {
			$this->table['selects'][] = "SUM( " . $this->table['alias'] . "." . $column . " )" . $this->select_as();
		}

		public function select_max( $column ) {
			$this->table['selects'][] = "MAX( " . $this->table['alias'] . "." . $column . " )" . $this->select_as();
		}

		public function select_min( $column ) {
			$this->table['selects'][] = "MIN( " . $this->table['alias'] . "." . $column . " )" . $this->select_as();
		}

		public function select_timestamp( $column ) {
			$this->table['selects'][] = "UNIX_TIMESTAMP( " . $this->table['alias'] . "." . $column . " )" . $this->select_as();
		}

    public function order( $column, $order, $use_alias ) {
			if( strlen( $this->order ) > 0 ) {
				$this->order .= ", ";
			}
			$this->order .= ( $use_alias ? $this->table['alias'] . "." : "" ) . $column . " " . strtoupper( $order );
		}

		public function group( $column, $use_alias ) {
			if( strlen( $this->group ) > 0 ) {
				$this->group .= ", ";
			}
			$this->group .= ( $use_alias ? $this->table['alias'] . "." : "" ) . $column;
		}

		public function limit( $start, $total ) {
			$this->limit = array();
			$this->limit['start'] = $start;
			$this->limit['total'] = $total;
		}

    public function select_sql() {
			$select = "SELECT ";
			$from = " FROM ";
			$where = " WHERE ";
      $having = " HAVING ";

			$this->parse_select( $this->index, $select, $from, $where, $having );

			$sql = $select;
      if( $from != " FROM " ) {
        $sql .= $from;
      }
			if( $where != " WHERE " ) {
				$sql .= $where;
			}
			if( $this->group ) {
				$sql .= " GROUP BY " . $this->group;
			}
      if( $having != " HAVING " ) {
        $sql .= $having;
      }
			if( $this->order ) {
				$sql .= " ORDER BY " . $this->order;
			}
			if( $this->limit ) {
				$sql .= " LIMIT " . $this->limit['start'] . " OFFSET " . $this->limit['total'];
			}
      if( $this->encased ) {
        $sql = "( " . $sql . " )";
      }
      if( $this->union_query != NULL ) {
        $sql .= " UNION ";
        switch( $this->union_query->get_union() ) {
          case ALL:
            $sql .= "ALL ";
            break;
          case DISTINCT:
            $sql .= "DISTINCT ";
            break;
        }
        $sql .= $this->union_query->select_sql();
      }
			return $sql;
		}

		private function parse_select( $index, &$select, &$from, &$where, &$having ) {
			$total_children = count( $index );
			for( $i = 0; $i < $total_children; $i++ ) {
				$this->parse_from( $index[$i], $from );
				$total_selects = count( $index[$i]['selects'] );
				for( $j = 0; $j < $total_selects; $j++ ) {
					if( $select != "SELECT " ) {
            if( is_string( $index[$i]['selects'][$j] ) && $index[$i]['selects'][$j] ) {
              $select .= ", ";
            }
					}
          if( !is_string( $index[$i]['selects'][$j] ) ) {
            $select .= "( " . $index[$i]['selects'][$j]->select_sql() . " )";
          } else {
            $select .= $index[$i]['selects'][$j];
          }
				}
				if( !$total_selects ) {
					if( $select != "SELECT " ) {
						$select .= ", ";
					}
					$select  .= $index[$i]['alias'] . ".*";
				}
        if( isset( $this->children[$index[$i]['index']] ) ) {
          $this->parse_select( $this->children[$index[$i]['index']], $select, $from, $where, $having );
        }
				if( !isset( $index[$i]['parent'] ) ) {
					$this->parse_where( $index[$i], $where );
          $this->parse_having( $index[$i], $having );
				} else {
					if( count( $this->children[$index[$i]['index']] ) ) {
						$from .= " )";
					}
          if( count( $index[$i]['wheres'] ) ) {
            $from .= " ON ";
            $this->parse_where( $index[$i], $from );
            $this->parse_having( $index[$i], $having );
          }
				}
			}
		}

    public function set( $column, $value, $escape = true ) {
			if( !is_int( $value ) && $escape ) {
				$value = "'" . str_replace( "'", "\'", $value ) . "'";
			}
			$this->table['values'][] = array( "table" => $this->table['alias'], "column" => $column, "value" => $value );
		}

    public function insert_sql() {
			$insert = "";
			$this->parse_insert( $this->index, $insert );
			return $insert;
		}

		private function parse_insert( $index, &$insert ) {
			$total_children = count( $index );
			for( $i = 0; $i < $total_children; $i++ ) {
				$insert .= "INSERT INTO " . $index[$i]['table'] . " ( ";
				$values = "";
				$total_values = count( $index[$i]['values'] );
				for( $j = 0; $j < $total_values; $j++ ) {
					if( $j > 0 ) {
						$insert .= ", ";
						$values .= ", ";
					}
					$insert .= $index[$i]['values'][$j]['column'];
					$values .= $index[$i]['values'][$j]['value'];
				}
				$insert .= " ) VALUES ( " . $values . " ); ";

				$this->parse_insert( $this->children[$index[$i]['index']], $insert );
			}
		}

    public function update_sql() {
			$update = "UPDATE ";
			$set = " SET ";
			$where = " WHERE ";

			$this->parse_update( $this->index, $update, $set, $where );

			$sql = $update;
			$sql .= $set;
			if( $where != " WHERE " ) {
				$sql .= $where;
			}
			return $sql;
		}

		private function parse_update( $index, &$update, &$set, &$where ) {
			$total_children = count( $index );
			for( $i = 0; $i < $total_children; $i++ ) {
				$this->parse_from( $index[$i], $update, true );
				$total_values = count( $index[$i]['values'] );
				for( $j = 0; $j < $total_values; $j++ ) {
					if( $set != " SET " ) {
						$set .= ", ";
					}
					$set .= $index[$i]['values'][$j]['column'] . " = " . $index[$i]['values'][$j]['value'];
				}
				$this->parse_update( $this->children[$index[$i]['index']], $update, $set, $where );
				if( !isset( $index[$i]['parent'] ) ) {
					self::parse_where( $index[$i], $where, true );
				} else {
					if( count( $this->children[$index[$i]['index']] ) ) {
						$update .= " )";
					}
					$update .= " ON ";
					$this->parse_where( $index[$i], $update, true );
				}
			}
		}

    public function delete_sql() {
			$delete = "DELETE ";
			$from = " FROM ";
			$where = " WHERE ";

			$this->parse_delete( $this->index, $delete, $from, $where );

			$sql = $delete . $from;
			if( $where != " WHERE " ) {
				$sql .= $where;
			}
			return $sql;
		}

		private function parse_delete( $index, &$delete, &$from, &$where ) {
			$total_children = count( $index );
			for( $i = 0; $i < $total_children; $i++ ) {
				if( $delete != "DELETE " ) {
					$delete .= ", ";
				}
				$delete .= $index[$i]['alias'];
				$this->parse_from( $index[$i], $from );
				$this->parse_delete( $this->children[$index[$i]['index']], $delete, $from, $where );
				if( !isset( $index[$i]['parent'] ) ) {
					$this->parse_where( $index[$i], $where );
				} else {
					if( count( $this->children[$index[$i]['index']] ) ) {
						$delete .= " )";
					}
					$delete .= " ON ";
					$this->parse_where( $index[$i], $update );
				}
			}
		}

		private function parse_from( $tbl, &$from, $ignore_alias = false ) {
      if( isset( $tbl['parent'] ) ) {
        switch( $tbl['join'] ) {
          case NONE:
            $from .= " JOIN ";
            break;
          case LEFT:
            $from .= " LEFT JOIN ";
            break;
          case RIGHT:
            $from .= " RIGHT JOIN ";
            break;
          case FULL:
            $from .= " FULL JOIN ";
            break;
        }
        if( count( $this->children[$tbl['index']] ) ) {
          $from .= " ( ";
        }
      }
      if( !is_bool( $tbl['subquery'] ) ) {
        $from .= " ( " . $tbl['subquery']->select_sql() . " ) ";
      } else {
        $from .= $tbl['table'];
      }
      if( $tbl['alias'] && !$ignore_alias ) {
        $from .= " AS " . $tbl['alias'];
      }
		}

		private function parse_where( $index, &$where, $ignore_alias = false ) {
			$total_wheres = count( $index['wheres'] );
			$current_block = 0;
			for( $i = 0; $i < $total_wheres; $i++ ) {
				if( $i > 0 ) {
					for( $j = 0; $j < $current_block - $index['wheres'][$i]['block']; $j++ ) {
						$where .= " ) ";
					}
					if( $index['wheres'][$i]['or'] ) {
						$where .= " OR ";
					} else {
						$where .= " AND ";
					}
				}
				if( $index['wheres'][$i]['block'] > $current_block ) {
					$where .= " ( ";
				}
        if( $index['wheres'][$i]['function'] ) {
          $where .= $index['wheres'][$i]['function'] . "( ";
        }
        if( !is_bool( $index['wheres'][$i]['subquery'] ) && $index['wheres'][$i]['column'] == NULL ) {
          $where .= "( " . $index['wheres'][$i]['subquery']->select_sql() . " ) ";
        } else {
          $where .= ( $ignore_alias ? "" : $index['alias'] . "." ) . $index['wheres'][$i]['column'] . " ";
        }
        if( $index['wheres'][$i]['function'] ) {
          $where .= ") ";
        }
        if( $index['wheres'][$i]['suffix'] ) {
          $where .= $index['wheres'][$i]['suffix'] . " ";
        } else {
          $where .= "= ";
        }
        if( !is_bool( $index['wheres'][$i]['subquery'] ) && $index['wheres'][$i]['value'] == NULL ) {
          $where .= "( " . $index['wheres'][$i]['subquery']->select_sql() . " )";
        } else {
          $where .= $index['wheres'][$i]['value'];
        }
        $current_block = $index['wheres'][$i]['block'];
			}
			while( $current_block > 0 ) {
				$where .= " ) ";
				$current_block--;
			}
		}

    private function parse_having( $index, &$having ) {
			$total_havings = count( $index['havings'] );
			$current_block = 0;
			for( $i = 0; $i < $total_havings; $i++ ) {
				if( $having !== " HAVING " ) {
					for( $j = 0; $j < $current_block - $index['havings'][$i]['block']; $j++ ) {
						$having .= " ) ";
					}
					if( $index['havings'][$i]['or'] ) {
						$having .= " OR ";
					} else {
						$having .= " AND ";
					}
				}
				if( $index['havings'][$i]['block'] > $current_block ) {
					$having .= " ( ";
				}
        $having .= $index['alias'] . "." . $index['havings'][$i]['column'] . " ";
        if( $index['havings'][$i]['suffix'] ) {
          $having .= $index['havings'][$i]['suffix'] . " ";
        } else {
          $having .= "= ";
        }
        if( $index['havings'][$i]['function'] ) {
          $having .= $index['havings'][$i]['function'] . "( ";
        }
        $having .= ( $index['havings'][$i]['function'] ? $index['alias'] . "." : "" ) . $index['havings'][$i]['value'];
        if( $index['havings'][$i]['function'] ) {
          $having .= ") ";
        }
        $current_block = $index['havings'][$i]['block'];
			}
			while( $current_block > 0 ) {
				$having .= " ) ";
				$current_block--;
			}
		}

  }

?>

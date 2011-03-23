<?php

$output_encoding = false;
$start = microtime( true );
error_reporting( E_ALL );
define( "DEFAULT_TIMEZONE", date_default_timezone_get() );
date_default_timezone_set( "UTC" );
define( "LINE_BREAK", "<br />" );
require_once( "system.php" );

//Load the settings document
if( !$settings_xml = simplexml_load_file( "settings.php" ) ) {
  sys::message( SYSTEM_ERROR, "ERROR", "The settings XML document could not be located.", __FILE__, __LINE__ );
}

$settings = array();
foreach( $settings_xml->setting as $setting ) {
  $settings[$setting['id'].''] = $setting;
}

//Define some global constants
define( "DEFAULT_LANG", $settings['default_language'] );
define( "ROOT_DIR", "." );
define( "RELATIVE_DIR", $settings['script_path'] );
define( "INCLUDE_DIR", ROOT_DIR . "/" . $settings['include_dir'] );
define( "DATABASE_DIR", INCLUDE_DIR . "/" . $settings['database_dir'] );
define( "CACHE_DIR", INCLUDE_DIR . "/" . $settings['cache_dir'] );
define( "CONTENT_DIR", INCLUDE_DIR . "/" . $settings['content_dir'] );
define( "LANGUAGE_DIR", INCLUDE_DIR . "/" . $settings['language_dir'] );
define( "EXTENSIONS_DIR", ROOT_DIR . "/" . $settings['extensions_dir'] );
define( "STYLES_DIR", ROOT_DIR . "/" . $settings['styles_dir'] );
define( "EMAIL_DIR", ROOT_DIR . "/" . $settings['email_dir'] );

//Require some necessary files
require_once( INCLUDE_DIR . "/account.php" );
require_once( INCLUDE_DIR . "/action.php" );
require_once( INCLUDE_DIR . "/authentication.php" );
require_once( INCLUDE_DIR . "/constants.php" );
require_once( INCLUDE_DIR . "/email.php" );
require_once( INCLUDE_DIR . "/facebook.php" );
require_once( INCLUDE_DIR . "/language.php" );
require_once( INCLUDE_DIR . "/template.php" );
require_once( INCLUDE_DIR . "/xsl.php" );

action::start( "settings" );
foreach( $settings as $key => $val ) {
  action::add( $key, $val );
}
action::end();
unset( $settings );

//Initialize our language engine
lang::initialize( LANGUAGE_DIR, DEFAULT_LANG );

//Connect to the database
define( "DATABASE_ENABLED", action::get( "settings/database_type" ) ? true : false );
if( DATABASE_ENABLED ) {
  require_once( DATABASE_DIR . "/" . action::get( "settings/database_type" ) . "/db_" . action::get( "settings/database_type" ) . ".php" );
  if( (int)action::get( "settings/debug" ) ) {
    db::enable_debugging();
  }
  db::connect( action::get( "settings/database_server" ), action::get( "settings/database_name" ), action::get( "settings/database_username" ), action::get( "settings/database_password" ) );
}

//Load the table listing
if( !$tables_xml = simplexml_load_file( "tables.php" ) ) {
  sys::message( SYSTEM_ERROR, lang::phrase( "main/tables_error/title" ), lang::phrase( "main/tables_error/body" ), __FILE__, __LINE__ );
}
foreach( $tables_xml->table as $table ) {
  define( "TABLE_" . strtoupper($table['id'].''), $table );
}
unset( $tables_xml );

if( action::get( "settings/cache_type" ) ) {

  require_once( CACHE_DIR . "/" . action::get( "settings/cache_type" ) . "/cache_" . action::get( "settings/cache_type" ) . ".php" );
  define( "CACHE_ENABLED", true );
} else {
  require_once( CACHE_DIR . "/default/cache_default.php" );
  define( "CACHE_ENABLED", false );
}

if( action::get( "settings/cdn_type" ) ) {
  require_once( CONTENT_DIR . "/" . action::get( "settings/cdn_type" ) . "/cdn_" . action::get( "settings/cdn_type" ) . ".php" );
  define( "CONTENT_ENABLED", true );
} else {
  define( "CONTENT_ENABLED", false );
}

if( DATABASE_ENABLED ) {
  //Load all of the installed extensions
  sys::list_extensions();
  $total_extensions = action::total( "extension_list/extension" );
  for( $i = 0; $i < $total_extensions; $i++ ) {
    if( (boolean)action::get( "extension_list/extension/active", $i ) ) {
      $extension_name = action::get( "extension_list/extension/name", $i );
      require( EXTENSIONS_DIR . "/" . $extension_name . "/ext_" . $extension_name . ".php" );
      lang::add( EXTENSIONS_DIR . "/" . $extension_name . "/language" );
      action::merge( simplexml_load_string( "<title>" . lang::phrase( $extension_name . "/title" ) . "</title>" ), "extension_list/extension", $i );
      unset( $extension_name );
    }
  }
  unset( $total_extensions );
}

$uri = parse_url( $_SERVER['REQUEST_URI'] );
$path = preg_replace( "/" . str_replace( "/", "\/", action::get( "settings/script_path" ) . "/" ) . "/si", "", $uri['path'], 1 );
$uri_split = explode( "/", $path );
if( !$uri_split[count($uri_split)-1] ) {
  array_pop( $uri_split );
}
$self = $_SERVER['REQUEST_URI'];
if( isset( $uri_split[0] ) && $uri_split[0] == "index.php" ) {
  $extension = sys::input( "extension", "" );
  $action = sys::input( "action", "" );
  $template = sys::input( "template", "" );
  $no_header = sys::input( "no_header", false );
  if( $extension && $action ) {
    action::start( "request" );
      action::add( "extension", $extension );
      action::add( "action", $action );
      action::add( "template", $template );
    action::end();
    if( action::get( "settings/enable_accounts" ) ) {
      account::initialize( false );
    }
    if( sys::setting( "global", "maintenance_mode" ) ) {
      if( !auth::test( "global", "bypass_maintenance" ) ) {
        sys::message( MAINTENANCE_ERROR, "Maintenance Underway", sys::setting( "global", "maintenance_message" ) );
      }
    }
    action::start( "request" );
      action::add( "page", $path );
      action::add( "self", $_SERVER['REQUEST_URI'] );
      action::add( "urlencoded_self", urlencode( $_SERVER['REQUEST_URI'] ) );
      action::add( "language", DEFAULT_LANG );
      action::add( "root", RELATIVE_DIR );
    action::end();
    action::call( $extension, $action );
    if( !$template ) {
      action::remove( "settings" );
    }
    $response = action::response();
    $response = $response->saveXML();
    if( $template ) {
      process_template( explode("/",$template), $style_dir, $template_dir, $template_page );
      tpl::initialize( $style_dir, $template_dir );
      $response = tpl::load( $template_page );
      
    } else if( !$no_header ) {
      header( "Content-type: text/xml" );
    }
    echo $response;
    exit();
  } else {
    sys::message( APPLICATION_ERROR, lang::phrase( "main/missing_action_error/title" ), lang::phrase( "main/missing_action_error/body" ), __FILE__, __LINE__ );
  }
} else {
  action::start( "request" );
    action::add( "page", $path );
    action::add( "self", $_SERVER['REQUEST_URI'] );
    action::add( "urlencoded_self", urlencode( $_SERVER['REQUEST_URI'] ) );
    action::add( "language", DEFAULT_LANG );
    action::add( "root", RELATIVE_DIR );
  action::end();
  process_template( $uri_split, $style_dir, $template_dir, $template_page, $feed );
  if( $template_page != "index" || $template_dir ) {
    $create_static = false;
  }
  action::resume( "request" );
    action::start( "template" );
      action::add( "page", $template_page );
      action::add( "directory", $template_dir );
    action::end();
    action::add( "feed", $feed ? 1 : 0 );
  action::end();

  

  tpl::initialize( $style_dir, $template_dir );
  if( action::get( "settings/enable_accounts" ) ) {
    account::initialize();
  }
  if( sys::setting( "global", "maintenance_mode" ) ) {
    if( !auth::test( "global", "bypass_maintenance" ) ) {
      sys::message( MAINTENANCE_ERROR, "Maintenance Underway", sys::setting( "global", "maintenance_message" ) );
    }
  }
  $bypass_maintenance = false;
  if( auth::test( "global", "bypass_maintenance" ) ) {
    error_reporting( E_ALL );
    $bypass_maintenance = true;
  }
  if( !$feed && $output_encoding ) {
    ob_start( "ob_gzhandler" );
  }
  if( $feed ) {
    $create_static = false;
  }
  
  ob_start();
  echo tpl::load( $template_page );
  
  $view_actions = sys::input( "view_actions", false );
  if( $view_actions ) {
    if( $bypass_maintenance ) {
      ob_end_clean();
      header( "Content-type: text/xml" );
      echo action::response()->saveXML();
      exit();
    }
  }
  action::clear();

  $end = microtime(true);
  $total = ( $end - $start );

  if( !$feed && $output_encoding ) {
    $HTTP_ACCEPT_ENCODING = $_SERVER["HTTP_ACCEPT_ENCODING"];
    if( headers_sent() ) {
      $encoding = false;
    } else if( strpos($HTTP_ACCEPT_ENCODING, 'x-gzip') !== false ) {
      $encoding = 'x-gzip';
    } else if( strpos($HTTP_ACCEPT_ENCODING,'gzip') !== false ) {
      $encoding = 'gzip';
    } else {
      $encoding = false;
    }

    if( $encoding ) {
      //echo "\n\n<!-- Generated in " . ( $total ) . " seconds. -->";
      $contents = ob_get_clean();
      $_temp1 = strlen($contents);
      if ($_temp1 < 2048) {
        print($contents);
      } else {
        header('Content-Encoding: '.$encoding);
        print("\x1f\x8b\x08\x00\x00\x00\x00\x00");
        $contents = gzcompress($contents, 9);
        $contents = substr($contents, 0, $_temp1);
        print($contents);
      }
    } else {
      //echo "\n\n<!-- Generated in " . ( $total ) . " seconds. -->";
      ob_end_flush();
    }
  } else {
    //echo "\n\n<!-- Generated in " . ( $total ) . " seconds. -->";
  }
  if( DATABASE_ENABLED ) {
    db::print_log();
  }
  ob_end_flush();
}

function process_template( $uri_split, &$style_dir, &$template_dir, &$template_page, &$feed = false ) {
  $total_vars = count( $uri_split );
  if( count( $uri_split) > 0 && $uri_split[count($uri_split)-1] == "feed" ) {
    $style_dir = ROOT_DIR . "/feeds";
    array_pop( $uri_split );
    $total_vars--;
    $feed = true;
  } else if( isset( $uri_split[0] ) && file_exists( ROOT_DIR . "/" . $uri_split[0] ) ) {
    $style_dir = ROOT_DIR . "/" . $uri_split[0];
    array_shift( $uri_split );
    $total_vars--;
  } else {
    $style_dir = STYLES_DIR . "/" . action::get( "settings/default_style" );
  }
  $template_dir = "";
  $template_page = "";
  $page_found = false;
  for( $i = 0; $i < $total_vars; $i++ ) {
    if( isset( $uri_split[$i] ) && strlen( $uri_split[$i] ) > 0 ) {
      if( strlen( $template_dir ) > 0 && substr( $template_dir, -1 ) != "/" ) {
        $template_dir .= "/";
      }
      $split_replace = str_replace( "-", "_", $uri_split[$i] );
      if( file_exists( $style_dir . "/" . $template_dir . $split_replace ) ) {
        $template_dir .= $split_replace;
        array_shift( $uri_split );
        $i--;
        $total_vars--;
      } else {
        break;
      }
    }
    if( strlen( $template_page ) > 0 && file_exists( $style_dir . "/" . $template_dir . $template_page . ".xsl" ) ) {
      $splice = array_splice( $uri_split, 0, $i+1 );
      $total_vars -= count( $splice );
      $page_found = true;
      break;
    }
  }
  action::start( "url_variables" );
  for( $i = 0; $i < $total_vars; $i++ ) {
    if( strlen( $uri_split[$i] ) ) {
      action::add( "var", urldecode( $uri_split[$i] ) );
    }
  }
  action::end();
  if( !$page_found ) {
    $template_page = "index";
    if( !file_exists( $style_dir . "/" . $template_page . ".xsl" ) ) {
      $style_dir = STYLES_DIR . "/" . action::get( "settings/default_style" );
    }
    return false;
  }
  return true;
}

?>
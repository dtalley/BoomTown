<?php
	
	class account {
		
		public static function initialize( $call_hooks = true ) {

      $error_reason = sys::input( "error_reason", "unknown_error" );
      $error = sys::input( "error", null );
      if( $error ) {
        sys::message(
          USER_ERROR,
          lang::phrase( "account/error/" . $error_reason . "/title" ),
          lang::phrase( "account/error/" . $error_reason . "/body" )
        );
      }

      $code = sys::input( "code", null );
      $app_id = sys::setting( "facebook", "fbapp_id" );
      $api_key = sys::setting( "facebook", "fbapi_key" );
      $app_secret = sys::setting( "facebook", "fbapp_secret" );
      $canvas = urlencode( sys::setting( "facebook", "fbcanvas" ) );
      $current_datetime = sys::create_datetime( time() );

      action::resume( "facebook" );
        action::add( "app_id", $app_id );
        action::add( "api_key", $api_key );
        action::add( "canvas", $canvas );
      action::end();

      $auth_url = "http://www.facebook.com/dialog/oauth?client_id=";
      $auth_url .= $app_id;
      $auth_url .= "&redirect_uri=";
      $auth_url .= $canvas;
      $auth_url .= "&scope=user_birthday,email";

      $signed_request = sys::input( "signed_request", null, SKIP_GET );
      if( $signed_request ) {
        list( $encoded_sig, $payload ) = explode( ".", $signed_request, 2 );
        $data = json_decode( base64_decode( strtr( $payload, "-_", "+/" ) ), true );

        if( strtoupper( $data['algorithm'] ) !== 'HMAC-SHA256' ) {
          sys::message( 
            USER_ERROR,
            lang::phrase( "account/error/wrong_fb_authorization_algorithm/title" ),
            lang::phrase( "account/error/wrong_fb_authorization_algorithm/body" )
          );
        }

        $sig = base64_decode( strtr( $encoded_sig, "-_", "+/" ) );
        $expected_sig = hash_hmac( "sha256", $payload, $app_secret, true );
        if( $sig !== $expected_sig ) {
          sys::message(
            USER_ERROR,
            lang::phrase( "account/error/bad_signed_fb_signature/title" ),
            lang::phrase( "account/error/bad_signed_fb_signature/body" )
          );
        }
      } else {
        $data = null;
      }

      action::resume( "account" );
        action::add( "auth_url", $auth_url );
        action::add( "logged_in", ( empty( $data['user_id'] ) || !$code ) ? 0 : 1 );
        if( !empty( $data['user_id'] ) && $code ) {
          db::open( TABLE_USERS );
            db::where( "user_id", $data['user_id'] );
          $user = db::result();
          db::clear_result();
          if( !$user ) {
            $token_url  = "https://graph.facebook.com/oauth/access_token?client_id=";
            $token_url .= $app_id;
            $token_url .= "&redirect_uri=" . $canvas;
            $token_url .= "&client_secret=" . $app_secret;
            $token_url .= "&code=" . $code;
            $access_token = facebook::graph_call( $token_url );
            $user_url = "https://graph.facebook.com/me?" . $access_token;
            $user = json_decode( facebook::graph_call( $user_url ), true );

            db::open( TABLE_USERS );
              db::set( "user_id", $data['user_id'] );
              db::set( "user_created", $current_datetime );
              db::set( "user_activity", $current_datetime );
              db::set( "user_timezone", $user['timezone'] );
              db::set( "user_name", $user['name'] );
              db::set( "user_first_name", $user['first_name'] );
              db::set( "user_last_name", $user['last_name'] );
              db::set( "user_birthday", $user['birthday'] );
              db::set( "user_email", $user['email'] );
              db::set( "user_updated", $current_datetime );
            if( !db::insert() ) {
              sys::message(
                USER_ERROR,
                lang::phrase( "account/error/could_not_create_user/title" ),
                lang::phrase( "account/error/could_not_create_user/body" )
              );
            }
            db::open( TABLE_USERS );
              db::where( "user_id", $data['user_id'] );
            $user = db::result();
            db::clear_result();
          }
          if( !$user ) {
            sys::message(
              USER_ERROR,
              lang::phrase( "account/error/unknown_account_creation_error/title" ),
              lang::phrase( "account/error/unknown_account_creation_error/body" )
            );
          }
          action::add( "id", $user['user_id'] );
          action::start( "name" );
            action::add( "full", $user['user_name'] );
            action::add( "first", $user['user_first_name'] );
            action::add( "last", $user['user_last_name'] );
          action::end();
          action::add( "email", $user['user_email'] );
          action::add( "birthday", $user['user_birthday'] );
          action::start( "created" );
            action::add( "datetime", $user['user_created'] );
            $timestamp = strtotime( $user['user_created'] );
            action::add( "timestamp", $timestamp );
            $timestamp += sys::timezone( empty( $user['user_timezone'] ) ? -5 : $user['user_timezone'] ) * 60 * 60;
            action::add( "altered_datetime", sys::create_datetime( $timestamp ) );
            action::add( "altered_timestamp", $timestamp );
          action::end();
        }
      action::end();

		}
		
	}

?>
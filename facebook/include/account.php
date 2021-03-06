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
      $access_token = sys::input( "access_token", null );
      if( substr( $access_token, 0, 11 ) !== "access_token" ) {
        $access_token = "access_token=" . $access_token;
      }
      $app_id = sys::setting( "facebook", "fbapp_id" );
      $api_key = sys::setting( "facebook", "fbapi_key" );
      $app_secret = sys::setting( "facebook", "fbapp_secret" );
      $canvas = urlencode( sys::setting( "facebook", "fbcanvas" ) );
      $current_datetime = sys::create_datetime( time() );

      /**
       * If we have a code but no access token, retrieve the access token
       */
      if( $code && !$access_token ) {
        $token_url  = "oauth/access_token?client_id=";
        $token_url .= $app_id;
        $token_url .= "&redirect_uri=" . $canvas;
        $token_url .= "&client_secret=" . $app_secret;
        $token_url .= "&code=" . $code;
        $access_token = facebook::graph_call( $token_url );
      }

      $auth_url = "http://www.facebook.com/dialog/oauth?client_id=";
      $auth_url .= $app_id;
      $auth_url .= "&redirect_uri=";
      $auth_url .= $canvas;
      $auth_url .= "&scope=user_birthday,email";

      /**
       * Process the Facebook signed request, verify it, and pull out the data
       * which should include the user id.
       */
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

        //If the Facebook data variable isn't empty, the user is logged into Facebook
        action::add( "logged_in", ( empty( $data['user_id'] ) ) ? 0 : 1 );

        if( !empty( $data['user_id'] ) ) {
          db::open( TABLE_USERS );
            db::where( "user_id", trim( $data['user_id'] ) );
          $user = db::result();
          db::clear_result();
          /**
           * If no user exists in the database, create one based on the
           * information pulled from Facebook.
           */
          if( !$user ) {
            db::open( TABLE_USERS );
              db::set( "user_id", trim( $data['user_id'] ) );
              db::set( "user_created", $current_datetime );
              db::set( "user_activity", $current_datetime );
            if( !db::insert() ) {
              sys::message(
                USER_ERROR,
                lang::phrase( "account/error/could_not_create_user/title" ),
                lang::phrase( "account/error/could_not_create_user/body" )
              );
            }
            db::open( TABLE_USERS );
              db::where( "user_id", trim( $data['user_id'] ) );
            $user = db::result();
            db::clear_result();
          }
          /**
           * At this point if the user variable is not populated, something
           * has gone terribly wrong.
           */
          if( !$user ) {
            sys::message(
              USER_ERROR,
              lang::phrase( "account/error/unknown_account_creation_error/title" ),
              lang::phrase( "account/error/unknown_account_creation_error/body" )
            );
          }

          /**
           * Check the user's last facebook update time, and if their information
           * hasn't been pulled from Facebook in a while, pull it and update
           * their database entry.
           */
          if( isset( $user['user_updated'] ) ) {
            $user_updated = strtotime( $user['user_updated'] );
          } else {
            $user_updated = 0;
          }
          if( $user_updated + 60 * 60 * 24 * 2 < time() ) {
            $user_data = json_decode( facebook::graph_call( "me?" . $access_token ), true );
            if( isset( $user_data['updated_time'] ) ) {
              $facebook_updated = strtotime( $user_data['updated_time'] );
            } else {
              $facebook_updated = 0;
            }
            if( $facebook_updated > $user_updated ) {
              db::open( TABLE_USERS );
                db::set( "user_timezone", $user_data['timezone'] );
                db::set( "user_name", $user_data['name'] );
                db::set( "user_first_name", $user_data['first_name'] );
                db::set( "user_last_name", $user_data['last_name'] );
                db::set( "user_birthday", $user_data['birthday'] );
                db::set( "user_email", $user_data['email'] );
                db::set( "user_updated", $current_datetime );
                db::where( "user_id", $user['user_id'] );
              if( !db::update() ) {
                sys::message(
                  USER_ERROR,
                  lang::phrase( "account/error/could_not_update_user/title" ),
                  lang::phrase( "account/error/could_not_update_user/body" )
                );
              }
            }
          }
          
          action::add( "id", $user['user_id'] );
          action::start( "name" );
            action::add( "full", $user['user_name'] );
            action::add( "first", $user['user_first_name'] );
            action::add( "last", $user['user_last_name'] );
          action::end();
          action::add( "email", $user['user_email'] );
          action::add( "birthday", $user['user_birthday'] );

          $action_key = sys::random_chars(32);
          db::open( TABLE_USERS );
            db::set( "user_action_key", $action_key );
          if( !db::update() ) {
            sys::message(
              USER_ERROR,
              lang::phrase( "account/error/could_not_update_action_key/title" ),
              lang::phrase( "account/error/could_not_update_action_key/body" )
            );
          }
          action::add( "action_key", $action_key );
          
        }
      action::end();

      action::resume( "facebook" );
        action::add( "app_id", $app_id );
        action::add( "api_key", $api_key );
        action::add( "canvas", $canvas );
        action::add( "auth_url", $auth_url );
      action::end();
      
      if( $call_hooks ) {
        sys::hook( "account_initialized" );
      }

		}

    public static function update_token() {

      $code = sys::input( "code", null );
      $response = sys::input( "response", null );
      $user_id = sys::input( "user_id", null );
      $app_id = sys::setting( "facebook", "fbapp_id" );
      $app_secret = sys::setting( "facebook", "fbapp_secret" );
      $canvas = urlencode( sys::setting( "facebook", "fbcanvas" ) );

      if( $code && !$access_token ) {
        $token_url  = "https://graph.facebook.com/oauth/access_token?client_id=";
        $token_url .= $app_id;
        $token_url .= "&redirect_uri=" . $canvas;
        $token_url .= "&client_secret=" . $app_secret;
        $token_url .= "&code=" . $code;
        $access_token = facebook::graph_call( $token_url );
      }

      if( $response == "token_only" ) {
        echo $access_token;
        exit();
      }

    }

    public static function verify_user() {
      $user_id = sys::input( "user_id", "" );
      $action_key = sys::input( "action_key", "" );
      if( !$user_id || !$action_key ) {
        sys::message(
          USER_ERROR,
          lang::phrase( "account/error/commander_already_exists/title" ),
          lang::phrase( "account/error/commander_already_exists/body" ),
          NULL, NULL, __FUNCTION__, __CLASS__
        );
      }
      db::open( TABLE_USERS );
        db::where( "user_id", $user_id );
        db::where( "user_action_key", $action_key );
      $user = db::result();
      if( !$user ) {
        sys::message(
          USER_ERROR,
          lang::phrase( "account/error/invalid_user/title" ),
          lang::phrase( "account/error/invalid_user/body" ),
          NULL, NULL, __FUNCTION__, __CLASS__
        );
      }
    }
		
	}

?>
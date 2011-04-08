<?php

class facebook {

  public static function graph_call( $url, $post = NULL ) {
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, "https://graph.facebook.com/" . $url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
    curl_setopt($ch, CURLOPT_HEADER, 0);
    curl_setopt($ch, CURLOPT_HTTPHEADER, Array("Content-Type: application/x-www-form-urlencoded"));
    if( $post != NULL ) {
      curl_setopt($ch, CURLOPT_POST, 1 );
      curl_setopt($ch, CURLOPT_POSTFIELDS, $post );
    }
    $response = curl_exec($ch);
    curl_close($ch);

    return $response;
  }

  public static function verify_user( $user_id, $access_token ) {
    $response = self::graph_call( "me?access_token=" . $access_token );
    $user = json_decode( $response, true );
    if( $user['id'] !== $user_id ) {
      return false;
    }
    return true;
  }

}

?>

<?php

class facebook {

  public static function graph_call( $url, $post = NULL ) {
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
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

}

?>

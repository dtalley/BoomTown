<?php

	class email {
		
		private static $responses = array();
		private static $requirements = array();
		
		private static $styleTree;
		
		public static function send( $id, $format, $email_to, $email_from, $language, $subject ) {
			$output = self::load( $language, $id, $format );
			$headers = "From: $email_from" . "\r\n";
			$headers .= "Reply-To: $email_from" . "\r\n";
			if( $format == "html" ) {
				$headers .= "Content-type: text/html; charset=iso-8859-1" . "\r\n";
			}
			mail( $email_to, $subject, $output, $headers );
		}
		
		public static function load( $language, $id, $format, $recursive = 0 ) {
                  $email_id = $id . "_" . $format;
                  //Check for the comprehensive template, and create it if it doesn't exist
                  if( !xsl::comprehensive_exists( $email_id, EMAIL_DIR . "/" . $language ) ) {
                    if( $recursive < 5 ) {
                      $xsl = xsl::load_xsl( $email_id, EMAIL_DIR . "/" . $language );
                      xsl::create_comprehensive( $email_id, EMAIL_DIR . "/" . $language, $xsl );
                      return self::load( $language, $id, $format, $recursive + 1 );
                    } else {
                      sys::message(
                        SYSTEM_ERROR,
                        lang::phrase( "error/template/could_not_create_comprehensive/title" ),
                        lang::phrase( "error/template/could_not_create_comprehensive/body", self::$template . $id )
                      );
                    }
                  //Check for the page template, and create it if it doesn't exist
                  } else {
                    $xsl = xsl::load_comprehensive( $email_id, EMAIL_DIR . "/" . $language );
                    return xsl::apply( action::response(), $xsl );
                  }
		}
		
	}

?>
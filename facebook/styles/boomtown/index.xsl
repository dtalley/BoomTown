<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:magasi="http://www.magasi-php.com/magasi"
                xmlns:premagasi="http://www.magasi-php.com/premagasi"
                xmlns:prexsl="http://www.magasi-php.com/prexsl"
                xmlns:php="http://php.net/xsl"
                xsl:extension-element-prefixes="php magasi premagasi prexsl">

  <xsl:namespace-alias stylesheet-prefix="prexsl" result-prefix="xsl" />
  
  <xsl:variable name="style_dir" select="response/template/style_dir" />
  <xsl:variable name="root" select="response/request/root" />

  <xsl:template match="response">
    <html>
      <head>
        <title>BoomTown</title>
        <link type="text/css" rel="stylesheet" href="{$style_dir}/styles/index.css" />
        <script type="text/javascript">
          var fbAppId = "<xsl:value-of select="facebook/app_id" />";
          var fbApiKey = "<xsl:value-of select="facebook/api_key" />";
          var fbCanvas = "<xsl:value-of select="facebook/canvas" />";
        </script>
        <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
      </head>
      <body>
        <xsl:choose>
          <xsl:when test="account/logged_in = 0">
            <script type="text/javascript">top.location.href = "<xsl:value-of select="account/auth_url" />";</script>
          </xsl:when>
          <xsl:otherwise>
            <!--<iframe src="http://www.facebook.com/plugins/like.php?href=http%3A%2F%2Fapps.facebook.com%2Fboomtowngame&amp;layout=standard&amp;show_faces=false&amp;width=450&amp;action=like&amp;font&amp;colorscheme=light&amp;height=35" scrolling="no" frameborder="0" style="border:none; overflow:hidden; width:450px; height:35px;" allowTransparency="true"></iframe><br />-->
            <img src="{$style_dir}/images/main_header.jpg" id="header" /><br />
            <div id="content">
              <object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" width="760" height="600" id="gameflash">
                <param name="movie" value="{$style_dir}/flash/main.swf" />
                <!--[if !IE]>-->
                <object type="application/x-shockwave-flash" data="{$style_dir}/flash/main.swf" width="760" height="600">
                <!--<![endif]-->
                  <a href="http://www.adobe.com/go/getflashplayer">
                    <img src="http://www.adobe.com/images/shared/download_buttons/get_flash_player.gif" alt="Get Adobe Flash player" />
                  </a>
                <!--[if !IE]>-->
                </object>
                <!--<![endif]-->
              </object>
            </div>

            <div id="fb-root"></div>
            <script src="http://connect.facebook.net/en_US/all.js"></script>

            <script type="text/javascript" src="{$style_dir}/scripts/jquery.js"></script>
            <script type="text/javascript" src="{$style_dir}/scripts/swfobject.js"></script>
            <script type="text/javascript" src="{$style_dir}/scripts/index.js"></script>
            <script type="text/javascript">
              swfobject.registerObject("gameflash", "10.1.0", "expressInstall.swf");
            </script>
          </xsl:otherwise>
        </xsl:choose>
      </body>
    </html>
  </xsl:template>

</xsl:stylesheet>
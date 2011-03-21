<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	
	<xsl:output method="html" />
	
	<xsl:variable name="root" select="response/request/root" />
	
	<xsl:template match="response">
    <html>
      <head>
        <title>BoomTown is Temporarily Unavailable</title>
        <style type="text/css">
          html, body {
            height: 100%;
          }
          body {
            margin: 0;
            padding: 0;
            font-family: Arial, sans-serif;
            background-color: #FFFFFF;
            color: #444444;
          }
        </style>
      </head>
      <body>
        <strong><xsl:value-of select="message/title" /></strong><br /><br />
        <xsl:value-of select="message/body" />
      </body>
    </html>
	</xsl:template>

</xsl:stylesheet>
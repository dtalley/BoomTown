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
  <xsl:variable name="self" select="response/request/self" />
  <xsl:variable name="urlencoded_self" select="response/request/urlencoded_self" />
  <xsl:variable name="page" select="response/request/page" />
  <xsl:variable name="template" select="response/request/template/page" />
  <xsl:variable name="directory" select="response/request/template/directory" />

  <xsl:variable name="resources_dir" select="/response/settings/static_url_1" />
  <xsl:variable name="resources_dir_a" select="/response/settings/static_url_2" />
  <xsl:variable name="resources_dir_b" select="/response/settings/static_url_3" />

  <xsl:output method="xml"
              doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
              doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
              omit-xml-declaration="yes" />

  <xsl:template match="/response">
    
  </xsl:template>

</xsl:stylesheet>
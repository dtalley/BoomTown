<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="html"
              doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
              doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
              omit-xml-declaration="yes" />

<xsl:template match="//link">
  <xsl:variable name="feature_id" select="current()" />
  <xsl:variable name="feature_title" select="/design_document/featureset/feature[id=$feature_id]/title" />
  <xsl:choose>
    <xsl:when test="string-length( $feature_title ) > 0">
      <a href="#feature_{$feature_id}"><xsl:value-of select="$feature_title" /></a>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$feature_id" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="//plink">
  <xsl:variable name="feature_id" select="current()" />
  <xsl:variable name="feature_title" select="/design_document/featureset/feature[id=$feature_id]/plural" />
  <xsl:choose>
    <xsl:when test="string-length( $feature_title ) > 0">
      <a href="#feature_{$feature_id}"><xsl:value-of select="$feature_title" /></a>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$feature_id" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="//tlink">
  <xsl:variable name="term_id" select="current()" />
  <xsl:variable name="term_title" select="/design_document/term[id=$feature_id]/title" />
  <xsl:choose>
    <xsl:when test="string-length( $term_title ) > 0">
      <xsl:value-of select="$term_title" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$term_id" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="//t">
  <xsl:variable name="feature_title" select="ancestor::feature/title" />
  <xsl:value-of select="$feature_title" />
</xsl:template>

<xsl:template match="//p">
  <xsl:variable name="feature_title" select="ancestor::feature/plural" />
  <xsl:value-of select="$feature_title" />
</xsl:template>

<xsl:template match="/design_document">
	<html>
		<head>
        	<title>
            	<xsl:value-of select="information/title" /> Design Document
            </title>
            <style type="text/css">
				body {
					background-color: #FFFFFF;
					text-align: center;
					margin: 0;
					padding: 0;
					color: #000000;
					font-size: 11px;
					font-family: Verdana, Geneva, sans-serif;
				}
				#content {
					width: 1000px;
					margin: 0 auto;
					padding: 0px 10px;
					text-align: left;
					border-left: 2px solid #DDDDDD;
					border-right: 2px solid #DDDDDD;
				}
				#title {
					font-size: 24px;
					font-weight: bold;
				}
        .featureset {
          border: 1px solid #000000;
          border-bottom: 5px solid #000000;
          padding: 5px;
        }
        .featureset .featureset_title {
          font-size: 26px;
          color: #FFFFFF;
          background-color: #000000;
          padding: 8px;
        }
				.feature {
					border: 1px solid #0099ff;
					border-bottom: 5px solid #0099ff;
					padding: 5px;
				}
				.feature .feature_title {
					font-size: 18px;
					color: #FFFFFF;
					background-color: #0099ff;
					padding: 3px;
				}
				.contact {
					border: 1px solid #000000;	
					padding: 3px;
				}
				.contact_title {
					background-color: #000000;
					color: #FFFFFF;
					padding: 3px;
					margin-bottom: 5px;
				}
				.goals {
					border: 1px solid #000000;
					padding: 3px;
				}
				.goals_title {
					background-color: #000000;
					color: #FFFFFF;
					padding: 3px;
					margin-bottom: 5px;
				}
        .background {
					border: 1px solid #000000;
					padding: 3px;
				}
				.background_title {
					background-color: #000000;
					color: #FFFFFF;
					padding: 3px;
					margin-bottom: 5px;
				}
				.implementation {
					border: 1px solid #000000;
					padding: 3px;
				}
				.implementation_title {
					background-color: #000000;
					color: #FFFFFF;
					padding: 3px;
					margin-bottom: 5px;
				}
				.impact {
					border: 1px solid #000000;	
					padding: 3px;
				}
				.impact_title {
					background-color: #000000;
					color: #FFFFFF;
					padding: 3px;
					margin-bottom: 5px;
				}
			</style>
        	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        </head>
	</html>
	<body>
		<div id="content">
        	<div id="title">
            	<xsl:variable name="graphic_header" select="information/graphic" />
                <img src="{$graphic_header}" />
            </div>

            <div style="text-align: center; font-weight: bold; font-style: italic;">Version: <xsl:value-of select="information/modified" /></div><br />
            <div id="description">
              <xsl:for-each select="information/description">
                <xsl:apply-templates />
              </xsl:for-each>
            </div>
            <br />
            This is a feature oriented design document.  Each feature is organized by a feature set, and listed broadest to most specific.<br /><br />
            <strong>Changes since the last version:</strong>
            <ul>
              <xsl:for-each select="information/changes/change">
                <xsl:choose>
                  <xsl:when test="@type = 'subtraction'">
                    <li style="color: #FF0000;">- <xsl:value-of select="current()" /></li>
                  </xsl:when>
                  <xsl:when test="@type = 'addition'">
                    <li style="color: #008800;">+ <xsl:value-of select="current()" /></li>
                  </xsl:when>
                  <xsl:otherwise>
                    <li><xsl:value-of select="current()" /></li>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:for-each>
            </ul>

            <strong>Table of Contents:</strong><br /><br />
            <xsl:for-each select="featureset">
              <strong><a href="#featureset_{id}"><xsl:value-of select="title" /></a></strong>
              <ul>
                <xsl:for-each select="feature">
                  <li><a href="#feature_{id}"><xsl:value-of select="title" /></a></li>
                </xsl:for-each>
              </ul>
            </xsl:for-each>
            <xsl:for-each select="featureset">
              <div class="featureset">
                <div class="featureset_title">
                  <strong><xsl:value-of select="title" /></strong>
                  <a name="featureset_{id}" />
                </div><br />
                <xsl:for-each select="feature">
                  <div class="feature">
                    <xsl:choose>
                      <xsl:when test="planned = '1'">
                        <div class="feature_title">
                            Planned Feature: <strong><xsl:value-of select="title" /></strong>
                            <xsl:variable name="feature_id" select="id" />
                            <a name="feature_{$feature_id}" />
                        </div>
                      </xsl:when>
                      <xsl:otherwise>
                        <div class="feature_title">
                            Feature: <strong><xsl:value-of select="title" /></strong>
                            <xsl:variable name="feature_id" select="id" />
                            <a name="feature_{$feature_id}" />
                        </div>
                        <br />
                        <div class="contact">
                            <div class="contact_title">Contact</div>
                            <div class="contact_info">
                              <span style="font-style: italic; color: #888888;">Contact information for the individual that maintains this section.</span><br /><br />
                              <xsl:variable name="author_email" select="contact/email" />
                              Author: <a href="mailto:{$author_email}"><xsl:value-of select="contact/author" /></a>
                            </div>
                        </div>
                        <br />
                        <div class="goals">
                          <div class="goals_title">Goals</div>
                          <span style="font-style: italic; color: #888888;">Clear, concise goals that this feature is meant to achieve.</span><br />
                            <div class="goals_list">
                              <ul>
                                <xsl:for-each select="goals/goal">
                                    <li><xsl:apply-templates /></li>
                                  </xsl:for-each>
                                </ul>
                            </div>
                        </div>
                        <br />
                        <xsl:if test="string-length( background ) > 0">
                          <div class="background">
                              <div class="background_title">Background</div>
                              <span style="font-style: italic; color: #888888;">Fictional or functional background information on this feature.</span><br /><br />
                              <xsl:for-each select="background">
                                <xsl:apply-templates />
                              </xsl:for-each>
                          </div>
                          <br />
                        </xsl:if>
                        <xsl:if test="string-length( implementation ) > 0">
                          <div class="implementation">
                              <div class="implementation_title">Implementation</div>
                              <span style="font-style: italic; color: #888888;">How this feature should work from the player's perspective.</span><br /><br />
                              <xsl:for-each select="implementation">
                                <xsl:apply-templates />
                              </xsl:for-each>
                          </div>
                          <br />
                        </xsl:if>
                        <xsl:if test="string-length( impact ) > 0">
                          <div class="impact">
                              <div class="impact_title">Impact</div>
                              <span style="font-style: italic; color: #888888;">How this feature impacts the player's experience or the overall gameplay.</span><br /><br />
                              <xsl:for-each select="impact">
                                <xsl:apply-templates />
                              </xsl:for-each>
                          </div>
                        </xsl:if>
                      </xsl:otherwise>
                    </xsl:choose>
                    </div><br />
                  </xsl:for-each>
                </div>
                <br />
            </xsl:for-each>
        </div>
    </body>
</xsl:template>

<xsl:template match="strong">
  <strong><xsl:apply-templates /></strong>
</xsl:template>

<xsl:template match="em">
  <em><xsl:apply-templates /></em>
</xsl:template>

<xsl:template match="ul">
  <ul><xsl:apply-templates /></ul>
</xsl:template>

<xsl:template match="li">
  <li><xsl:apply-templates /></li>
</xsl:template>

<xsl:template match="br">
  <br />
</xsl:template>

<xsl:template match="span">
  <span>
    <xsl:if test="string-length( @style ) > 0">
      <xsl:attribute name="style"><xsl:value-of select="@style" /></xsl:attribute>
    </xsl:if>
    <xsl:apply-templates />
  </span>
</xsl:template>

</xsl:stylesheet>
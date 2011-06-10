<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:php="http://www.php.net/">

  <xsl:output method="html"
              omit-xml-declaration="yes" />

  <xsl:template match="l">
    <xsl:variable name="feature_id" select="current()" />
    <xsl:variable name="feature_title" select="/design_document/featureset/feature[id=$feature_id]/title" />
    <xsl:variable name="term_title" select="/design_document/term[id=$feature_id]/title" />
    <xsl:choose>
      <xsl:when test="string-length( $feature_title ) > 0">
        <a href="#feature_{$feature_id}">
          <xsl:value-of select="$feature_title" />
        </a>
      </xsl:when>
      <xsl:when test="string-length( $term_title ) > 0">
        <xsl:value-of select="$term_title" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$feature_id" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="pl">
    <xsl:variable name="feature_id" select="current()" />
    <xsl:variable name="feature_title" select="/design_document/featureset/feature[id=$feature_id]/plural" />
    <xsl:variable name="term_title" select="/design_document/term[id=$feature_id]/plural" />
    <xsl:choose>
      <xsl:when test="string-length( $feature_title ) > 0">
        <a href="#feature_{$feature_id}">
          <xsl:value-of select="$feature_title" />
        </a>
      </xsl:when>
      <xsl:when test="string-length( $term_title ) > 0">
        <xsl:value-of select="$term_title" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$feature_id" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="t">
    <xsl:variable name="feature_title" select="ancestor::feature/title" />
    <xsl:value-of select="$feature_title" />
  </xsl:template>

  <xsl:template match="p">
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
        textarea {
          border: 0;
          padding: 0;
        }
        a:link, a:visited {
          color: #0066AA;
          text-decoration: none;
        }
        a:hover, a:active {
          color: #FF0000;
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
					padding: 6px;
				}
				.contact {
					border: 1px solid #000000;	
					padding: 3px;
				}
				.contact_title {
					background-color: #000000;
					color: #FFFFFF;
					padding: 6px;
				}
				.goals {
					border: 1px solid #000000;
					padding: 3px;
				}
				.goals_title {
					background-color: #000000;
					color: #FFFFFF;
					padding: 6px;
				}
        .background {
					border: 1px solid #000000;
					padding: 3px;
				}
				.background_title {
					background-color: #000000;
					color: #FFFFFF;
					padding: 6px;
				}
        .background_description {
          padding-top: 5px;
        }
				.implementation {
					border: 1px solid #000000;
					padding: 3px;
				}
				.implementation_title {
					background-color: #000000;
					color: #FFFFFF;
					padding: 6px;
				}
        .implementation_description {
          padding-top: 5px;
        }
				.impact {
					border: 1px solid #000000;	
					padding: 3px;
				}
				.impact_title {
					background-color: #000000;
					color: #FFFFFF;
					padding: 6px;
				}
        .impact_description {
          padding-top: 5px;
        }
        .goals_list li {
          padding-top: 5px;
          padding-bottom: 5px;
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

        <div style="text-align: center; font-weight: bold; font-style: italic;">Version:
          <xsl:value-of select="information/modified" />
        </div>
        <br />
        <div id="description">
          <xsl:for-each select="information/description">
            <xsl:apply-templates />
          </xsl:for-each>
        </div>
        <br />
            This is a feature oriented design document.  Each feature is organized by a feature set, and listed broadest to most specific.
        <br />
        <br />
        <strong>Changes since the last version:</strong>
        <ul>
          <xsl:for-each select="information/changes/change">
            <xsl:choose>
              <xsl:when test="@type = 'subtraction'">
                <li style="color: #FF0000;">-
                  <xsl:apply-templates />
                </li>
              </xsl:when>
              <xsl:when test="@type = 'addition'">
                <li style="color: #008800;">+
                  <xsl:apply-templates />
                </li>
              </xsl:when>
              <xsl:otherwise>
                <li>
                  <xsl:apply-templates />
                </li>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
        </ul><br />

        <strong><a name="toc">Table of Contents:</a></strong>
        <br />
        <br />
        <xsl:for-each select="featureset">
          <strong>
            <a href="#featureset_{id}">
              <xsl:value-of select="title" />
            </a>
          </strong>
          <ul>
            <xsl:for-each select="feature">
              <li>
                <a href="#feature_{id}">
                  <xsl:value-of select="title" />
                </a>
              </li>
            </xsl:for-each>
          </ul>
        </xsl:for-each><br />
        <xsl:for-each select="featureset">
          <div id="{id}" class="featureset">
            <div class="featureset_title">
              <strong>
                <xsl:value-of select="title" />
              </strong>
              <a name="featureset_{id}" />
            </div>
            <br />
            <xsl:for-each select="feature">
              <div id="{id}">
                <xsl:attribute name="class">
                  <xsl:text>feature</xsl:text>
                </xsl:attribute>
                <div class="feature_title">
                  Feature:
                  <span style="font-weight: bold;" class="feature_title_text">
                    <xsl:value-of select="title" />
                  </span>
                  <a name="feature_{id}" />
                </div>
                <br />
                <div class="contact">
                  <div class="contact_title">Contact</div>
                  <div class="contact_description">
                    <span style="font-style: italic; color: #888888;">Contact information for the individual that maintains this section.</span>
                    <br /><br />
                  </div>
                  <div class="contact_info">
                    Author:
                    <a href="mailto:{contact/email}" class="contact_link">
                      <xsl:value-of select="contact/author" />
                    </a>
                  </div>
                </div>
                <br />
                <div class="goals">
                  <div class="goals_title">Goals</div>
                  <div class="goals_description">
                    <span style="font-style: italic; color: #888888;">Clear, concise goals that this feature is meant to achieve.</span>
                    <br />
                  </div>
                  <div class="goals_list">
                    <ul>
                      <xsl:for-each select="goals/goal">
                        <li>
                          <xsl:apply-templates />
                        </li>
                      </xsl:for-each>
                    </ul>
                  </div>
                </div>
                <br />
                <xsl:if test="string-length( background ) > 0">
                  <div class="background">
                    <div class="background_title">Background</div>
                    <div class="background_description">
                      <xsl:attribute name="style">
                        <xsl:if test="string-length( background ) = 0">display: none;</xsl:if>
                      </xsl:attribute>
                      <span style="font-style: italic; color: #888888;">Fictional or functional background information on this feature.</span>
                      <br />
                      <br />
                    </div>
                    <div class="background_text">
                      <xsl:apply-templates select="background" />
                    </div>
                  </div>
                  <br />
                </xsl:if>
                <xsl:if test="string-length( implementation ) > 0">
                  <div class="implementation">
                    <div class="implementation_title">Implementation</div>
                    <div class="implementation_description">
                      <xsl:attribute name="style">
                        <xsl:if test="string-length( implementation ) = 0">display: none;</xsl:if>
                      </xsl:attribute>
                      <span style="font-style: italic; color: #888888;">How this feature should work from the player's perspective.</span>
                      <br />
                      <br />
                    </div>
                    <div class="implementation_text">
                      <xsl:apply-templates select="implementation" />
                    </div>
                  </div>
                  <br />
                </xsl:if>
                <xsl:if test="string-length( impact ) > 0">
                  <div class="impact">
                    <div class="impact_title">Impact</div>
                    <div class="impact_description">
                      <xsl:attribute name="style">
                        <xsl:if test="string-length( impact ) = 0">display: none;</xsl:if>
                      </xsl:attribute>
                      <span style="font-style: italic; color: #888888;">How this feature impacts the player's experience or the overall gameplay.</span>
                      <br />
                      <br />
                    </div>
                    <div class="impact_text">
                      <xsl:apply-templates select="impact" />
                    </div>
                  </div>
                </xsl:if>
              </div><br />
              <div style="text-align: right; padding-right: 10px;">
                <a href="#toc">Table of Contents</a>
              </div><br />
            </xsl:for-each>
          </div>
          <br />
        </xsl:for-each>
      </div>
    </body>
  </xsl:template>

  <xsl:template match="strong">
    <strong>
      <xsl:apply-templates />
    </strong>
  </xsl:template>

  <xsl:template match="em">
    <em>
      <xsl:apply-templates />
    </em>
  </xsl:template>

  <xsl:template match="ul">
    <ul>
      <xsl:apply-templates />
    </ul>
  </xsl:template>

  <xsl:template match="li">
    <li>
      <xsl:apply-templates />
    </li>
  </xsl:template>

  <xsl:template match="br">
    <br />
  </xsl:template>

  <xsl:template match="span">
    <span>
      <xsl:if test="string-length( @style ) > 0">
        <xsl:attribute name="style">
          <xsl:value-of select="@style" />
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates />
    </span>
  </xsl:template>

</xsl:stylesheet>
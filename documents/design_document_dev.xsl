<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:php="http://www.php.net/">

  <xsl:output method="xml"
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
          margin: 0;
          padding: 0;
          resize: none;
          font-size: 11px;
					font-family: Verdana, Geneva, sans-serif;
        }
        ul {
          padding-top: 10px;
          padding-bottom: 10px;
        }
        .ico_link {
          display: block;
          width: 14px;
          height: 14px;
          text-indent: -1000px;
          overflow: hidden;
        }
        a.ico_link:hover, a.ico_link:active {
          background-position: 0px -14px;
        }
        .ico_text_link {
          display: inline-block;
          height: 14px;
          padding-left: 19px;
        }
        a.ico_text_link:hover, a.ico_text_link:active {
          background-position: 0px -14px;
        }
        .edit_link {          
          background: transparent url( './edit_ico.gif' ) top left no-repeat;
        }
        .add_link {
          background: transparent url( './add_ico.gif' ) top left no-repeat;
        }
        .up_link {
          background: transparent url( './up_ico.gif' ) top left no-repeat;
        }
        .delete_link {
          background: transparent url( './delete_ico.gif' ) top left no-repeat;
        }
        .check_link {
          background: transparent url( './check_ico.gif' ) top left no-repeat;
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
        .impact_edit {
          width: 100%;
        }
        .goals_list li {
          padding-top: 5px;
          padding-bottom: 5px;
          line-height: 14px;
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
          </ul><br />
        </xsl:for-each>
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
                  <xsl:if test="planned = '1'"> planned</xsl:if>
                </xsl:attribute>
                <input type="hidden" id="feature_title" value="{title}" />
                <input type="hidden" id="feature_plural" value="{plural}" />
                <div class="feature_title">
                  <xsl:if test="planned = '1'">Planned </xsl:if>Feature:
                  <span style="font-weight: bold;" class="feature_title_text">
                    <xsl:value-of select="title" />
                  </span>
                  <a name="feature_{id}" />
                </div>
                <br />
                <div class="contact">
                  <div class="contact_title"><a href="#" class="edit_contact ico_link edit_link" title="Edit Contact" style="float: right;">.</a> Contact</div>
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
                    <span style="font-style: italic; color: #888888;">What problems should this feature solve? What objectives should this feature achieve?</span>
                    <br />
                  </div>
                  <div class="goals_list">
                    <ul>
                      <xsl:for-each select="goals/goal">
                        <li>
                          <span class="view_goal_section">
                            <a href="#" class="edit_goal ico_link edit_link" title="Edit Goal" style="float: left; margin-right: 5px;">.</a>
                            <a href="#" class="delete_goal ico_link delete_link" title="Delete Goal" style="float: left; margin-right: 5px;">.</a>
                            <span class="edit_goal_text"><xsl:apply-templates /></span>
                          </span>
                          <span class="edit_goal_section" style="display: none;">
                            <a href="#" class="save_goal ico_link check_link" title="Save Goal" style="float: left; margin-right: 5px;">.</a>
                            <div style="padding-left: 19px;">
                              <textarea style="width: 100%; height: 14px;" class="edit_goal_edit"><xsl:copy-of select="node()" /></textarea>
                            </div>
                          </span>
                        </li>
                      </xsl:for-each>
                      <li><a href="#" class="add_goal ico_text_link add_link">Add Goal</a></li>
                    </ul>
                  </div>
                </div>
                <br />
                <div class="background">
                  <div class="background_title"><a href="#" class="edit_background ico_link edit_link" title="Edit Background" style="float: right;">.</a> Background</div>
                  <div class="background_description">
                    <xsl:attribute name="style">
                      <xsl:if test="string-length( background ) = 0">display: none;</xsl:if>
                    </xsl:attribute>
                    <span style="font-style: italic; color: #888888;">What is the fictional origin of this feature?</span>
                    <br />
                    <br />
                  </div>
                  <textarea class="background_edit" style="display: none;">
                    <xsl:choose>
                      <xsl:when test="string-length( background ) > 0">
                        <xsl:copy-of select="background/node()" />
                      </xsl:when>
                      <xsl:otherwise>
                        Edit here!
                      </xsl:otherwise>
                    </xsl:choose>
                  </textarea>
                  <xsl:if test="string-length( background ) > 0">
                    <div class="background_text">
                      <xsl:apply-templates select="background" />
                    </div>
                  </xsl:if>
                </div>
                <br />
                <div class="implementation">
                  <div class="implementation_title"><a href="#" class="edit_implementation ico_link edit_link" title="Edit Implementation" style="float: right;">.</a> Implementation</div>
                  <div class="implementation_description">
                    <xsl:attribute name="style">
                      <xsl:if test="string-length( implementation ) = 0">display: none;</xsl:if>
                    </xsl:attribute>
                    <span style="font-style: italic; color: #888888;">How does the player experience this feature?  What are the different aspects of it when the player actually encounters or interacts with this feature in the game?</span>
                    <br />
                    <br />
                  </div>
                  <textarea class="implementation_edit" style="display: none;">
                    <xsl:choose>
                      <xsl:when test="string-length( implementation ) > 0">
                        <xsl:copy-of select="implementation/node()" />
                      </xsl:when>
                      <xsl:otherwise>
                        Edit here!
                      </xsl:otherwise>
                    </xsl:choose>
                  </textarea>
                  <xsl:if test="string-length( implementation ) > 0">
                    <div class="implementation_text">
                      <xsl:apply-templates select="implementation" />
                    </div>
                  </xsl:if>
                </div>
                <br />
                <div class="impact">
                  <div class="impact_title"><a href="#" class="edit_impact ico_link edit_link" title="Edit Impact" style="float: right;">.</a> Impact</div>
                  <div class="impact_description">
                    <xsl:attribute name="style">
                      <xsl:if test="string-length( impact ) = 0">display: none;</xsl:if>
                    </xsl:attribute>
                    <span style="font-style: italic; color: #888888;">Why does this feature matter?  How important is it in the scope of the game as a whole?  How does it affect the player's gameplay experience?</span>
                    <br />
                    <br />
                  </div>
                  <textarea class="impact_edit" style="display: none;">
                    <xsl:choose>
                      <xsl:when test="string-length( impact ) > 0">
                        <xsl:copy-of select="impact/node()" />
                      </xsl:when>
                      <xsl:otherwise>
                        Edit here!
                      </xsl:otherwise>
                    </xsl:choose>
                  </textarea>
                  <xsl:if test="string-length( impact ) > 0">
                    <div class="impact_text">
                      <xsl:apply-templates select="impact" />
                    </div>
                  </xsl:if>
                </div>
              </div><br />
              <div style="text-align: right; padding-right: 10px;">
                <a href="#toc" class="ico_text_link up_link">Table of Contents</a>
              </div><br />
            </xsl:for-each>
          </div>
          <br />
        </xsl:for-each>
      </div>

      <script type="text/javascript" src="jquery.js">
        /* A script */
      </script>
      <script type="text/javascript" src="scripts.js">
        /* A script */
      </script>
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
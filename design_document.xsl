<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="html"
              doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
              doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
              omit-xml-declaration="yes" />

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
					width: 800px;
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
				.tasks {
					border: 1px solid #000000;	
					padding: 3px;
				}
				.tasks_title {
					background-color: #000000;
					color: #FFFFFF;
					padding: 3px;
					margin-bottom: 5px;
				}
				.tasks_design_title {
					padding: 3px;
					border-bottom: 1px solid #DDDDDD;
				}
				.tasks_code_title {
					padding: 3px;
					border-bottom: 1px solid #DDDDDD;
				}
				.tasks_art_title {
					padding: 3px;
					border-bottom: 1px solid #DDDDDD;
				}
				.tasks_animation_title {
					padding: 3px;
					border-bottom: 1px solid #DDDDDD;
				}
				.tasks_sound_title {
					padding: 3px;
					border-bottom: 1px solid #DDDDDD;
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
            <div id="description">
            	<xsl:copy-of select="information/description" />
            </div>
            <br />
            This is a feature oriented design document.  Each feature is listed individually, simplest to most complex.<br /><br />
            <xsl:for-each select="feature">
            	<div class="feature">
                    <div class="feature_title">
                        Feature: <strong><xsl:value-of select="title" /></strong>
                        <xsl:variable name="feature_id" select="id" />
                        <a name="feature_{$feature_id}" />
                    </div>
                    <br />
                    <div class="contact">
                        <div class="contact_title">Contact</div>
                        <div class="contact_info">
                        	<xsl:variable name="author_email" select="contact/email" />
                        	Author: <a href="mailto:{$author_email}"><xsl:value-of select="contact/author" /></a>
                        </div>
                        <br />
                        <div class="contact_list">
                        	Related Sections:<br />
                            <ul>
                                <xsl:for-each select="contact/related_sections/section">
                                    <xsl:variable name="related_section_id" select="id" />
                                    <li><a href="#feature_{$related_section_id}"><xsl:value-of select="title" /></a></li>
                                </xsl:for-each>
                            </ul>
                        </div>
                    </div>
                    <br />
                    <div class="goals">
                    	<div class="goals_title">Goals</div>
                        <div class="goals_list">
                        	<ul>
                        		<xsl:for-each select="goals/goal">
                            		<li><xsl:copy-of select="description" /></li>
                            	</xsl:for-each>
                            </ul>
                        </div>
                    </div>
                    <br />
                    <div class="implementation">
                        <div class="implementation_title">Implementation</div>
                        <xsl:copy-of select="implementation" />
                    </div>
                    <br />
                    <div class="impact">
                        <div class="impact_title">Impact</div>
                        <xsl:copy-of select="impact" />
                    </div>
                    <br />
                    <div class="tasks">
                    	<div class="tasks_title">
                        	Tasks
                        </div>
                        <div class="tasks_design_title">
                            Tasks for Design
                        </div>
                        <div class="tasks_design">
                            <ul>
                                <xsl:for-each select="tasks/design/task">
                                    <li>
                                    	<xsl:variable name="task_priority">
                                            <xsl:choose>
												<xsl:when test="completed=1">
													#AAAAAA
												</xsl:when>
                                                <xsl:when test="priority=0">
                                                    #FF0000
                                                </xsl:when>
                                                <xsl:when test="priority=1">
                                                    #FF9900
                                                </xsl:when>
                                                <xsl:when test="priority=2">
                                                    #FFFF00
                                                </xsl:when>
                                                <xsl:when test="priority=9">
                                                    #99FF00
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    #00FF00
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:variable>
                                        <div style="border-left: 10px solid {$task_priority};border-bottom:1px solid {$task_priority};margin-bottom:2px;padding:4px;display:block;">
											<span>
												<xsl:if test="completed = 1">
													<xsl:attribute name="style">color: #AAAAAA;</xsl:attribute>
													<strong>Completed: </strong> 
												</xsl:if>
												<xsl:copy-of select="description" />
											</span>
										</div>
                                    </li>
                                </xsl:for-each>
                            </ul>
                        </div>
                        <div class="tasks_code_title">
                            Tasks for Code
                        </div>
                        <div class="tasks_code">
                            <ul>
                                <xsl:for-each select="tasks/code/task">
                                	<li>
                                    	<xsl:variable name="task_priority">
                                            <xsl:choose>
												<xsl:when test="completed=1">
													#AAAAAA
												</xsl:when>
                                                <xsl:when test="priority=0">
                                                    #FF0000
                                                </xsl:when>
                                                <xsl:when test="priority=1">
                                                    #FF9900
                                                </xsl:when>
                                                <xsl:when test="priority=2">
                                                    #FFFF00
                                                </xsl:when>
                                                <xsl:when test="priority=9">
                                                    #99FF00
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    #00FF00
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:variable>
                                        <div style="border-left: 10px solid {$task_priority};border-bottom:1px solid {$task_priority};margin-bottom:2px;padding:4px;display:block;">
											<span>
												<xsl:if test="completed = 1">
													<xsl:attribute name="style">color: #AAAAAA;</xsl:attribute>
													<strong>Completed: </strong> 
												</xsl:if>
												<xsl:copy-of select="description" />
											</span>
										</div>
                                    </li>
                                </xsl:for-each>
                            </ul>
                        </div>
                        <div class="tasks_art_title">
                            Tasks for Art
                        </div>
                        <div class="tasks_art">
                            <ul>
                                <xsl:for-each select="tasks/art/task">
                                    <li>
                                    	<xsl:variable name="task_priority">
                                            <xsl:choose>
												<xsl:when test="completed=1">
													#AAAAAA
												</xsl:when>
                                                <xsl:when test="priority=0">
                                                    #FF0000
                                                </xsl:when>
                                                <xsl:when test="priority=1">
                                                    #FF9900
                                                </xsl:when>
                                                <xsl:when test="priority=2">
                                                    #FFFF00
                                                </xsl:when>
                                                <xsl:when test="priority=9">
                                                    #99FF00
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    #00FF00
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:variable>
                                        <div style="border-left: 10px solid {$task_priority};border-bottom:1px solid {$task_priority};margin-bottom:2px;padding:4px;display:block;">
											<span>
												<xsl:if test="completed = 1">
													<xsl:attribute name="style">color: #AAAAAA;</xsl:attribute>
													<strong>Completed: </strong> 
												</xsl:if>
												<xsl:copy-of select="description" />
											</span>
										</div>
                                    </li>
                                </xsl:for-each>
                            </ul>
                        </div>
                        <div class="tasks_animation_title">
                            Tasks for Animation
                        </div>
                        <div class="tasks_animation">
                            <ul>
                                <xsl:for-each select="tasks/animation/task">
                                    <li>
                                    	<xsl:variable name="task_priority">
                                            <xsl:choose>
												<xsl:when test="completed=1">
													#AAAAAA
												</xsl:when>
                                                <xsl:when test="priority=0">
                                                    #FF0000
                                                </xsl:when>
                                                <xsl:when test="priority=1">
                                                    #FF9900
                                                </xsl:when>
                                                <xsl:when test="priority=2">
                                                    #FFFF00
                                                </xsl:when>
                                                <xsl:when test="priority=9">
                                                    #99FF00
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    #00FF00
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:variable>
                                        <div style="border-left: 10px solid {$task_priority};border-bottom:1px solid {$task_priority};margin-bottom:2px;padding:4px;display:block;">
											<span>
												<xsl:if test="completed = 1">
													<xsl:attribute name="style">color: #AAAAAA;</xsl:attribute>
													<strong>Completed: </strong> 
												</xsl:if>
												<xsl:copy-of select="description" />
											</span>
										</div>
                                    </li>
                                </xsl:for-each>
                            </ul>
                        </div>
                        <div class="tasks_sound_title">
                            Tasks for Sound
                        </div>
                        <div class="tasks_sound">
                            <ul>
                                <xsl:for-each select="tasks/sound/task">
                                    <li>
                                    	<xsl:variable name="task_priority">
                                            <xsl:choose>
												<xsl:when test="completed=1">
													#AAAAAA
												</xsl:when>
                                                <xsl:when test="priority=0">
                                                    #FF0000
                                                </xsl:when>
                                                <xsl:when test="priority=1">
                                                    #FF9900
                                                </xsl:when>
                                                <xsl:when test="priority=2">
                                                    #FFFF00
                                                </xsl:when>
                                                <xsl:when test="priority=9">
                                                    #99FF00
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    #00FF00
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:variable>
                                        <div style="border-left: 10px solid {$task_priority};border-bottom:1px solid {$task_priority};margin-bottom:2px;padding:4px;display:block;">
											<span>
												<xsl:if test="completed = 1">
													<xsl:attribute name="style">color: #AAAAAA;</xsl:attribute>
													<strong>Completed: </strong> 
												</xsl:if>
												<xsl:copy-of select="description" />
											</span>
										</div>
                                    </li> 
                                </xsl:for-each>
                            </ul>
                        </div>
                    </div>
                </div>
                <br />
            </xsl:for-each>
        </div>
    </body>
</xsl:template>

</xsl:stylesheet>
<?xml version="1.0"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	  <xsl:output method="text"/>
	  <xsl:template match="/lift">
			<xsl:apply-templates select="entry"/>
	  </xsl:template>
	  <xsl:template match="entry">
			<xsl:param name="headword" select="lexical-unit/form/text"/>
			<xsl:apply-templates select="sense">
				  <xsl:with-param name="headword" select="$headword"/>
			</xsl:apply-templates>
			<!--
			 <xsl:for-each select="sense">
				  <xsl:call-template name="senseentry">
					<xsl:with-param name="headword" select="$headword"/>
				  </xsl:call-template>
			</xsl:for-each>
			-->
	  </xsl:template>
	  <xsl:template match="lexical-unit/form/text">
			<xsl:apply-templates/>
	  </xsl:template>
	  <xsl:template match="sense/definition/form/text[@lang = 'en']">
			<xsl:apply-templates/>
	  </xsl:template>
	  <xsl:template name="senseentry">
			<xsl:param name="headword">

			</xsl:param>
			<xsl:variable name="l1" select="sense[1]/definition/form[@lang = 'en']/text"/>
			<xsl:variable name="l2" select="sense[1]/definition/form[@lang = 'tl']/text"/>
			<xsl:choose>
				  <xsl:when test="string-length($l1) + string-length($l2) = 0"/>
				  <xsl:otherwise>
						<xsl:apply-templates select="$headword"/>
						<xsl:text>&#9;</xsl:text>
						<xsl:apply-templates select="$l1"/>
						<xsl:text> &#9;</xsl:text>
						<xsl:apply-templates select="$l2"/>
						<xsl:text> </xsl:text>
						<xsl:text>&#10;</xsl:text>
				  </xsl:otherwise>
			</xsl:choose>
	  </xsl:template>
	  <xsl:template match="sense">
			<xsl:param name="headword"/>
			<xsl:variable name="l1" select="definition/form[@lang = 'en']/text"/>
			<xsl:variable name="l2" select="definition/form[@lang = 'tl']/text"/>
			<xsl:choose>
				  <xsl:when test="string-length($l1) + string-length($l2) = 0"/>
				  <xsl:otherwise>
						<xsl:apply-templates select="$headword"/>
						<xsl:text>&#9;</xsl:text>
						<xsl:apply-templates select="$l1"/>
						<xsl:text> &#9;</xsl:text>
						<xsl:apply-templates select="$l2"/>
						<xsl:text> </xsl:text>
						<xsl:text>&#10;</xsl:text>
				  </xsl:otherwise>
			</xsl:choose>
	  </xsl:template>
</xsl:stylesheet>

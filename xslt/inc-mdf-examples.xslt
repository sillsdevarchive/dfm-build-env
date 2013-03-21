<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	  <xsl:template match="xv">
			<xsl:text>\n[03</xsl:text>
			<xsl:if test="$size = 'full'">}}</xsl:if>
			<xsl:apply-templates/>
			<xsl:if test="$size = 'full'">{{</xsl:if>
			<xsl:text>] </xsl:text>
	  </xsl:template>
	  <xsl:template match="xe">
			<xsl:text>\n[04</xsl:text>
			<xsl:if test="$size = 'full'">}}</xsl:if>
			<xsl:apply-templates/>
			<xsl:if test="$size = 'full'">{{</xsl:if>
			<xsl:text>] </xsl:text>
	  </xsl:template>
	  <xsl:template match="xn">
			<xsl:text>\n[03[08</xsl:text>
			<xsl:if test="$size = 'full'">}}</xsl:if>
			<xsl:apply-templates/>
			<xsl:if test="$size = 'full'">{{</xsl:if>
			<xsl:text>]] </xsl:text>
	  </xsl:template>
	  <xsl:template match="xr">
			<xsl:text>\n[04</xsl:text>
			<xsl:if test="$size = 'full'">}}</xsl:if>
			<xsl:apply-templates/>
			<xsl:if test="$size = 'full'">{{</xsl:if>
			<xsl:text>] </xsl:text>
	  </xsl:template>
</xsl:stylesheet>

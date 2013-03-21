<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	   <xsl:template match="ex|xv">
			<xsl:text>\n[03 }}</xsl:text>
			<xsl:apply-templates/>
			<!-- remove trouble causing [ and ] brackets -->
			<xsl:text>{{] </xsl:text>
	  </xsl:template>
	  <xsl:template match="tr|xe">
			<xsl:text>\n[04 </xsl:text>
			<xsl:apply-templates/>
			<!-- remove trouble causing [ and ] brackets -->
			<xsl:text>] </xsl:text>
	  </xsl:template>
</xsl:stylesheet>

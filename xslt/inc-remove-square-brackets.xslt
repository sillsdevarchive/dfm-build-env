<?xml version="1.0" encoding="utf-8" standalone="no"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:silp="http://silp.org.ph/ns/">
	  <xsl:function name="silp:remove-sq-brackets">
			<xsl:param name="input"/>
			<xsl:sequence select="translate(replace(replace($input,'\\\[','\\['),'\\\]','\\]'),'&#9;&#10;','  ')"/>
	  </xsl:function>
	 <xsl:template match="text()">
			<!-- Replace [ and ] found in any text with escaped \[  and \] and removes tab characters -->
			<xsl:value-of select="silp:remove-sq-brackets(.)"/>
	  </xsl:template>

</xsl:stylesheet>

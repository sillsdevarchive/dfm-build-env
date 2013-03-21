<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	  <!--
The lists are \s+ separated (win CR LF or any space type) included items must be preceeded by a underscore
The control list source text is in the form:
included_item_1
included_item_2
or
item1 item3 item3 etc
	Modified by Ian McQuay
	Created 2012-06-14
-->
	  <xsl:template name="list2xml">
			<xsl:param name="text"/>
			<xsl:analyze-string select="$text" regex="\s+">
				  <xsl:matching-substring/>
				  <xsl:non-matching-substring>
						<xsl:element name="element">
							  <xsl:value-of select="."/>
						</xsl:element>
				  </xsl:non-matching-substring>
			</xsl:analyze-string>
	  </xsl:template>
</xsl:stylesheet>

<?xml version="1.0"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:html="http://www.w3.org/1999/xhtml">
	  <xsl:output method="text"/>
	  <xsl:include href="inc-remove-square-brackets.xslt"/>
	  <xsl:strip-space elements="*"/>
	  <xsl:template match="/*">
			<!-- root -->
			<xsl:apply-templates/>
	  </xsl:template>
	  <xsl:template match="html:body">
			<!-- body -->
			<xsl:apply-templates select="html:div"/>
	  </xsl:template>
	  <xsl:template match="html:div">
			<!-- root -->
			<xsl:apply-templates mode="entry"/>
	  </xsl:template>
	  <xsl:template match="html:*[contains(@class, 'entry')]" mode="entry">
			<!-- Main template to control layout -->
			<xsl:apply-templates mode="head"/>
			<xsl:text> {{<!-- start hide content from inclusion in indexes --></xsl:text>
			<xsl:apply-templates mode="main"/>
			<xsl:text>}}<!-- end hide content from inclusion in indexes --></xsl:text>
			<xsl:text>&#9;<!-- tab to separate language index--></xsl:text>
			<xsl:apply-templates mode="index"/>
			<xsl:text>&#13;<!-- CR character entity and NL provided by NL-->
</xsl:text>
	  </xsl:template>
	  <xsl:template match="html:*[@class = 'headword']" mode="head">
			<xsl:apply-templates mode="head"/>
	  </xsl:template>
	  <xsl:template match="html:*[@class = 'xhomographnumber']" mode="head">
			<xsl:apply-templates mode="head"/>
	  </xsl:template>
	  <xsl:template match="html:*[@class = 'senses']" mode="main">
			<xsl:apply-templates/>
	  </xsl:template>
	  <xsl:template match="html:*[@class = 'senses']" mode="index">
			<xsl:apply-templates mode="index"/>
	  </xsl:template>
	  <xsl:template match="html:*[@class = 'sense']">
			<xsl:apply-templates/>
	  </xsl:template>
	  <xsl:template match="html:*[@class = 'sense']" mode="index">
			<xsl:apply-templates mode="index"/>
	  </xsl:template>
	  <xsl:template match="html:*[@class = 'examples']">
			<xsl:apply-templates/>
	  </xsl:template>
	  <xsl:template match="html:*[@class = 'xitem']">
			<xsl:apply-templates/>
	  </xsl:template>
	  <xsl:template match="html:*[@class = 'grammatical-info']">
			<xsl:apply-templates/>
	  </xsl:template>
	  <xsl:template match="html:*[@class = 'translations']">
			<xsl:apply-templates/>
	  </xsl:template>
	  <xsl:template match="html:*[@class = 'partofspeech']">
			<xsl:text> [01 </xsl:text>
			<xsl:value-of select="."/>
			<xsl:text>]</xsl:text>
	  </xsl:template>
	  <xsl:template match="html:*[@class = 'definition']">
			<xsl:text> [02 </xsl:text>
			<xsl:value-of select="."/>
			<xsl:text>]</xsl:text>
	  </xsl:template>
	  <xsl:template match="html:*[@class = 'definition']" mode="index">
			<xsl:text></xsl:text>
			<xsl:value-of select="."/>
<xsl:text></xsl:text>
	  </xsl:template>
	  <xsl:template match="html:*[@class = 'example']">
			<xsl:text> [03 </xsl:text>
			<xsl:value-of select="."/>
			<xsl:text>]</xsl:text>
	  </xsl:template>
	  <xsl:template match="html:*[@class = 'translation']">
			<xsl:text> [04 </xsl:text>
			<xsl:value-of select="."/>
			<xsl:text>]</xsl:text>
	  </xsl:template>
	  <xsl:template match="html:*"/>
	  <xsl:template match="html:*" mode="head"/>
	  <xsl:template match="html:*" mode="main"/>
	  <xsl:template match="html:*" mode="index"/>
	  <xsl:template match="html:*[@class = 'letHead']"/>
</xsl:stylesheet>

<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:silp="http://silp.org.ph/ns/" version="2.0">
	  <!-- for making DictionaryForMID input files from xml exported from Toolbox. This one is for PLB codes but can be adapted to MDF codes also. -->
	  <xsl:output method="text" omit-xml-declaration="yes" encoding="UTF-8"/>
	  <xsl:param name="type" select="mdf"/>
	  <xsl:strip-space elements="*"/>
	  <xsl:preserve-space elements="xsl:text"/>
	  <xsl:include href="inc-common.xslt"/>
	  <xsl:include href="inc-mdf-fields.xslt"/>
</xsl:stylesheet>

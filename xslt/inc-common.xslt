<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	  <xsl:param name="langs" select="2"/>
	  <xsl:param name="size"/>
	  <xsl:variable name="nomarkupgrouplist" select="
'CommonGroups
psGroup

PlbGroups
glGroup
msGroup
glGroup
itGroup
iiGroup
ivGroup
exGroup

MDFgroups
seGroup
snGroup
rfGroup
xvGroup
lfGroup
lvGroup
mrGroup
cfGroup
mnGroup
vaGroup
etGroup
pdGroup
pdlGroup
deGroup
'
"/>
	  <!-- the above list should space or newline separated
	It is okay to have redundant groups, but all groups sould be included and any thing else that has valid content -->
	  <xsl:variable name="nomarkupgroup">
			<!-- uses inc-list2xml.xslt to create a node set of group elements   -->
			<xsl:call-template name="list2xml">
				  <xsl:with-param name="text" select="$nomarkupgrouplist"/>
			</xsl:call-template>
	  </xsl:variable>
	  <xsl:include href="inc-remove-square-brackets.xslt"/>
	  <xsl:include href="inc-list2xml.xslt"/>
	  <!-- inc-list2xml.xslt used by the nomarkupgroup variable   -->
	  <xsl:template match="*"/>
	  <!-- dump anything not specifically handled          -->
	  <xsl:template match="/*">
			<!-- matches root element common to PLB or MDF -->
			<xsl:apply-templates/>
	  </xsl:template>
	  <xsl:template match="lxGroup">
			<!-- lxGroup templates  controls all languages groups to be made =================================== -->
			<xsl:apply-templates select="lx" mode="ver"/>
			<xsl:if test="$size != 'wl'">
				  <!--  This selects some fields for inclusion on the vernacular side  pn non wordlist Dictionaries   -->
				  <xsl:text>{{</xsl:text>
				  <xsl:apply-templates select="*"/>
				  <xsl:text>}}</xsl:text>
			</xsl:if>
			<xsl:text>&#x9;<!-- Tab character to separate the languages.  --></xsl:text>
			<!-- This starts the English Index section  -->
			<xsl:choose>
				  <!--   <xsl:when test="not(*[local-name() = $engindex] nor */*[local-name() = $engindex] nor */*/*[local-name() = $engindex]  nor */*/*/*[local-name() = $engindex] )">   -->
				  <xsl:when test="$engindextest">
						<xsl:apply-templates select="*" mode="indexengsub"/>
				  </xsl:when>
				  <xsl:otherwise>
						<xsl:apply-templates select="*" mode="indexeng"/>
				  </xsl:otherwise>
			</xsl:choose>
			<xsl:if test="number($langs) &gt;= 3">
				  <xsl:text>&#x9;</xsl:text>
				  <xsl:apply-templates select="*" mode="indexnat"/>
				  <xsl:text> </xsl:text>
			</xsl:if>
			<xsl:if test="number($langs) &gt;= 4">
				  <xsl:text>&#x9;</xsl:text>
				  <xsl:apply-templates select="*" mode="indexreg"/>
				  <xsl:text> </xsl:text>
			</xsl:if>
			<xsl:if test="number($langs) &gt;= 5">
				  <xsl:text>&#x9;</xsl:text>
				  <xsl:apply-templates select="*" mode="indexreg2"/>
				  <xsl:text> </xsl:text>
			</xsl:if>
			<xsl:text>&#13;
</xsl:text>
	  </xsl:template>
	  <xsl:template match="*[local-name() = $nomarkupgroup/*/text()]">
			<!-- common group to PLB or MDF like msGroup|psGroup|glGroup  *[local-name() = $nomarkupgroup/*/text()] -->
			<xsl:apply-templates/>
	  </xsl:template>
	  <!-- ver mode templates =================================== -->
	  <xsl:template match="lx" mode="ver">
			<xsl:value-of select="."/>
			<xsl:text> </xsl:text>
	  </xsl:template>
	  <!-- index handling templates ==================================== -->
	  <xsl:template match="*" mode="indexeng"/>
	  <xsl:template match="*" mode="indexengsub"/>
	  <xsl:template match="*" mode="indexnat"/>
	  <xsl:template match="*" mode="indexreg"/>
	  <xsl:template match="*" mode="indexreg2"/>
	  <xsl:template match="*[local-name() = $nomarkupgroup/*/text()]" mode="indexeng">
			<!-- common group to PLB or MDF like msGroup|psGroup|glGroup  *[local-name() = $nomarkupgroup/*/text()] -->
			<xsl:apply-templates mode="indexeng"/>
	  </xsl:template>
	  <xsl:template match="*[local-name() = $nomarkupgroup/*/text()]" mode="indexengsub">
			<!-- common group to PLB or MDF like msGroup|psGroup|glGroup  *[local-name() = $nomarkupgroup/*/text()] -->
			<xsl:apply-templates mode="indexengsub"/>
	  </xsl:template>
	  <xsl:template match="*[local-name() = $nomarkupgroup/*/text()]" mode="indexnat">
			<!-- common group to PLB or MDF like msGroup|psGroup|glGroup  *[local-name() = $nomarkupgroup/*/text()] -->
			<xsl:apply-templates mode="indexnat"/>
	  </xsl:template>
	  <xsl:template match="*[local-name() = $nomarkupgroup/*/text()]" mode="indexreg">
			<!-- common group to PLB or MDF like msGroup|psGroup|glGroup  *[local-name() = $nomarkupgroup/*/text()] -->
			<xsl:apply-templates mode="indexreg"/>
	  </xsl:template>
	  <xsl:template match="*[local-name() = $nomarkupgroup/*/text()]" mode="indexreg2">
			<!-- common group to PLB or MDF like msGroup|psGroup|glGroup  *[local-name() = $nomarkupgroup/*/text()] -->
			<xsl:apply-templates mode="indexreg2"/>
	  </xsl:template>
</xsl:stylesheet>

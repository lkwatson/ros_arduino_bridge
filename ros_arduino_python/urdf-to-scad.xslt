<?xml version="1.0"?>

<xsl:stylesheet version="2.0"
		xmlns="http://www.w3.org/1999/xhtml"
		xmlns:html="http://www.w3.org/1999/xhtml"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:fn="http://www.w3.org/2005/xpath-functions">

  <xsl:output method="text" encoding="UTF-8" />

  <xsl:template match="/">
    <xsl:text>$fs = 0.1;&#x0A;</xsl:text>
    <xsl:text>$fa = 3;&#x0A;</xsl:text>
    <xsl:text>function meters(mm) = mm*1000;&#x0A;</xsl:text>
    <xsl:text>function radians(theta) = 180 * theta / 3.14159;&#x0A;</xsl:text>
    <xsl:apply-templates select="//link[@name eq 'base_link']" />
  </xsl:template>
  
  <xsl:template match="link">
    <xsl:variable name="parentName" select="@name" />
    <xsl:apply-templates select="visual" />
    <xsl:apply-templates select="//joint[@type eq 'fixed' and parent/@link eq $parentName]" />
  </xsl:template>

  <xsl:template match="origin">
    <xsl:if test="@xyz">
      <xsl:text>translate([</xsl:text>
      <xsl:value-of
	  select="fn:replace(fn:string-join(fn:tokenize(@xyz, '\s+'),
		  ', '), '[0-9.][0-9.]*', 'meters($0)')" />
      <xsl:text>])&#x0A;</xsl:text>
    </xsl:if>
    <xsl:if test="@rpy[. ne '0 0 0']">
      <xsl:text>rotate([</xsl:text>
      <xsl:value-of
	  select="fn:replace(fn:string-join(fn:tokenize(@rpy, '\s+'),
		  ', '), '[0-9.][0-9.]*', 'radians($0)')" />
      <xsl:text>])&#x0A;</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="joint">
    <xsl:variable name="childName" select="child/@link" />
    <xsl:value-of select="concat('// Processing ', parent/@link, '->',
			  $childName, '&#x0A;')" />
    <xsl:apply-templates select="origin" />
    <xsl:apply-templates select="//link[@name eq $childName]" />
  </xsl:template>

  <xsl:template match="visual">
    <xsl:apply-templates select="origin" />
    <xsl:choose>
      <xsl:when test="material/color/@rgba">
	<xsl:apply-templates select="material/color" />
      </xsl:when>
      <xsl:when test="material/@name">
	<xsl:variable name="colorName" select="material/@name" />
	<xsl:apply-templates select="//material[@name eq
				     $colorName]/color" />
      </xsl:when>
    </xsl:choose>
    <xsl:apply-templates select="geometry/*" />
  </xsl:template>

  <xsl:template match="color">
    <xsl:text>color([</xsl:text>
    <xsl:value-of
	select="fn:string-join(fn:tokenize(@rgba,
		'\s+'), ',')" />
    <xsl:text>])&#x0A;</xsl:text>
  </xsl:template>
  
  <xsl:template match="cylinder">
    <xsl:text>cylinder(h=meters(</xsl:text>
    <xsl:value-of select="@length" />
    <xsl:text>), r=meters(</xsl:text>
    <xsl:value-of select="@radius" />
    <xsl:text>), center=true);&#x0A;</xsl:text>
  </xsl:template>

  <xsl:template match="box">
    <xsl:text>scale([1000, 1000, 1000])&#x0A;</xsl:text>
    <xsl:text>cube(size=[</xsl:text>
    <xsl:value-of select="fn:string-join(fn:tokenize(@size, '\s+'), ', ')" />
    <xsl:text>], center=true);&#x0A;</xsl:text>
  </xsl:template>

  <xsl:template match="node()|@*" />

</xsl:stylesheet>

<?xml version="1.0" encoding="UTF-8"?>

<!--

Copyright (c) 2009 Braiden Kindt <braiden[at]braiden.org>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

-->

<xsl:stylesheet version="2.0"
    xmlns="http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xsi:schemaLocation="http://www.garmin.com/xmlschemas/TrainingCenterDatabase/v2
                        http://www.garmin.com/xmlschemas/TrainingCenterDatabasev2.xsd">
                
<xsl:template match="/">
  <TrainingCenterDatabase>
    <Activities>
      <xsl:apply-templates select="//garmin_dump"/>
    </Activities>
  </TrainingCenterDatabase>
</xsl:template>

<xsl:template match="//garmin_dump">
  <Activity>
    <xsl:attribute name="Sport">
      <xsl:choose>
        <xsl:when test="run/@sport='running'">Running</xsl:when>
        <xsl:when test="run/@sport='biking'">Biking</xsl:when>
        <xsl:otherwise>Other</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
    <Id><xsl:value-of select="adjust-dateTime-to-timezone(lap[1]/@start,xs:dayTimeDuration('PT0H'))"/></Id>
    <xsl:apply-templates select="lap"/>
  </Activity>
</xsl:template>

<xsl:template match="//garmin_dump/lap">
  <Lap>
    <xsl:variable name="duration">
      <xsl:text>PT</xsl:text>
      <xsl:for-each select="tokenize(@duration,':')">
        <xsl:value-of select="."/>
        <xsl:choose>
          <xsl:when test="position()=1">H</xsl:when>
          <xsl:when test="position()=2">M</xsl:when>
          <xsl:when test="position()=3">S</xsl:when>
        </xsl:choose>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="seconds" select="hours-from-duration($duration)*60*60 + minutes-from-duration($duration)*60 + seconds-from-duration($duration)"/>
    <xsl:attribute name="StartTime"><xsl:value-of select="adjust-dateTime-to-timezone(@start,xs:dayTimeDuration('PT0H'))"/></xsl:attribute>
    <TotalTimeSeconds><xsl:value-of select="$seconds"/></TotalTimeSeconds>
    <DistanceMeters><xsl:value-of select="@distance"/></DistanceMeters>
    <MaximumSpeed><xsl:value-of select="max_speed"/></MaximumSpeed>
    <Calories><xsl:value-of select="calories"/></Calories>
    <xsl:if test="avg_hr">
      <AverageHeartRateBpm>
        <Value><xsl:value-of select="avg_hr"/></Value>
      </AverageHeartRateBpm>
    </xsl:if>
    <xsl:if test="max_hr">
      <MaximumHeartRateBpm>
        <Value><xsl:value-of select="max_hr"/></Value> 
      </MaximumHeartRateBpm>
    </xsl:if>
    <Intensity>
      <xsl:choose>
        <xsl:when test="intensity='active'">Active</xsl:when>
        <xsl:when test="intensity='resting'">Resting</xsl:when>
        <xsl:otherwise>Active</xsl:otherwise>
      </xsl:choose>
    </Intensity>
    <xsl:if test="avg_cadence">
      <Cadence><xsl:value-of select="avg_cadence"/></Cadence>
    </xsl:if>
    <TriggerMethod>
      <xsl:choose>
        <xsl:when test="@trigger='manual'">Manual</xsl:when>
        <xsl:when test="@trigger='distance'">Distance</xsl:when>
        <xsl:when test="@trigger='location'">Location</xsl:when>
        <xsl:when test="@trigger='time'">Time</xsl:when>
        <xsl:when test="@trigger='heartrate'">HeartRate</xsl:when>
        <xsl:otherwise>Manual</xsl:otherwise>
      </xsl:choose>
    </TriggerMethod>
    <xsl:variable name="start" select="substring(@start,1,19)"/>
    <xsl:variable name="end">
      <xsl:choose>
        <xsl:when test="following-sibling::lap"><xsl:value-of select="substring(following-sibling::lap[1]/@start,1,19)"/></xsl:when>
        <xsl:otherwise>9999-99-99T99:99:99</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="points" select="../point[@time &gt;= $start and @time &lt; $end]"/>
    <xsl:if test="count($points) &gt; 0">
      <Track>
        <xsl:apply-templates select="$points"/>
      </Track>
    </xsl:if>
  </Lap>
</xsl:template>

<xsl:template match="//garmin_dump/point">
  <Trackpoint>
    <Time><xsl:value-of select="adjust-dateTime-to-timezone(@time,xs:dayTimeDuration('PT0H'))"/></Time>
    <xsl:if test="@lat">
     <Position>
       <LatitudeDegrees><xsl:value-of select="@lat"/></LatitudeDegrees>
       <LongitudeDegrees><xsl:value-of select="@lon"/></LongitudeDegrees>
     </Position>
   </xsl:if>
   <xsl:if test="@alt">
     <AltitudeMeters><xsl:value-of select="@alt"/></AltitudeMeters>
   </xsl:if>
   <xsl:if test="@distance">
     <DistanceMeters><xsl:value-of select="@distance"/></DistanceMeters>
   </xsl:if>
   <xsl:if test="@hr">
     <HeartRateBpm>
       <Value><xsl:value-of select="@hr"/></Value>
     </HeartRateBpm>
   </xsl:if> 
   <xsl:if test="@cadence">
    <Cadence><xsl:value-of select="@cadence"/></Cadence>
   </xsl:if>
 </Trackpoint>
</xsl:template>

</xsl:stylesheet>

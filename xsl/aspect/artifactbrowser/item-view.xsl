<!--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

-->

<!--
    Rendering specific to the item display page.

    Author: art.lowel at atmire.com
    Author: lieven.droogmans at atmire.com
    Author: ben at atmire.com
    Author: Alexey Maslov

-->

<xsl:stylesheet
    xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
    xmlns:dri="http://di.tamu.edu/DRI/1.0/"
    xmlns:mets="http://www.loc.gov/METS/"
    xmlns:dim="http://www.dspace.org/xmlns/dspace/dim"
    xmlns:xlink="http://www.w3.org/TR/xlink/"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:atom="http://www.w3.org/2005/Atom"
    xmlns:ore="http://www.openarchives.org/ore/terms/"
    xmlns:oreatom="http://www.openarchives.org/ore/atom/"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xalan="http://xml.apache.org/xalan"
    xmlns:encoder="xalan://java.net.URLEncoder"
    xmlns:util="org.dspace.app.xmlui.utils.XSLUtils"
    xmlns:jstring="java.lang.String"
    xmlns:rights="http://cosimo.stanford.edu/sdr/metsrights/"
    xmlns:confman="org.dspace.core.ConfigurationManager"
    exclude-result-prefixes="xalan encoder i18n dri mets dim xlink xsl util jstring rights confman">

    <xsl:output indent="yes"/>


    <xsl:variable name='handle_alt'><xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='focus'][@qualifier='object']"/></xsl:variable>
    <xsl:variable name='requestcopy'><xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='requestcopy']"/></xsl:variable>
    <xsl:variable name='tombstone'><xsl:value-of select="/dri:document/dri:body/dri:div[@id='aspect.artifactbrowser.TombstoneView.div.item-view']"/></xsl:variable>
    <xsl:variable name='bentley-collection'><xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:trail[@target='/handle/TEMP-BOGUS/65133']"/></xsl:variable>
    <xsl:variable name='ross-collection'><xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:trail[@target='/handle/TEMP-BOGUS/35324']"/></xsl:variable>
    <xsl:variable name='umtri-collection'><xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:trail[@target='/handle/TEMP-BOGUS/13914']"/></xsl:variable>


   <!-- this is for the short display -->
    <xsl:template name="itemSummaryView-DIM">
        <!-- Generate the info about the item from the metadata section -->
        <xsl:apply-templates select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim"
        mode="itemSummaryView-DIM"/>

        <xsl:copy-of select="$SFXLink" />

        <!-- Generate the Creative Commons license information from the file section (DSpace deposit license hidden by default)-->
        <xsl:if test="./mets:fileSec/mets:fileGrp[@USE='CC-LICENSE' or @USE='LICENSE']">
            <div class="license-info table">
                <p>
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.license-text</i18n:text>
                </p>
                <ul class="list-unstyled">
                    <xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='CC-LICENSE' or @USE='LICENSE']" mode="simple"/>
                </ul>
            </div>
        </xsl:if>


    </xsl:template>

    <!-- An item rendered in the detailView pattern, the "full item record" view of a DSpace item in Manakin. -->
    <xsl:template name="itemDetailView-DIM">
        <!-- Output all of the metadata about the item from the metadata section -->
        <xsl:apply-templates select="mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim"
                             mode="itemDetailView-DIM"/>

        <!-- Generate the bitstream information from the file section -->
        <xsl:choose>
            <xsl:when test="./mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='LICENSE']/mets:file">
                <h3><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-head</i18n:text></h3>
                <div class="file-list">
                    <xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='LICENSE' or @USE='CC-LICENSE']">
                        <xsl:with-param name="context" select="."/>
                        <xsl:with-param name="primaryBitstream" select="./mets:structMap[@TYPE='LOGICAL']/mets:div[@TYPE='DSpace Item']/mets:fptr/@FILEID"/>
                    </xsl:apply-templates>
                </div>
            </xsl:when>
            <!-- Special case for handling ORE resource maps stored as DSpace bitstreams -->
            <xsl:when test="./mets:fileSec/mets:fileGrp[@USE='ORE']">
                <xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='ORE']" mode="itemDetailView-DIM" />
            </xsl:when>
            <xsl:otherwise>
                <h2><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-head</i18n:text></h2>
                <table class="ds-table file-list">
                    <tr class="ds-table-header-row">
                        <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-file</i18n:text></th>
                        <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-size</i18n:text></th>
                        <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-format</i18n:text></th>
                        <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-view</i18n:text></th>
                    </tr>
                    <tr>
                        <td colspan="4">
                            <p><i18n:text>xmlui.dri2xhtml.METS-1.0.item-no-files</i18n:text></p>
                        </td>
                    </tr>
                </table>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>


    <xsl:template match="dim:dim" mode="itemSummaryView-DIM">
        <div class="item-summary-view-metadata">

	      <div style="font-weight: bold;font-size: 20px;"><xsl:call-template name="itemSummaryView-DIM-title2"/></div>

              <xsl:choose>
                  <xsl:when test="$ross-collection!=''">
                      <xsl:call-template name="itemSummaryView-DIM-authors2-ross" />
                  </xsl:when>
                  <xsl:when test="$bentley-collection!=''">
                      <xsl:call-template name="itemSummaryView-DIM-authors2-default" />
                  </xsl:when>
                  <xsl:when test="$umtri-collection!=''">
                      <xsl:call-template name="itemSummaryView-DIM-authors2-umtri" />
                  </xsl:when>
                  <xsl:otherwise>
                      <xsl:call-template name="itemSummaryView-DIM-authors2-default" />
                  </xsl:otherwise>
              </xsl:choose>

              <xsl:call-template name="itemSummaryView-DIM-date2"/>
	      <div style="padding-bottom: 2px;  margin: 10px 0 20px;  border-bottom: 1px solid #eee; ">
            </div>

            <div class="row">
                <div class="col-sm-4">
                    <div class="row">
                        <div class="col-xs-6 col-sm-12">
                            <xsl:call-template name="itemSummaryView-DIM-thumbnail"/>
                        </div>
                        <div class="col-xs-6 col-sm-12">
                            <xsl:call-template name="itemSummaryView-DIM-file-section"/>
                        </div>
                    </div>
                    <!-- <xsl:call-template name="itemSummaryView-DIM-date"/> -->
                    <!-- <xsl:call-template name="itemSummaryView-DIM-authors"/> -->
                    <xsl:if test="$ds_item_view_toggle_url != ''">
                        <xsl:call-template name="itemSummaryView-show-full"/>
                    </xsl:if>
                </div>
		<div class="col-sm-8">
                    <xsl:choose>
                        <xsl:when test="$ross-collection!=''">
                            <xsl:call-template name="itemSummaryView-DIM-fields-ross" />
                        </xsl:when>
                        <xsl:when test="$bentley-collection!=''">
                            <xsl:call-template name="itemSummaryView-DIM-fields-bentley" />
                        </xsl:when>
                        <xsl:when test="$umtri-collection!=''">
                            <xsl:call-template name="itemSummaryView-DIM-fields-umtri" />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="itemSummaryView-DIM-fields-default" />
                        </xsl:otherwise>
                    </xsl:choose>
                </div>
            </div>
        </div>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-fields-bentley">

        <!-- This is where you put the default list -->
	<xsl:call-template name="itemSummaryView-DIM-alternatetitle"><xsl:with-param name="label" select='"Other Titles"'/></xsl:call-template>
	<xsl:call-template name="itemSummaryView-DIM-citation"><xsl:with-param name="label" select='"Citation"'/></xsl:call-template>
	<xsl:call-template name="itemSummaryView-DIM-abstract"><xsl:with-param name="label" select='"Abstract"'/></xsl:call-template>
	<xsl:call-template name="itemSummaryView-DIM-publisher"><xsl:with-param name="label" select='"Publisher"'/></xsl:call-template>
	<xsl:call-template name="itemSummaryView-DIM-isbn"><xsl:with-param name="label" select='"ISBN"'/></xsl:call-template>
	<xsl:call-template name="itemSummaryView-DIM-issn"><xsl:with-param name="label" select='"ISSN"'/></xsl:call-template>
	<xsl:call-template name="itemSummaryView-DIM-ismn"><xsl:with-param name="label" select='"ISMN"'/></xsl:call-template>
	<xsl:call-template name="itemSummaryView-DIM-idother"><xsl:with-param name="label" select='"Other Identifiers"'/></xsl:call-template>
	<xsl:call-template name="itemSummaryView-DIM-doi"><xsl:with-param name="label" select='"DOIs"'/></xsl:call-template>
	<xsl:call-template name="itemSummaryView-DIM-pmid"><xsl:with-param name="label" select='"PMID"'/></xsl:call-template>
	<xsl:call-template name="itemSummaryView-DIM-govdoc"><xsl:with-param name="label" select='"Government Doc no."'/></xsl:call-template>
	<xsl:call-template name="itemSummaryView-DIM-other"><xsl:with-param name="label" select='"Other Identifiers"'/></xsl:call-template>
	<xsl:call-template name="itemSummaryView-DIM-relation"><xsl:with-param name="label" select='"Series/Report no."'/></xsl:call-template>
	<xsl:call-template name="itemSummaryView-DIM-subject"><xsl:with-param name="label" select='"Subject(s)"'/></xsl:call-template>
	<xsl:call-template name="itemSummaryView-DIM-description"><xsl:with-param name="label" select='"Description"'/></xsl:call-template>
	<xsl:call-template name="itemSummaryView-DIM-video"><xsl:with-param name="label" select='"Videos"'/></xsl:call-template>
	<xsl:call-template name="itemSummaryView-DIM-rights"><xsl:with-param name="label" select='"Rights"'/></xsl:call-template>
	<xsl:call-template name="itemSummaryView-DIM-type"><xsl:with-param name="label" select='"Type(s)"'/></xsl:call-template>


        <xsl:call-template name="itemSummaryView-DIM-HANDLE"/>
        <xsl:call-template name="itemSummaryView-DIM-URI"/>
        <xsl:call-template name="itemSummaryView-collections"/>

    </xsl:template>



    <xsl:template name="itemSummaryView-DIM-fields-ross">

        <!-- This is where you put the default list -->
	<xsl:call-template name="itemSummaryView-DIM-alternatetitle"><xsl:with-param name="label" select='"Other Title(s)"'/></xsl:call-template>
	<xsl:call-template name="itemSummaryView-DIM-subject"><xsl:with-param name="label" select='"Subjects"'/></xsl:call-template>
	<xsl:call-template name="itemSummaryView-DIM-publisher"><xsl:with-param name="label" select='"Publisher"'/></xsl:call-template>
	<xsl:call-template name="itemSummaryView-DIM-citation"><xsl:with-param name="label" select='"Citation"'/></xsl:call-template>
	<xsl:call-template name="itemSummaryView-DIM-relation"><xsl:with-param name="label" select='"Series/Report no."'/></xsl:call-template>
	<xsl:call-template name="itemSummaryView-DIM-abstract"><xsl:with-param name="label" select='"Abstract"'/></xsl:call-template>
	<xsl:call-template name="itemSummaryView-DIM-description"><xsl:with-param name="label" select='"Description"'/></xsl:call-template>
	<xsl:call-template name="itemSummaryView-DIM-govdoc"><xsl:with-param name="label" select='"Government Doc no."'/></xsl:call-template>
	<xsl:call-template name="itemSummaryView-DIM-isbn"><xsl:with-param name="label" select='"ISBN"'/></xsl:call-template>
	<xsl:call-template name="itemSummaryView-DIM-issn"><xsl:with-param name="label" select='"ISSN"'/></xsl:call-template>
	<xsl:call-template name="itemSummaryView-DIM-ismn"><xsl:with-param name="label" select='"ISMN"'/></xsl:call-template>
	<xsl:call-template name="itemSummaryView-DIM-idother"><xsl:with-param name="label" select='"Other Identifiers"'/></xsl:call-template>
	<xsl:call-template name="itemSummaryView-DIM-pmid"><xsl:with-param name="label" select='"PMID"'/></xsl:call-template>
	<xsl:call-template name="itemSummaryView-DIM-idother"><xsl:with-param name="label" select='"Other Identifiers"'/></xsl:call-template>
	<xsl:call-template name="itemSummaryView-DIM-classification"><xsl:with-param name="label" select='"Subject Classification"'/></xsl:call-template>
	<xsl:call-template name="itemSummaryView-DIM-type"><xsl:with-param name="label" select='"Type(s)"'/></xsl:call-template>

        <xsl:call-template name="itemSummaryView-DIM-HANDLE"/>
        <xsl:call-template name="itemSummaryView-DIM-URI"/>
        <xsl:call-template name="itemSummaryView-collections"/>

    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-fields-umtri">

        <!-- This is where you put the default list -->
	<xsl:call-template name="itemSummaryView-DIM-alternatetitle"><xsl:with-param name="label" select='"Other Title(s)"'/></xsl:call-template>
	<xsl:call-template name="itemSummaryView-DIM-subject"><xsl:with-param name="label" select='"Subject(s)"'/></xsl:call-template>
	<xsl:call-template name="itemSummaryView-DIM-publisher"><xsl:with-param name="label" select='"Publisher"'/></xsl:call-template>
	<xsl:call-template name="itemSummaryView-DIM-citation"><xsl:with-param name="label" select='"Citation"'/></xsl:call-template>
	<xsl:call-template name="itemSummaryView-DIM-relation"><xsl:with-param name="label" select='"Series/Report no."'/></xsl:call-template>
	<xsl:call-template name="itemSummaryView-DIM-abstract"><xsl:with-param name="label" select='"Abstract"'/></xsl:call-template>
	<xsl:call-template name="itemSummaryView-DIM-description"><xsl:with-param name="label" select='"Description"'/></xsl:call-template>
	<xsl:call-template name="itemSummaryView-DIM-govdoc"><xsl:with-param name="label" select='"Government Doc no."'/></xsl:call-template>
	<xsl:call-template name="itemSummaryView-DIM-isbn"><xsl:with-param name="label" select='"ISBN"'/></xsl:call-template>
	<xsl:call-template name="itemSummaryView-DIM-issn"><xsl:with-param name="label" select='"ISSN"'/></xsl:call-template>
	<xsl:call-template name="itemSummaryView-DIM-ismn"><xsl:with-param name="label" select='"ISMN"'/></xsl:call-template>
	<xsl:call-template name="itemSummaryView-DIM-idother"><xsl:with-param name="label" select='"Other Identifiers"'/></xsl:call-template>
	<xsl:call-template name="itemSummaryView-DIM-pmid"><xsl:with-param name="label" select='"PMID"'/></xsl:call-template>
	<xsl:call-template name="itemSummaryView-DIM-other"><xsl:with-param name="label" select='"Other Identifiers"'/></xsl:call-template>
	<xsl:call-template name="itemSummaryView-DIM-video"><xsl:with-param name="label" select='"Videos"'/></xsl:call-template>
	<xsl:call-template name="itemSummaryView-DIM-type"><xsl:with-param name="label" select='"Type(s)"'/></xsl:call-template>

        <xsl:call-template name="itemSummaryView-DIM-HANDLE"/>
        <xsl:call-template name="itemSummaryView-DIM-URI"/>
        <xsl:call-template name="itemSummaryView-collections"/>

    </xsl:template>


    <xsl:template name="itemSummaryView-DIM-fields-default">

        <!-- This is where you put the default list -->
	<xsl:call-template name="itemSummaryView-DIM-alternatetitle"><xsl:with-param name="label" select='"Other Title(s)"'/></xsl:call-template>
	<xsl:call-template name="itemSummaryView-DIM-citation"><xsl:with-param name="label" select='"Citation"'/></xsl:call-template>
	<xsl:call-template name="itemSummaryView-DIM-abstract"><xsl:with-param name="label" select='"Abstract"'/></xsl:call-template>
	<xsl:call-template name="itemSummaryView-DIM-publisher"><xsl:with-param name="label" select='"Publisher"'/></xsl:call-template>
	<xsl:call-template name="itemSummaryView-DIM-isbn"><xsl:with-param name="label" select='"ISBN"'/></xsl:call-template>
	<xsl:call-template name="itemSummaryView-DIM-issn"><xsl:with-param name="label" select='"ISSN"'/></xsl:call-template>
	<xsl:call-template name="itemSummaryView-DIM-ismn"><xsl:with-param name="label" select='"ISMN"'/></xsl:call-template>
	<xsl:call-template name="itemSummaryView-DIM-other"><xsl:with-param name="label" select='"Other Identifiers"'/></xsl:call-template>
	<xsl:call-template name="itemSummaryView-DIM-doi"><xsl:with-param name="label" select='"DOIs"'/></xsl:call-template>
	<xsl:call-template name="itemSummaryView-DIM-pmid"><xsl:with-param name="label" select='"PMID"'/></xsl:call-template>
	<xsl:call-template name="itemSummaryView-DIM-govdoc"><xsl:with-param name="label" select='"Government Doc No."'/></xsl:call-template>
	<xsl:call-template name="itemSummaryView-DIM-idother"><xsl:with-param name="label" select='"Other Identifiers"'/></xsl:call-template>
	<xsl:call-template name="itemSummaryView-DIM-relation"><xsl:with-param name="label" select='"Series/Report no."'/></xsl:call-template>
	<xsl:call-template name="itemSummaryView-DIM-subject"><xsl:with-param name="label" select='"Subject(s)"'/></xsl:call-template>
	<xsl:call-template name="itemSummaryView-DIM-description"><xsl:with-param name="label" select='"Description"'/></xsl:call-template>
	<xsl:call-template name="itemSummaryView-DIM-video"><xsl:with-param name="label" select='"Videos"'/></xsl:call-template>
	<xsl:call-template name="itemSummaryView-DIM-type"><xsl:with-param name="label" select='"Type(s)"'/></xsl:call-template>

        <xsl:call-template name="itemSummaryView-DIM-HANDLE"/>
        <xsl:call-template name="itemSummaryView-DIM-URI"/>
        <xsl:call-template name="itemSummaryView-collections"/>

    </xsl:template>


    <xsl:template name="itemSummaryView-DIM-title2">
        <xsl:choose>
            <xsl:when test="count(dim:field[@element='title'][not(@qualifier)]) &gt; 1">
                    <xsl:value-of select="dim:field[@element='title'][not(@qualifier)][1]/node()"/>
                <div class="simple-item-view-other">
                    <p class="lead">
                        <xsl:for-each select="dim:field[@element='title'][not(@qualifier)]">
                            <xsl:if test="not(position() = 1)">
                                <xsl:value-of select="./node()"/>
                                <xsl:if test="count(following-sibling::dim:field[@element='title'][not(@qualifier)]) != 0">
                                    <xsl:text>; </xsl:text>
                                    <br/>
                                </xsl:if>
                            </xsl:if>

                        </xsl:for-each>
                    </p>
                </div>
            </xsl:when>
            <xsl:when test="count(dim:field[@element='title'][not(@qualifier)]) = 1">
                    <xsl:value-of select="dim:field[@element='title'][not(@qualifier)][1]/node()"/>
            </xsl:when>
            <xsl:otherwise>
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.no-title</i18n:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>



    <xsl:template name="itemSummaryView-DIM-title">
        <xsl:choose>
            <xsl:when test="count(dim:field[@element='title'][not(@qualifier)]) &gt; 1">
                <h2 class="page-header first-page-header">
                    <xsl:value-of select="dim:field[@element='title'][not(@qualifier)][1]/node()"/>
                </h2>
                <div class="simple-item-view-other">
                    <p class="lead">
                        <xsl:for-each select="dim:field[@element='title'][not(@qualifier)]">
                            <xsl:if test="not(position() = 1)">
                                <xsl:value-of select="./node()"/>
                                <xsl:if test="count(following-sibling::dim:field[@element='title'][not(@qualifier)]) != 0">
                                    <xsl:text>; </xsl:text>
                                    <br/>
                                </xsl:if>
                            </xsl:if>

                        </xsl:for-each>
                    </p>
                </div>
            </xsl:when>
            <xsl:when test="count(dim:field[@element='title'][not(@qualifier)]) = 1">
                <h2 class="page-header first-page-header">
                    <xsl:value-of select="dim:field[@element='title'][not(@qualifier)][1]/node()"/>
                </h2>
            </xsl:when>
            <xsl:otherwise>
                <h2 class="page-header first-page-header">
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.no-title</i18n:text>
                </h2>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-thumbnail">
        <div class="thumbnail">
            <xsl:choose>
                <xsl:when test="//mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']">
                    <xsl:variable name="src">
                        <xsl:choose>
                            <xsl:when test="/mets:METS/mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/mets:file[@GROUPID=../../mets:fileGrp[@USE='CONTENT']/mets:file[@GROUPID=../../mets:fileGrp[@USE='THUMBNAIL']/mets:file/@GROUPID][1]/@GROUPID]">
                                <xsl:value-of
                                        select="/mets:METS/mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/mets:file[@GROUPID=../../mets:fileGrp[@USE='CONTENT']/mets:file[@GROUPID=../../mets:fileGrp[@USE='THUMBNAIL']/mets:file/@GROUPID][1]/@GROUPID]/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of
                                        select="//mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/mets:file/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <!-- Checking if Thumbnail is restricted and if so, show a restricted image --> 
                    <xsl:choose>
                        <xsl:when test="contains($src,'isAllowed=n')"/>
                        <xsl:otherwise>
                            <img class="img-thumbnail" alt="Thumbnail">
                                <xsl:attribute name="src">
                                    <xsl:value-of select="$src"/>
                                </xsl:attribute>
                            </img>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <img class="img-thumbnail" alt="Thumbnail">
                        <xsl:attribute name="data-src">
                            <xsl:text>holder.js/100%x</xsl:text>
                            <xsl:value-of select="$thumbnail.maxheight"/>
                            <xsl:text>/text:No Thumbnail</xsl:text>
                        </xsl:attribute>
                    </img>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-alternatetitle">
	<xsl:param name = "label" />
        <xsl:if test="dim:field[@element='title' and @qualifier='alternative']">
            <div class="simple-item-view-description item-page-field-wrapper table">
		<h5><xsl:value-of select = "$label" /></h5>
                <div>
                    <xsl:for-each select="dim:field[@element='title' and @qualifier='alternative']">
                        <xsl:choose>
                            <xsl:when test="node()">
                                <xsl:copy-of select="node()"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>&#160;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="count(following-sibling::dim:field[@element='title' and @qualifier='alternative']) != 0">
                            <div class="spacer">&#160;</div>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:if test="count(dim:field[@element='title' and @qualifier='alternative']) &gt; 1">
                        <div class="spacer">&#160;</div>
                    </xsl:if>
                </div>
            </div>
        </xsl:if>
    </xsl:template>


    <xsl:template name="itemSummaryView-DIM-citation">
	<xsl:param name = "label" />
        <xsl:if test="dim:field[@element='identifier' and @qualifier='citation']">
            <div class="simple-item-view-description item-page-field-wrapper table">
		<h5><xsl:value-of select = "$label" /></h5>
                <div>
                    <xsl:for-each select="dim:field[@element='identifier' and @qualifier='citation']">
                        <xsl:choose>
                            <xsl:when test="node()">
                                <xsl:copy-of select="node()"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>&#160;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="count(following-sibling::dim:field[@element='identifier' and @qualifier='citation']) != 0">
                            <div class="spacer">&#160;</div>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:if test="count(dim:field[@element='identifier' and @qualifier='citation']) &gt; 1">
                        <div class="spacer">&#160;</div>
                    </xsl:if>
                </div>
            </div>
        </xsl:if>
    </xsl:template>


    <xsl:template name="itemSummaryView-DIM-abstract">
	<xsl:param name = "label" />    
        <xsl:if test="dim:field[@element='description' and @qualifier='abstract']">
		<div class="simple-item-view-description item-page-field-wrapper table">
		<div class="comment more">
                <h5><xsl:value-of select = "$label" /></h5>
                    <xsl:for-each select="dim:field[@element='description' and @qualifier='abstract']">
                        <xsl:choose>
                            <xsl:when test="node()">
                                <xsl:copy-of select="node()"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>&#160;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="count(following-sibling::dim:field[@element='description' and @qualifier='abstract']) != 0">
                            <div class="spacer">&#160;</div>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:if test="count(dim:field[@element='description' and @qualifier='abstract']) &gt; 1">
                        <div class="spacer">&#160;</div>
                    </xsl:if>
                </div>
            </div>
        </xsl:if>
    </xsl:template>


    <xsl:template name="itemSummaryView-DIM-publisher">
	<xsl:param name = "label" />    
        <xsl:if test="dim:field[@element='publisher'][not(@qualifier)]">
            <div class="simple-item-view-description item-page-field-wrapper table">
		<h5><xsl:value-of select = "$label" /></h5>
                <div>
                    <xsl:for-each select="dim:field[@element='publisher'][not(@qualifier)]">
                        <xsl:choose>
                            <xsl:when test="node()">
                                <xsl:copy-of select="node()"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>&#160;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="count(following-sibling::dim:field[@element='publisher'][not(@qualifier)]) != 0">
                            <div class="spacer">&#160;</div>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:if test="count(dim:field[@element='publisher'][not(@qualifier)]) &gt; 1">
                        <div class="spacer">&#160;</div>
                    </xsl:if>
                </div>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-isbn">
	<xsl:param name = "label" />    
        <xsl:if test="dim:field[@element='identifier' and @qualifier='isbn']">
            <div class="simple-item-view-description item-page-field-wrapper table">
		<h5><xsl:value-of select = "$label" /></h5>
                <div>
                    <xsl:for-each select="dim:field[@element='identifier' and @qualifier='isbn']">
                        <xsl:choose>
                            <xsl:when test="node()">
                                <xsl:copy-of select="node()"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>&#160;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="count(following-sibling::dim:field[@element='identifier' and @qualifier='isbn']) != 0">
                            <div class="spacer">&#160;</div>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:if test="count(dim:field[@element='identifier' and @qualifier='isbn']) &gt; 1">
                        <div class="spacer">&#160;</div>
                    </xsl:if>
                </div>
            </div>
        </xsl:if>
    </xsl:template>


    <xsl:template name="itemSummaryView-DIM-issn">
	<xsl:param name = "label" />    
        <xsl:if test="dim:field[@element='identifier' and @qualifier='issn']">
            <div class="simple-item-view-description item-page-field-wrapper table">
		<h5><xsl:value-of select = "$label" /></h5>
                <div>
                    <xsl:for-each select="dim:field[@element='identifier' and @qualifier='issn']">
                        <xsl:choose>
                            <xsl:when test="node()">
                                <xsl:copy-of select="node()"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>&#160;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="count(following-sibling::dim:field[@element='identifier' and @qualifier='issn']) != 0">
                            <div class="spacer">&#160;</div>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:if test="count(dim:field[@element='identifier' and @qualifier='issn']) &gt; 1">
                        <div class="spacer">&#160;</div>
                    </xsl:if>
                </div>
            </div>
        </xsl:if>
    </xsl:template>


    <xsl:template name="itemSummaryView-DIM-ismn">
	<xsl:param name = "label" />
        <xsl:if test="dim:field[@element='identifier' and @qualifier='ismn']">
            <div class="simple-item-view-description item-page-field-wrapper table">
		<h5><xsl:value-of select = "$label" /></h5>
                <div>
                    <xsl:for-each select="dim:field[@element='identifier' and @qualifier='ismn']">
                        <xsl:choose>
                            <xsl:when test="node()">
                                <xsl:copy-of select="node()"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>&#160;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="count(following-sibling::dim:field[@element='identifier' and @qualifier='ismn']) != 0">
                            <div class="spacer">&#160;</div>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:if test="count(dim:field[@element='identifier' and @qualifier='ismn']) &gt; 1">
                        <div class="spacer">&#160;</div>
                    </xsl:if>
                </div>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-other">
	<xsl:param name = "label" />    
        <xsl:if test="dim:field[@element='identifier' and @qualifier='other']">
            <div class="simple-item-view-description item-page-field-wrapper table">
		<h5><xsl:value-of select = "$label" /></h5>
                <div>
                    <xsl:for-each select="dim:field[@element='identifier' and @qualifier='other']">
                        <xsl:choose>
                            <xsl:when test="node()">
                                <xsl:copy-of select="node()"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>&#160;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="count(following-sibling::dim:field[@element='identifier' and @qualifier='other']) != 0">
                            <div class="spacer">&#160;</div>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:if test="count(dim:field[@element='identifier' and @qualifier='other']) &gt; 1">
                        <div class="spacer">&#160;</div>
                    </xsl:if>
                </div>
            </div>
        </xsl:if>
    </xsl:template>


    <xsl:template name="itemSummaryView-DIM-doi">
	<xsl:param name = "label" />    
        <xsl:if test="dim:field[@element='identifier' and @qualifier='doi']">
            <div class="simple-item-view-description item-page-field-wrapper table">
		<h5><xsl:value-of select = "$label" /></h5>
                <div>
                    <xsl:for-each select="dim:field[@element='identifier' and @qualifier='doi']">
                        <xsl:choose>
                            <xsl:when test="node()">


                                <xsl:if test="(contains(node(),'http'))">
        

                                    <a>
                                        <xsl:attribute name="href">
                                        <xsl:copy-of select="node()"/>
                                        </xsl:attribute>
                                        <xsl:copy-of select="node()"/>
                                    </a>
                                  </xsl:if>


                                  <xsl:if test="(not(contains(./node(),'http')))">


                                    <a>
                                        <xsl:attribute name="href">
                                          <xsl:text>http://dx.doi.org/</xsl:text>
                                            <xsl:copy-of select="node()"/>
                                        </xsl:attribute>
                                        <xsl:copy-of select="node()"/>
                                    </a>
                                  </xsl:if>

                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>&#160;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="count(following-sibling::dim:field[@element='identifier' and @qualifier='doi']) != 0">
                            <div class="spacer">&#160;</div>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:if test="count(dim:field[@element='identifier' and @qualifier='doi']) &gt; 1">
                        <div class="spacer">&#160;</div>
                    </xsl:if>
                </div>
            </div>
        </xsl:if>
    </xsl:template>


    <xsl:template name="itemSummaryView-DIM-pmid">
	<xsl:param name = "label" />
        <xsl:if test="dim:field[@element='identifier' and @qualifier='pmid']">
            <div class="simple-item-view-description item-page-field-wrapper table">
		<h5><xsl:value-of select = "$label" /></h5>
                <div>
                    <xsl:for-each select="dim:field[@element='identifier' and @qualifier='pmid']">
                        <xsl:choose>
                            <xsl:when test="node()">
                                <xsl:copy-of select="node()"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>&#160;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="count(following-sibling::dim:field[@element='identifier' and @qualifier='pmid']) != 0">
                            <div class="spacer">&#160;</div>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:if test="count(dim:field[@element='identifier' and @qualifier='pmdi']) &gt; 1">
                        <div class="spacer">&#160;</div>
                    </xsl:if>
                </div>
            </div>
        </xsl:if>
    </xsl:template>


    <xsl:template name="itemSummaryView-DIM-govdoc">
	<xsl:param name = "label" />    
        <xsl:if test="dim:field[@element='identifier' and @qualifier='govdoc']">
            <div class="simple-item-view-description item-page-field-wrapper table">
		    <h5><xsl:value-of select = "$label" /></h5>
                <div>
                    <xsl:for-each select="dim:field[@element='identifier' and @qualifier='govdoc']">
                        <xsl:choose>
                            <xsl:when test="node()">
                                <xsl:copy-of select="node()"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>&#160;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="count(following-sibling::dim:field[@element='identifier' and @qualifier='govdoc']) != 0">
                            <div class="spacer">&#160;</div>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:if test="count(dim:field[@element='identifier' and @qualifier='govdoc']) &gt; 1">
                        <div class="spacer">&#160;</div>
                    </xsl:if>
                </div>
            </div>
        </xsl:if>
    </xsl:template>


    <xsl:template name="itemSummaryView-DIM-idother">
	<xsl:param name = "label" />    
        <xsl:if test="dim:field[@element='identifier'][not(@qualifier)]">
            <div class="simple-item-view-description item-page-field-wrapper table">
		    <h5><xsl:value-of select = "$label" /></h5>
                <div>
                    <xsl:for-each select="dim:field[@element='identifier'][not(@qualifier)]">
                        <xsl:choose>
                            <xsl:when test="node()">
                                <xsl:copy-of select="node()"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>&#160;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="count(following-sibling::dim:field[@element='identifier'][not(@qualifier)]) != 0">
                            <div class="spacer">&#160;</div>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:if test="count(dim:field[@element='identifier'][not(@qualifier)]) &gt; 1">
                        <div class="spacer">&#160;</div>
                    </xsl:if>
                </div>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-relation">
	<xsl:param name = "label" />    
        <xsl:if test="dim:field[@element='relation' and @qualifier='ispartofseries']">
            <div class="simple-item-view-description item-page-field-wrapper table">
		<h5><xsl:value-of select = "$label" /></h5>
                <div>
                    <xsl:for-each select="dim:field[@element='relation' and @qualifier='ispartofseries']">
                        <xsl:choose>
                            <xsl:when test="node()">
                                <xsl:copy-of select="node()"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>&#160;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="count(following-sibling::dim:field[@element='relation' and @qualifier='ispartofseries']) != 0">
                            <div class="spacer">&#160;</div>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:if test="count(dim:field[@element='relation' and @qualifier='ispartofseries']) &gt; 1">
                        <div class="spacer">&#160;</div>
                    </xsl:if>
                </div>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-subject">
	<xsl:param name = "label" />    
        <xsl:if test="dim:field[@element='subject'][not(@qualifier)]">
            <div class="simple-item-view-description item-page-field-wrapper table">
		<h5><xsl:value-of select = "$label" /></h5>
                <div>
                    <xsl:for-each select="dim:field[@element='subject'][not(@qualifier)]">
                        <xsl:choose>
                            <xsl:when test="node()">
                                <xsl:copy-of select="node()"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>&#160;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="count(following-sibling::dim:field[@element='subject'][not(@qualifier)]) != 0">
                            <div class="spacer">&#160;</div>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:if test="count(dim:field[@element='subject'][not(@qualifier)]) &gt; 1">
                        <div class="spacer">&#160;</div>
                    </xsl:if>
                </div>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-description">
	<xsl:param name = "label" />
        <xsl:if test="dim:field[@element='description'][not(@qualifier)]">
            <div class="simple-item-view-description item-page-field-wrapper table">
		<h5><xsl:value-of select = "$label" /></h5>
                <div>
                    <xsl:for-each select="dim:field[@element='description'][not(@qualifier)]">
                        <xsl:choose>
                            <xsl:when test="node()">
                                <xsl:copy-of select="node()"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>&#160;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="count(following-sibling::dim:field[@element='description'][not(@qualifier)]) != 0">
                            <div class="spacer">&#160;</div>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:if test="count(dim:field[@element='description'][not(@qualifier)]) &gt; 1">
                        <div class="spacer">&#160;</div>
                    </xsl:if>
                </div>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-video">
	<xsl:param name = "label" />    
        <xsl:if test="dim:field[@element='identifier' and @qualifier='videostream']">
            <div class="simple-item-view-description item-page-field-wrapper table">
		<h5><xsl:value-of select = "$label" /></h5>
                <div>
                    <xsl:for-each select="dim:field[@element='identifier' and @qualifier='videostream']">
                        <xsl:choose>
			     <xsl:when test="node()">
                                  <script>
                                    <xsl:attribute name="src">
                                      <xsl:copy-of select="node()"/>
                                    </xsl:attribute>
                                    <xsl:copy-of select="node()"/>
                                  </script>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>&#160;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="count(following-sibling::dim:field[@element='identifier' and @qualifier='videostream']) != 0">
                            <div class="spacer">&#160;</div>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:if test="count(dim:field[@element='identifier' and @qualifier='videostream']) &gt; 1">
                        <div class="spacer">&#160;</div>
                    </xsl:if>
                </div>
            </div>
        </xsl:if>
    </xsl:template>


    <xsl:template name="itemSummaryView-DIM-type">
	<xsl:param name = "label" />    
        <xsl:if test="dim:field[@element='description'][not(@qualifier)]">
            <div class="simple-item-view-description item-page-field-wrapper table">
		<h5><xsl:value-of select = "$label" /></h5>
                <div>
                    <xsl:for-each select="dim:field[@element='type'][not(@qualifier)]">
                        <xsl:choose>
                            <xsl:when test="node()">
                                <xsl:copy-of select="node()"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>&#160;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="count(following-sibling::dim:field[@element='type'][not(@qualifier)]) != 0">
                            <div class="spacer">&#160;</div>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:if test="count(dim:field[@element='type'][not(@qualifier)]) &gt; 1">
                        <div class="spacer">&#160;</div>
                    </xsl:if>
                </div>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-rights">
	<xsl:param name = "label" />    
        <xsl:if test="dim:field[@element='rights']">
            <div class="simple-item-view-description item-page-field-wrapper table">
		<h5><xsl:value-of select = "$label" /></h5>
                <div>
                    <xsl:for-each select="dim:field[@element='rights']">
                        <xsl:choose>
                            <xsl:when test="node()">
                                <xsl:copy-of select="node()"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>&#160;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="count(following-sibling::dim:field[@element='rights']) != 0">
                            <div class="spacer">&#160;</div>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:if test="count(dim:field[@element='rights']) &gt; 1">
                        <div class="spacer">&#160;</div>
                    </xsl:if>
                </div>
            </div>
        </xsl:if>
    </xsl:template>


    <xsl:template name="itemSummaryView-DIM-classification">
	<xsl:param name = "label" />    
        <xsl:if test="dim:field[@element='subject' and @qualifier='classification']">
            <div class="simple-item-view-description item-page-field-wrapper table">
		<h5><xsl:value-of select = "$label" /></h5>
                <div>
                    <xsl:for-each select="dim:field[@element='subject' and @qualifier='classification']">
                        <xsl:choose>
                            <xsl:when test="node()">
                                <xsl:copy-of select="node()"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>&#160;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="count(following-sibling::dim:field[@element='subject' and @qualifier='classification']) != 0">
                            <div class="spacer">&#160;</div>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:if test="count(dim:field[@element='subject' and @qualifier='classification']) &gt; 1">
                        <div class="spacer">&#160;</div>
                    </xsl:if>
                </div>
            </div>
        </xsl:if>
    </xsl:template>




    <xsl:template name="itemSummaryView-DIM-authors">
        <xsl:if test="dim:field[@element='contributor'][@qualifier='author' and descendant::text()] or dim:field[@element='creator' and descendant::text()] or dim:field[@element='contributor' and descendant::text()]">
            <div class="simple-item-view-authors item-page-field-wrapper table">
                <h5><i18n:text>xmlui.dri2xhtml.METS-1.0.item-author</i18n:text></h5>
                <xsl:choose>
                    <xsl:when test="dim:field[@element='contributor'][@qualifier='author']">
                        <xsl:for-each select="dim:field[@element='contributor'][@qualifier='author']">
                            <xsl:call-template name="itemSummaryView-DIM-authors-entry" />
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:when test="dim:field[@element='creator']">
                        <xsl:for-each select="dim:field[@element='creator']">
                            <xsl:call-template name="itemSummaryView-DIM-authors-entry" />
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:when test="dim:field[@element='contributor']">
                        <xsl:for-each select="dim:field[@element='contributor']">
                            <xsl:call-template name="itemSummaryView-DIM-authors-entry" />
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.no-author</i18n:text>
                    </xsl:otherwise>
                </xsl:choose>
            </div>
        </xsl:if>
    </xsl:template>


    <xsl:template name="itemSummaryView-DIM-authors2">
        <xsl:if test="dim:field[@element='contributor'][@qualifier='author' and descendant::text()] or dim:field[@element='creator' and descendant::text()] or dim:field[@element='contributor' and descendant::text()]">
            <div>
                <xsl:choose>
			<xsl:when test="dim:field[@element='contributor'][@qualifier='author']">
				<div class="comment auth_more">				
                        <xsl:for-each select="dim:field[@element='contributor'][@qualifier='author']">
                            <xsl:copy-of select="node()"/>
                            <xsl:if test="count(following-sibling::dim:field[@element='contributor'][@qualifier='author']) != 0">
                                  <xsl:text>; </xsl:text>
                             </xsl:if>
		     </xsl:for-each>
	     </div>
                        
                    </xsl:when>
                </xsl:choose>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-authors2-default">
        <xsl:if test="dim:field[@element='contributor'][@qualifier='author']">
            <div>
            <div class="comment auth_more">
                <xsl:if test="dim:field[@element='contributor'][@qualifier='author']">
                    <xsl:for-each select="dim:field[@element='contributor'][@qualifier='author']">
                        <xsl:copy-of select="node()"/>
                            <xsl:if test="count(following-sibling::dim:field[@element='contributor'][@qualifier='author']) != 0">
                                <xsl:text>; </xsl:text>
                            </xsl:if>
                    </xsl:for-each>
                </xsl:if>
            </div>
            </div>
        </xsl:if>
    </xsl:template>


    <xsl:template name="itemSummaryView-DIM-authors2-ross">
        <xsl:if test="dim:field[@element='contributor'][@qualifier='author'] or dim:field[@element='contributor'][@qualifier='other'] or dim:field[@element='contributor']">
            <div>
            <div class="comment auth_more">
                <xsl:if test="dim:field[@element='contributor'][@qualifier='author']">
                    <xsl:for-each select="dim:field[@element='contributor'][@qualifier='author']">
                        <xsl:copy-of select="node()"/>
                            <xsl:if test="count(following-sibling::dim:field[@element='contributor'][@qualifier='author']) != 0">
                                <xsl:text>; </xsl:text>
		            </xsl:if>
                    </xsl:for-each>
                    <xsl:if test="dim:field[@element='contributor'][@qualifier='other'] or dim:field[@element='contributor'][not(@qualifier)] or dim:field[@element='contributor'][@qualifier='editor'] or dim:field[@element='contributor'][@qualifier='illustrator'] or dim:field[@element='contributor'][@qualifier='committeemember']">
                           <xsl:text>; </xsl:text>
                    </xsl:if>
                </xsl:if>

                <xsl:if test="dim:field[@element='contributor'][not(@qualifier)]">
                    <xsl:for-each select="dim:field[@element='contributor'][not(@qualifier)]">
                        <xsl:copy-of select="node()"/>
                            <xsl:if test="count(following-sibling::dim:field[@element='contributor'][not(@qualifier)]) != 0">
                                <xsl:text>; </xsl:text>
                            </xsl:if>
                    </xsl:for-each>
                    <xsl:if test="dim:field[@element='contributor'][@qualifier='other'] or dim:field[@element='contributor'][@qualifier='editor'] or dim:field[@element='contributor'][@qualifier='illustrator'] or dim:field[@element='contributor'][@qualifier='committeemember']">
                        <xsl:text>; </xsl:text>
                    </xsl:if>
                </xsl:if>

                <xsl:if test="dim:field[@element='contributor'][@qualifier='other']">
                    <xsl:for-each select="dim:field[@element='contributor'][@qualifier='other']">
                        <xsl:copy-of select="node()"/>
                            <xsl:if test="count(following-sibling::dim:field[@element='contributor'][@qualifier='other']) != 0">
                                <xsl:text>; </xsl:text>
                            </xsl:if>
                    </xsl:for-each>
                    <xsl:if test="dim:field[@element='contributor'][@qualifier='editor'] or dim:field[@element='contributor'][@qualifier='illustrator'] or dim:field[@element='contributor'][@qualifier='committeemember']">
                        <xsl:text>; </xsl:text>
                    </xsl:if>
                </xsl:if>

                <xsl:if test="dim:field[@element='contributor'][@qualifier='editor']">
                    <xsl:for-each select="dim:field[@element='contributor'][@qualifier='editor']">
                        <xsl:copy-of select="node()"/>
                            <xsl:if test="count(following-sibling::dim:field[@element='contributor'][@qualifier='editor']) != 0">
                                <xsl:text>; </xsl:text>
                            </xsl:if>
                    </xsl:for-each>
                    <xsl:if test="dim:field[@element='contributor'][@qualifier='illustrator'] or dim:field[@element='contributor'][@qualifier='committeemember']">
                        <xsl:text>; </xsl:text>
                    </xsl:if>
                </xsl:if>

                <xsl:if test="dim:field[@element='contributor'][@qualifier='illustrator']">
                    <xsl:for-each select="dim:field[@element='contributor'][@qualifier='illustrator']">
                        <xsl:copy-of select="node()"/>
                            <xsl:if test="count(following-sibling::dim:field[@element='contributor'][@qualifier='illustrator']) != 0">
                                <xsl:text>; </xsl:text>
                            </xsl:if>
                    </xsl:for-each>
                    <xsl:if test="dim:field[@element='contributor'][@qualifier='committeemember']">
                        <xsl:text>; </xsl:text>
                    </xsl:if>
                </xsl:if>

                <xsl:if test="dim:field[@element='contributor'][@qualifier='committeemember']">
                    <xsl:for-each select="dim:field[@element='contributor'][@qualifier='committeemember']">
                        <xsl:copy-of select="node()"/>
                            <xsl:if test="count(following-sibling::dim:field[@element='contributor'][@qualifier='committeemember']) != 0">
                                <xsl:text>; </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                </xsl:if>
            </div>
            </div>
        </xsl:if>
    </xsl:template>


    <xsl:template name="itemSummaryView-DIM-authors2-umtri">
        <xsl:if test="dim:field[@element='contributor'][@qualifier='author'] or dim:field[@element='contributor'][@qualifier='other'] or dim:field[@element='contributor']">
            <div>
            <div class="comment auth_more">
                <xsl:if test="dim:field[@element='contributor'][@qualifier='author']">
                    <xsl:for-each select="dim:field[@element='contributor'][@qualifier='author']">
                        <xsl:copy-of select="node()"/>
                            <xsl:if test="count(following-sibling::dim:field[@element='contributor'][@qualifier='author']) != 0">
                                <xsl:text>; </xsl:text>
                            </xsl:if>
                    </xsl:for-each>
                    <xsl:if test="dim:field[@element='contributor'][@qualifier='other'] or dim:field[@element='contributor'][not(@qualifier)]">
                           <xsl:text>; </xsl:text>
                    </xsl:if>
                </xsl:if>

                <xsl:if test="dim:field[@element='contributor'][not(@qualifier)]">
                    <xsl:for-each select="dim:field[@element='contributor'][not(@qualifier)]">
                        <xsl:copy-of select="node()"/>
                            <xsl:if test="count(following-sibling::dim:field[@element='contributor'][not(@qualifier)]) != 0">
                                <xsl:text>; </xsl:text>
                            </xsl:if>
                    </xsl:for-each>
                    <xsl:if test="dim:field[@element='contributor'][@qualifier='other']">
                        <xsl:text>; </xsl:text>
                    </xsl:if>
                </xsl:if>

                <xsl:if test="dim:field[@element='contributor'][@qualifier='other']">
                    <xsl:for-each select="dim:field[@element='contributor'][@qualifier='other']">
                        <xsl:copy-of select="node()"/>
                            <xsl:if test="count(following-sibling::dim:field[@element='contributor'][@qualifier='other']) != 0">
                                <xsl:text>; </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                </xsl:if>
            </div>
            </div>
        </xsl:if>
    </xsl:template>







    <xsl:template name="itemSummaryView-DIM-authors-entry">
        <div>
            <xsl:if test="@authority">
                <xsl:attribute name="class"><xsl:text>ds-dc_contributor_author-authority</xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:copy-of select="node()"/>
        </div>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-HANDLE">
        <xsl:if test="dim:field[@element='identifier' and @qualifier='uri' and descendant::text()]">
            <div class="simple-item-view-uri item-page-field-wrapper table">
                <h5>Handle</h5>
                <span>
                    <xsl:for-each select="dim:field[@element='identifier' and @qualifier='uri']">
                        <xsl:if test="(contains(./node(),'TEMP-BOGUS'))">
                        <a>
                            <xsl:attribute name="href">
                                <xsl:copy-of select="./node()"/>
                            </xsl:attribute>
                            <xsl:copy-of select="./node()"/>
                        </a>
                        <xsl:if test="count(following-sibling::dim:field[@element='identifier' and @qualifier='uri']) != 0">
                            <br/>
                        </xsl:if>
                        </xsl:if>
                    </xsl:for-each>
                </span>
            </div>
        </xsl:if>
    </xsl:template>



    <xsl:template name="itemSummaryView-DIM-URI">

        <xsl:variable name='alluris' select="dim:field[@element='identifier' and @qualifier='uri'][not(contains(.,'TEMP-BOGUS'))]"></xsl:variable>

        <xsl:if test="dim:field[@element='identifier' and @qualifier='uri' and descendant::text()]">
            <div class="simple-item-view-uri item-page-field-wrapper table">

                 <xsl:if test="$alluris">
                    <h5><i18n:text>xmlui.dri2xhtml.METS-1.0.item-uri</i18n:text></h5>
                </xsl:if>
                <span>
                    <xsl:for-each select="$alluris">
                        <a>
                            <xsl:attribute name="href">
                                <xsl:copy-of select="./node()"/>
                            </xsl:attribute>
                            <xsl:copy-of select="./node()"/>
                        </a>
                        <xsl:if test="count(following-sibling::dim:field[@element='identifier' and @qualifier='uri']) != 0">
                            <br/>
                        </xsl:if>
                    </xsl:for-each>
                </span>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-date">
        <xsl:if test="dim:field[@element='date' and @qualifier='issued' and descendant::text()]">
            <div class="simple-item-view-date word-break item-page-field-wrapper table">
                <h5>
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.item-date</i18n:text>
                </h5>
                <xsl:for-each select="dim:field[@element='date' and @qualifier='issued']">
                    <xsl:copy-of select="substring(./node(),1,10)"/>
                    <xsl:if test="count(following-sibling::dim:field[@element='date' and @qualifier='issued']) != 0">
                        <br/>
                    </xsl:if>
                </xsl:for-each>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-date2">
        <xsl:if test="dim:field[@element='date' and @qualifier='issued' and descendant::text()]">
            <div>
                <xsl:for-each select="dim:field[@element='date' and @qualifier='issued']">
                    <xsl:copy-of select="substring(./node(),1,10)"/>
                    <xsl:if test="count(following-sibling::dim:field[@element='date' and @qualifier='issued']) != 0">
                        <br/>
                    </xsl:if>
                </xsl:for-each>
            </div>
        </xsl:if>
    </xsl:template>


    <xsl:template name="itemSummaryView-show-full">
        <div class="simple-item-view-show-full item-page-field-wrapper table">
            <h5>
                <i18n:text>xmlui.mirage2.itemSummaryView.MetaData</i18n:text>
            </h5>
            <a>
                <xsl:attribute name="href"><xsl:value-of select="$ds_item_view_toggle_url"/></xsl:attribute>
                <i18n:text>xmlui.ArtifactBrowser.ItemViewer.show_full</i18n:text>
            </a>
        </div>
    </xsl:template>

    <xsl:template name="itemSummaryView-collections">
        <xsl:if test="$document//dri:referenceSet[@id='aspect.artifactbrowser.ItemViewer.referenceSet.collection-viewer']">
            <div class="simple-item-view-collections item-page-field-wrapper table">
                <h5>
                    <i18n:text>xmlui.mirage2.itemSummaryView.Collections</i18n:text>
                </h5>
                <xsl:apply-templates select="$document//dri:referenceSet[@id='aspect.artifactbrowser.ItemViewer.referenceSet.collection-viewer']/dri:reference"/>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-file-section">

        <xsl:variable name='hathis' select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim/dim:field[@element='description' and @qualifier='hathi']"></xsl:variable>
        <xsl:variable name='fulcrum' select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim/dim:field[@element='description' and @qualifier='fulcrum']"></xsl:variable>

        <xsl:variable name='primaryBitstream' select="/mets:METS/mets:structMap[@TYPE='LOGICAL']/mets:div[@TYPE='DSpace Item']/mets:fptr/@FILEID"></xsl:variable>


        <xsl:choose>
            <xsl:when test="/mets:METS/mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim/dim:field[@element='description' and @qualifier='fulcrum']">
                <xsl:call-template name="fulcrumFileDisplay">
                    <xsl:with-param name="context" select="/mets:METS/mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL']"/>
                    <xsl:with-param name="primaryBitstream" select="/mets:METS/mets:structMap[@TYPE='LOGICAL']/mets:div[@TYPE='DSpace Item']/mets:fptr/@FILEID"/>
                </xsl:call-template>
            </xsl:when>

            <xsl:when test="/mets:METS/mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim/dim:field[@element='description' and @qualifier='hathi']">
                <xsl:call-template name="hathiFileDisplay"/>
            </xsl:when>

            <xsl:otherwise>
            </xsl:otherwise>
        </xsl:choose>


        <xsl:choose>
            <xsl:when test="//mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='LICENSE']/mets:file">
                <div class="item-page-field-wrapper table word-break">
                    <xsl:if test="$tombstone=''">
                        <h5>
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-viewOpen</i18n:text>
                        </h5>
                    </xsl:if>

                    <xsl:variable name="label-1">
                            <xsl:choose>
                                <xsl:when test="confman:getProperty('mirage2.item-view.bitstream.href.label.1')">
                                    <xsl:value-of select="confman:getProperty('mirage2.item-view.bitstream.href.label.1')"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>label</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                    </xsl:variable>

                    <xsl:variable name="label-2">
                            <xsl:choose>
                                <xsl:when test="confman:getProperty('mirage2.item-view.bitstream.href.label.2')">
                                    <xsl:value-of select="confman:getProperty('mirage2.item-view.bitstream.href.label.2')"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>title</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                    </xsl:variable>

                    <xsl:choose>
                      <!-- If one exists and it's of text/html MIME type, only display the primary bitstream -->
                      <xsl:when test="/mets:METS/mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL']/mets:file[@ID=$primaryBitstream]/@MIMETYPE='text/html'">
                        <xsl:if test="$tombstone=''">
                          <xsl:for-each select="//mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='LICENSE']/mets:file">
                            <xsl:if test="@ID=$primaryBitstream">
                              <xsl:call-template name="itemSummaryView-DIM-file-section-entry">
                                <xsl:with-param name="href" select="mets:FLocat[@LOCTYPE='URL']/@xlink:href" />
                                <xsl:with-param name="mimetype" select="@MIMETYPE" />
                                <xsl:with-param name="label-1" select="$label-1" />
                                <xsl:with-param name="label-2" select="$label-2" />
                                <xsl:with-param name="title" select="mets:FLocat[@LOCTYPE='URL']/@xlink:title" />
                                <xsl:with-param name="label" select="mets:FLocat[@LOCTYPE='URL']/@xlink:label" />
                                <xsl:with-param name="size" select="@SIZE" />
                              </xsl:call-template>
                            </xsl:if>
                          </xsl:for-each>
                        </xsl:if>
                     </xsl:when>
                     <!-- Otherwise, iterate over and display all of them -->
                     <xsl:otherwise>
                       <xsl:if test="$tombstone=''">
                          <xsl:for-each select="//mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='LICENSE']/mets:file">
                            <xsl:call-template name="itemSummaryView-DIM-file-section-entry">
                              <xsl:with-param name="href" select="mets:FLocat[@LOCTYPE='URL']/@xlink:href" />
                              <xsl:with-param name="mimetype" select="@MIMETYPE" />
                              <xsl:with-param name="label-1" select="$label-1" />
                              <xsl:with-param name="label-2" select="$label-2" />
                              <xsl:with-param name="title" select="mets:FLocat[@LOCTYPE='URL']/@xlink:title" />
                              <xsl:with-param name="label" select="mets:FLocat[@LOCTYPE='URL']/@xlink:label" />
                              <xsl:with-param name="size" select="@SIZE" />
                            </xsl:call-template>
                          </xsl:for-each>
                       </xsl:if>
                     </xsl:otherwise>
                   </xsl:choose>

                </div>
            </xsl:when>
            <!-- Special case for handling ORE resource maps stored as DSpace bitstreams -->
            <xsl:when test="//mets:fileSec/mets:fileGrp[@USE='ORE']">
                <xsl:apply-templates select="//mets:fileSec/mets:fileGrp[@USE='ORE']" mode="itemSummaryView-DIM" />
            </xsl:when>
        </xsl:choose>

            <xsl:variable name='doi_alt' select="/mets:METS/mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim/dim:field[@element='identifier' and @qualifier='doi']"></xsl:variable>

            <p align="center">
            <span align="center" data-badge-popover="right" data-badge-type="1"   data-hide-less-than="1" class="altmetric-embed" data-style="large_rectangle" >
               <xsl:attribute name="data-handle">
                  <xsl:value-of select="substring-after($handle_alt,':')"/>
               </xsl:attribute>

               <xsl:attribute name="data-doi">
                  <xsl:choose>
                     <xsl:when test="contains($doi_alt, 'http://dx.doi.org/')">
                        <xsl:value-of select="substring-after($doi_alt,'http://dx.doi.org/')"/>
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:value-of select="$doi_alt"/>
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:attribute>
            </span>
            </p>

            <p>
            <span style="margin-left: auto; margin-right: auto; width: 8.5em" class="__dimensions_badge_embed__"  data-hide-zero-citations="true" data-style="large_rectangle"  >
               <xsl:attribute name="data-doi">
                  <xsl:choose>
                     <xsl:when test="contains($doi_alt, 'http://dx.doi.org/')">
                        <xsl:value-of select="substring-after($doi_alt,'http://dx.doi.org/')"/>
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:value-of select="$doi_alt"/>
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:attribute>
            </span>
            </p>


    </xsl:template>


    <xsl:template name="hathiFileDisplay">

    <xsl:variable name='item_title'><xsl:value-of select="/mets:METS/mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim/dim:field[@element='title']"/></xsl:variable>
    <xsl:variable name='full_item_handle'><xsl:value-of select="/mets:METS/mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim/dim:field[@element='identifier' and @qualifier='uri'][contains(.,'TEMP-BOGUS')]"/></xsl:variable>
    <xsl:variable name="item_handle" select="substring( $full_item_handle,23, 1000 )"/>
    <xsl:variable name='owningcollname'><xsl:value-of select="/mets:METS/mets:dmdSec/mets:mdWrap/mets:xmlData/dim:dim/dim:field[@element='owningcollname']"/></xsl:variable>


       <div id="ds-body-file-list">
        <div class="ds-wrapper clearfix">
            <div class="thumbnail-wrapper">
                <a class="image-link">

                  <xsl:variable name='hathis' select="/mets:METS/mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim/dim:field[@element='description' and @qualifier='hathi']"></xsl:variable>
                      <xsl:if test="$hathis">
                        <!-- <span class="bold">File:</span><br/> -->
                        <xsl:for-each select="$hathis">

                          <span>
                <xsl:element name="a">

                            <xsl:attribute name="class">
                              <xsl:text>image-link</xsl:text>
                            </xsl:attribute>

                  <xsl:if test="(contains(./node(),': http'))">
                            <xsl:attribute name="href">
                              <xsl:value-of select="substring-after(./node(),': ')"/>
                            </xsl:attribute>
                </xsl:if>
                 <xsl:if test="not(contains(./node(),': http'))">
                            <xsl:attribute name="href">
                              <xsl:copy-of select="./node()"/>
                            </xsl:attribute>

                </xsl:if>

                    <xsl:attribute name="onclick">
                      <xsl:text>_gaq.push(['_trackEvent', 'HATHI Download', 'Item View','</xsl:text><xsl:value-of select="$owningcollname"/><xsl:text> - </xsl:text><xsl:value-of select="$item_handle"/><xsl:text> - </xsl:text><xsl:value-of select="$item_title"/><xsl:text>']);</xsl:text></xsl:attribute>

                          </xsl:element>
                 <img alt="HathiTrust Viewer" src="{concat($theme-path, '/images_icon/DB-file_format_icons/hathi_trust_icon18x18.png')}" style="height:20px;width:20px;text-decoration:none;" title="HathiTrust Viewer"/>


                <a>

                  <xsl:if test="(contains(./node(),': http'))">
                            <xsl:attribute name="href">
                              <xsl:value-of select="substring-after(./node(),': ')"/>
                            </xsl:attribute>
                    <i18n:text><xsl:value-of select="substring-before(./node(),': ')"/></i18n:text>
                </xsl:if>

                 <xsl:if test="not(contains(./node(),': http'))">

                    <xsl:attribute name="href">
                        <xsl:value-of select="./node()"/>
		</xsl:attribute><xsl:text> </xsl:text>
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-viewOpen</i18n:text>
                </xsl:if>

                </a>
<br/>
              </span>
	      <br/>

                      </xsl:for-each>
                    </xsl:if>
                  </a>
                </div>
              </div>
            </div>

     </xsl:template>



    <xsl:template name="fulcrumFileDisplay">
        <xsl:param name="context"/>
        <xsl:param name="primaryBitstream" select="-1"/>

    <xsl:variable name='item_title'><xsl:value-of select="/mets:METS/mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim/dim:field[@element='title']"/></xsl:variable>
    <xsl:variable name='full_item_handle'><xsl:value-of select="/mets:METS/mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim/dim:field[@element='identifier' and @qualifier='uri'][contains(.,'TEMP-BOGUS')]"/></xsl:variable>
    <xsl:variable name="item_handle" select="substring( $full_item_handle,23, 1000 )"/>
    <xsl:variable name='owningcollname'><xsl:value-of select="/mets:METS/mets:dmdSec/mets:mdWrap/mets:xmlData/dim:dim/dim:field[@element='owningcollname']"/></xsl:variable>

       <div id="ds-body-file-list">
        <div class="ds-wrapper clearfix">
            <div class="thumbnail-wrapper">
                <a class="image-link">

                  <xsl:variable name='fulcrum' select="/mets:METS/mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim/dim:field[@element='description' and @qualifier='fulcrum']"></xsl:variable>
                      <xsl:if test="$fulcrum">
                        <!-- <span class="bold">File:</span><br/> -->
                        <xsl:for-each select="$fulcrum">

                          <span>
                <xsl:element name="a">

                            <xsl:attribute name="class">
                              <xsl:text>image-link</xsl:text>
                            </xsl:attribute>

                  <xsl:if test="(contains(./node(),': http'))">
                            <xsl:attribute name="href">
                              <xsl:value-of select="substring-after(./node(),': ')"/>
                            </xsl:attribute>
                </xsl:if>
                 <xsl:if test="not(contains(./node(),': http'))">
                            <xsl:attribute name="href">
                              <xsl:copy-of select="./node()"/>
                            </xsl:attribute>

                </xsl:if>

                    <xsl:attribute name="onclick">
                      <xsl:text>_gaq.push(['_trackEvent', 'FULCRUM Download', 'Item View','</xsl:text><xsl:value-of select="$owningcollname"/><xsl:text> - </xsl:text><xsl:value-of select="$item_handle"/><xsl:text> - </xsl:text><xsl:value-of select="$item_title"/><xsl:text>']);</xsl:text></xsl:attribute>

                          </xsl:element>
                 <img alt="Fulcrum Viewer" src="{concat($theme-path, '/images_icon/DB-file_format_icons/fulcrum_icon.png')}" style="height:20px;width:20px;text-decoration:none;" title="Fulcrum Viewer"/>


<xsl:text>&#160;&#160;&#160;</xsl:text>

                <a>

                  <xsl:if test="(contains(./node(),': http'))">
                            <xsl:attribute name="href">
                              <xsl:value-of select="substring-after(./node(),': ')"/>
                            </xsl:attribute>
                    <i18n:text><xsl:value-of select="substring-before(./node(),': ')"/></i18n:text>
                </xsl:if>

                 <xsl:if test="not(contains(./node(),': http'))">

                    <xsl:attribute name="href">
                        <xsl:value-of select="./node()"/>
                    </xsl:attribute>
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-viewOpen</i18n:text>
                </xsl:if>

                </a>
<br/>
              </span>
<p></p>
<p></p>
                      </xsl:for-each>
                    </xsl:if>
                  </a>
                </div>
</div>              </div>

     </xsl:template>



    <xsl:template name="itemSummaryView-DIM-file-section-entry">
        <xsl:param name="href" />
        <xsl:param name="mimetype" />
        <xsl:param name="label-1" />
        <xsl:param name="label-2" />
        <xsl:param name="title" />
        <xsl:param name="label" />
        <xsl:param name="size" />
        <div>
            <xsl:call-template name="getFileIcon2">
                 <xsl:with-param name="mimetype">
                     <xsl:value-of select="substring-before($mimetype,'/')"/>
                     <xsl:text>/</xsl:text>
                     <xsl:value-of select="substring-after($mimetype,'/')"/>
                 </xsl:with-param>
            </xsl:call-template>

            <a>
                <xsl:attribute name="href">
                    <xsl:value-of select="$href"/>
                </xsl:attribute>
                <xsl:choose>
                    <xsl:when test="contains($label-1, 'label') and string-length($label)!=0">
                        <xsl:value-of select="$label"/>
                    </xsl:when>
                    <xsl:when test="contains($label-1, 'title') and string-length($title)!=0">
                        <xsl:value-of select="$title"/>
                    </xsl:when>
                    <xsl:when test="contains($label-2, 'label') and string-length($label)!=0">
                        <xsl:value-of select="$label"/>
                    </xsl:when>
                    <xsl:when test="contains($label-2, 'title') and string-length($title)!=0">
                        <xsl:value-of select="$title"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="getFileTypeDesc">
                            <xsl:with-param name="mimetype">
                                <xsl:value-of select="substring-before($mimetype,'/')"/>
                                <xsl:text>/</xsl:text>
                                <xsl:choose>
                                    <xsl:when test="contains($mimetype,';')">
                                        <xsl:value-of select="substring-before(substring-after($mimetype,'/'),';')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="substring-after($mimetype,'/')"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text> (</xsl:text>
                <xsl:choose>
                    <xsl:when test="$size &lt; 1024">
                        <xsl:value-of select="$size"/>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.size-bytes</i18n:text>
                    </xsl:when>
                    <xsl:when test="$size &lt; 1024 * 1024">
                        <xsl:value-of select="substring(string($size div 1024),1,5)"/>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.size-kilobytes</i18n:text>
                    </xsl:when>
                    <xsl:when test="$size &lt; 1024 * 1024 * 1024">
                        <xsl:value-of select="substring(string($size div (1024 * 1024)),1,5)"/>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.size-megabytes</i18n:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="substring(string($size div (1024 * 1024 * 1024)),1,5)"/>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.size-gigabytes</i18n:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>)</xsl:text>
             </a>
               <br/>         <xsl:value-of select="$label"/>
        </div>
	<br/>

    </xsl:template>

    <xsl:template match="dim:dim" mode="itemDetailView-DIM">
        <xsl:call-template name="itemSummaryView-DIM-title"/>
        <div class="ds-table-responsive">
            <table class="ds-includeSet-table detailtable table table-striped table-hover">
                <xsl:apply-templates mode="itemDetailView-DIM"/>
            </table>
        </div>

        <span class="Z3988">
            <xsl:attribute name="title">
                 <xsl:call-template name="renderCOinS"/>
            </xsl:attribute>
            &#xFEFF; <!-- non-breaking space to force separating the end tag -->
        </span>
        <xsl:copy-of select="$SFXLink" />
    </xsl:template>

    <xsl:template match="dim:field" mode="itemDetailView-DIM">
            <tr>
                <xsl:attribute name="class">
                    <xsl:text>ds-table-row </xsl:text>
                    <xsl:if test="(position() div 2 mod 2 = 0)">even </xsl:if>
                    <xsl:if test="(position() div 2 mod 2 = 1)">odd </xsl:if>
                </xsl:attribute>
                <td class="label-cell">
                    <xsl:value-of select="./@mdschema"/>
                    <xsl:text>.</xsl:text>
                    <xsl:value-of select="./@element"/>
                    <xsl:if test="./@qualifier">
                        <xsl:text>.</xsl:text>
                        <xsl:value-of select="./@qualifier"/>
                    </xsl:if>
                </td>
            <td class="word-break">
              <xsl:copy-of select="./node()"/>
            </td>
                <td><xsl:value-of select="./@language"/></td>
            </tr>
    </xsl:template>

    <!-- don't render the item-view-toggle automatically in the summary view, only when it gets called -->
    <xsl:template match="dri:p[contains(@rend , 'item-view-toggle') and
        (preceding-sibling::dri:referenceSet[@type = 'summaryView'] or following-sibling::dri:referenceSet[@type = 'summaryView'])]">
    </xsl:template>

    <!-- don't render the head on the item view page -->
    <xsl:template match="dri:div[@n='item-view']/dri:head" priority="5">
    </xsl:template>

   <xsl:template match="mets:fileGrp[@USE='CONTENT']">
        <xsl:param name="context"/>
	<xsl:param name="primaryBitstream" select="-1"/>
            <xsl:choose>
                <!-- If one exists and it's of text/html MIME type, only display the primary bitstream -->
                <xsl:when test="mets:file[@ID=$primaryBitstream]/@MIMETYPE='text/html'">
                    <xsl:apply-templates select="mets:file[@ID=$primaryBitstream]">
                        <xsl:with-param name="context" select="$context"/>
                    </xsl:apply-templates>
                </xsl:when>
                <!-- Otherwise, iterate over and display all of them -->
                <xsl:otherwise>
                    <xsl:apply-templates select="mets:file">
                     	<!--Do not sort any more bitstream order can be changed-->
                        <xsl:with-param name="context" select="$context"/>
                    </xsl:apply-templates>
                </xsl:otherwise>
            </xsl:choose>
    </xsl:template>

   <xsl:template match="mets:fileGrp[@USE='LICENSE']">
        <xsl:param name="context"/>
        <xsl:param name="primaryBitstream" select="-1"/>
            <xsl:apply-templates select="mets:file">
                        <xsl:with-param name="context" select="$context"/>
            </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="mets:file">
        <xsl:param name="context" select="."/>
        <div class="file-wrapper row">
            <div class="col-xs-6 col-sm-3">
                <div class="thumbnail">
                    <a class="image-link">
                        <xsl:attribute name="href">
                            <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                        </xsl:attribute>
                        <xsl:choose>
                            <xsl:when test="$context/mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/
                        mets:file[@GROUPID=current()/@GROUPID]">
                                <img class="img-thumbnail" alt="Thumbnail">
                                    <xsl:attribute name="src">
                                        <xsl:value-of select="$context/mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/
                                    mets:file[@GROUPID=current()/@GROUPID]/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                                    </xsl:attribute>
                                </img>
                            </xsl:when>
                            <xsl:otherwise>
                                <img class="img-thumbnail" alt="Thumbnail">
                                    <xsl:attribute name="data-src">
                                        <xsl:text>holder.js/100%x</xsl:text>
                                        <xsl:value-of select="$thumbnail.maxheight"/>
                                        <xsl:text>/text:No Thumbnail</xsl:text>
                                    </xsl:attribute>
                                </img>
                            </xsl:otherwise>
                        </xsl:choose>
                    </a>
                </div>
            </div>

            <div class="col-xs-6 col-sm-7">
                <dl class="file-metadata dl-horizontal">
                    <dt>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-name</i18n:text>
                        <xsl:text>:</xsl:text>
                    </dt>
                    <dd class="word-break">
                        <xsl:attribute name="title">
                            <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:title"/>
                        </xsl:attribute>
                        <xsl:value-of select="util:shortenString(mets:FLocat[@LOCTYPE='URL']/@xlink:title, 30, 5)"/>
                    </dd>
                <!-- File size always comes in bytes and thus needs conversion -->
                    <dt>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-size</i18n:text>
                        <xsl:text>:</xsl:text>
                    </dt>
                    <dd class="word-break">
                        <xsl:choose>
                            <xsl:when test="@SIZE &lt; 1024">
                                <xsl:value-of select="@SIZE"/>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-bytes</i18n:text>
                            </xsl:when>
                            <xsl:when test="@SIZE &lt; 1024 * 1024">
                                <xsl:value-of select="substring(string(@SIZE div 1024),1,5)"/>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-kilobytes</i18n:text>
                            </xsl:when>
                            <xsl:when test="@SIZE &lt; 1024 * 1024 * 1024">
                                <xsl:value-of select="substring(string(@SIZE div (1024 * 1024)),1,5)"/>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-megabytes</i18n:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="substring(string(@SIZE div (1024 * 1024 * 1024)),1,5)"/>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-gigabytes</i18n:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </dd>
                <!-- Lookup File Type description in local messages.xml based on MIME Type.
         In the original DSpace, this would get resolved to an application via
         the Bitstream Registry, but we are constrained by the capabilities of METS
         and can't really pass that info through. -->
                    <dt>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-format</i18n:text>
                        <xsl:text>:</xsl:text>
                    </dt>
                    <dd class="word-break">
                        <xsl:call-template name="getFileTypeDesc">
                            <xsl:with-param name="mimetype">
                                <xsl:value-of select="substring-before(@MIMETYPE,'/')"/>
                                <xsl:text>/</xsl:text>
                                <xsl:choose>
                                    <xsl:when test="contains(@MIMETYPE,';')">
                                <xsl:value-of select="substring-before(substring-after(@MIMETYPE,'/'),';')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="substring-after(@MIMETYPE,'/')"/>
                                    </xsl:otherwise>
                                </xsl:choose>

                            </xsl:with-param>
                        </xsl:call-template>
                    </dd>
                <!-- Display the contents of 'Description' only if bitstream contains a description -->
                <xsl:if test="mets:FLocat[@LOCTYPE='URL']/@xlink:label != ''">
                        <dt>
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-description</i18n:text>
                            <xsl:text>:</xsl:text>
                        </dt>
                        <dd class="word-break">
                            <xsl:attribute name="title">
                                <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:label"/>
                            </xsl:attribute>
                            <xsl:value-of select="util:shortenString(mets:FLocat[@LOCTYPE='URL']/@xlink:label, 30, 5)"/>
                        </dd>
                </xsl:if>
                </dl>
            </div>

            <div class="file-link col-xs-6 col-xs-offset-6 col-sm-2 col-sm-offset-0">
                <xsl:choose>
                    <xsl:when test="@ADMID">
                        <xsl:call-template name="display-rights"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="view-open"/>
                    </xsl:otherwise>
                </xsl:choose>
            </div>
        </div>

</xsl:template>

    <xsl:template name="view-open">
        <a>
            <xsl:attribute name="href">
                <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
            </xsl:attribute>
            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-viewOpen</i18n:text>
        </a>
    </xsl:template>

    <xsl:template name="display-rights">
        <xsl:variable name="file_id" select="jstring:replaceAll(jstring:replaceAll(string(@ADMID), '_METSRIGHTS', ''), 'rightsMD_', '')"/>
        <xsl:variable name="rights_declaration" select="../../../mets:amdSec/mets:rightsMD[@ID = concat('rightsMD_', $file_id, '_METSRIGHTS')]/mets:mdWrap/mets:xmlData/rights:RightsDeclarationMD"/>
        <xsl:variable name="rights_context" select="$rights_declaration/rights:Context"/>
        <xsl:variable name="users">
            <xsl:for-each select="$rights_declaration/*">
                <xsl:value-of select="rights:UserName"/>
                <xsl:choose>
                    <xsl:when test="rights:UserName/@USERTYPE = 'GROUP'">
                       <xsl:text> (group)</xsl:text>
                    </xsl:when>
                    <xsl:when test="rights:UserName/@USERTYPE = 'INDIVIDUAL'">
                       <xsl:text> (individual)</xsl:text>
                    </xsl:when>
                </xsl:choose>
                <xsl:if test="position() != last()">, </xsl:if>
            </xsl:for-each>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="not ($rights_context/@CONTEXTCLASS = 'GENERAL PUBLIC') and ($rights_context/rights:Permissions/@DISPLAY = 'true')">
                <a href="{mets:FLocat[@LOCTYPE='URL']/@xlink:href}">
                    <img width="64" height="64" src="{concat($theme-path,'/images/Crystal_Clear_action_lock3_64px.png')}" title="Read access available for {$users}"/>
                    <!-- icon source: http://commons.wikimedia.org/wiki/File:Crystal_Clear_action_lock3.png -->
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="view-open"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="getFileIcon">
        <xsl:param name="mimetype"/>
            <i aria-hidden="true">
                <xsl:attribute name="class">
                <xsl:text>glyphicon </xsl:text>
                <xsl:choose>
                    <xsl:when test="contains(mets:FLocat[@LOCTYPE='URL']/@xlink:href,'isAllowed=n')">
                        <xsl:text> glyphicon-lock</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text> glyphicon-file</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                </xsl:attribute>
            </i>
        <xsl:text> </xsl:text>
    </xsl:template>


    <xsl:template name="getFileIcon2">
        <xsl:param name="mimetype"/>

        <xsl:variable name='full_item_handle'><xsl:value-of select="/mets:METS/mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim/dim:field[@element='identifier' and @qualifier='uri'][contains(.,'TEMP-BOGUS')]"/></xsl:variable>

        <xsl:variable name="item_handle" select="substring( $full_item_handle,23, 1000 )"/>


        <xsl:variable name='item_title'><xsl:value-of select="/mets:METS/mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim/dim:field[@element='title']"/></xsl:variable>

        <xsl:variable name='owningcollname'><xsl:value-of select="/mets:METS/mets:dmdSec/mets:mdWrap/mets:xmlData/dim:dim/dim:field[@element='owningcollname']"/></xsl:variable>


<xsl:variable name="smallcase" select="'abcdefghijklmnopqrstuvwxyz'" />
<xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />

    <xsl:variable name='full_item_handle'><xsl:value-of select="/mets:METS/mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim/dim:field[@element='identifier' and @qualifier='uri'][contains(.,'TEMP-BOGUS')]"/></xsl:variable>

   <xsl:variable name="item_handle" select="substring( $full_item_handle,23, 1000 )"/>

    <xsl:variable name='owningcollname'><xsl:value-of select="/mets:METS/mets:dmdSec/mets:mdWrap/mets:xmlData/dim:dim/dim:field[@element='owningcollname']"/></xsl:variable>

    <xsl:variable name="UMRestrictedMsg">
      <xsl:if test="mets:FLocat[contains(translate(@xlink:href, $smallcase,$uppercase), translate('isAllowed=n',$smallcase,$uppercase))]">
        <xsl:value-of select="123" />
      </xsl:if>
    </xsl:variable>

    <xsl:variable name="UMRestricted">
      <xsl:if test="mets:FLocat[contains(translate(@xlink:label,$smallcase,$uppercase), translate('restricted to U',$smallcase,$uppercase))]">
        <xsl:value-of select="123" />
      </xsl:if>
    </xsl:variable>

    <xsl:variable name="BioRestricted">
      <xsl:if test="mets:FLocat[contains(translate(@xlink:label,$smallcase,$uppercase), translate('Access restricted to on-site users at the U-M Biological Station',$smallcase,$uppercase))]">
        <xsl:value-of select="123" />
      </xsl:if>
    </xsl:variable>

    <xsl:variable name="BentleyRestricted">
      <xsl:if test="mets:FLocat[contains(@xlink:label, 'Access restricted to Bentley')]">
        <xsl:value-of select="123" />
      </xsl:if>
    </xsl:variable>

<xsl:if test="$requestcopy!='active'">

<xsl:if test ="$UMRestricted != '' ">
  <img alt="Restricted to current U-M faculty, staff, and students" src="{concat($theme-path, '/images_icon/DB-file_format_icons/u-m_campus_only_access_icon.png')}" style="height:20px;width:20px;text-decoration:none;" title="Restricted to current U-M faculty, staff, and students"/>
</xsl:if>


<xsl:if test ="$BioRestricted != '' ">
  <img alt="Restricted to on-site access at Biological Station" src="{concat($theme-path, '/images_icon/DB-file_format_icons/u-m_campus_only_access_icon.png')}" style="height:20px;width:20px;text-decoration:none;" title="Restricted to on-site access at Biological Station"/>
</xsl:if>

<xsl:if test ="$BentleyRestricted != '' ">
  <img alt="Restricted to on-site access at Bentley Historical Library" src="{concat($theme-path, '/images_icon/DB-file_format_icons/u-m_campus_only_access_icon.png')}" style="height:20px;width:20px;text-decoration:none;" title="Restricted to on-site access at Bentley Historical Library"/>
</xsl:if>


<xsl:if test ="$UMRestricted != '123' and $BioRestricted != '123' and $BentleyRestricted != '123' and $UMRestrictedMsg = '123' ">
  <img alt="Restricted to current U-M faculty, staff, and students" src="{concat($theme-path, '/images_icon/DB-file_format_icons/u-m_campus_only_access_icon.png')}" style="height:20px;width:20px;text-decoration:none;" title="Restricted to current U-M faculty, staff, and students"/>
</xsl:if>

</xsl:if>

<xsl:if test="$requestcopy='active'">
<img alt="Request Copy" src="{concat($theme-path, '/images/lock.gif')}" style="height:20px;width:20px;text-decoration:none;" title="Request Copy"/>
</xsl:if>

              <xsl:choose>
                <xsl:when test="$mimetype='application/pdf'">

                <a>
                    <xsl:attribute name="class">
                      <xsl:text>image-link</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="href">
                      <xsl:value-of select="mets:FLocat/@xlink:href"/>
                    </xsl:attribute>

                    <xsl:attribute name="onclick">
                      <xsl:text>_gaq.push(['_trackEvent', 'PDF Download', 'Item View','</xsl:text><xsl:value-of select="$owningcollname"/><xsl:text> - </xsl:text><xsl:value-of select="$item_handle"/><xsl:text> - </xsl:text><xsl:value-of select="$item_title"/><xsl:text>']);</xsl:text></xsl:attribute>

	      <img alt="PDF file" src="{concat($theme-path, '/images_icon/DB-file_format_icons/pdf_icon-18x18.png')}" style="text-decoration:none;height:20px;width:20px;text-decoration:none;" title="PDF file"/>
	        </a>
                </xsl:when>

                <xsl:when test="$mimetype='text/plain'">
                <a>
                    <xsl:attribute name="class">
                      <xsl:text>image-link</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="href">
                      <xsl:value-of select="mets:FLocat/@xlink:href"/>

                    </xsl:attribute>
		    <img alt="TXT file" src="{concat($theme-path, '/images_icon/DB-file_format_icons/text_icon-18x18.png')}" style="height:20px;width:20px;text-decoration:none;" title="TXT file"/>
	    </a>
                </xsl:when>

              <xsl:when test="$mimetype='application/msword'">
                <a>
                    <xsl:attribute name="class">
                      <xsl:text>image-link</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="href">
                      <xsl:value-of select="mets:FLocat/@xlink:href"/>
                    </xsl:attribute>


                    <xsl:attribute name="onclick">
                      <xsl:text>_gaq.push(['_trackEvent', 'MSWord Download', 'Item View','</xsl:text><xsl:value-of select="$owningcollname"/><xsl:text> - </xsl:text><xsl:value-of select="$item_handle"/><xsl:text> - </xsl:text><xsl:value-of select="$item_title"/><xsl:text>']);</xsl:text></xsl:attribute>

	      <img alt="MS Word file" src="{concat($theme-path, '/images_icon/DB-file_format_icons/word_icon-18x18.png')}" style="height:20px;width:20px;text-decoration:none;" title="MS Word file"/>
	        </a>
                </xsl:when>


              <xsl:when test="$mimetype='application/vnd.ms-powerpoint'">
                <a>
                    <xsl:attribute name="class">
                      <xsl:text>image-link</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="href">
                      <xsl:value-of select="mets:FLocat/@xlink:href"/>
                    </xsl:attribute>

                    <xsl:attribute name="onclick">
                      <xsl:text>_gaq.push(['_trackEvent', 'MSPowerPoint Download', 'Item View','</xsl:text><xsl:value-of select="$owningcollname"/><xsl:text> - </xsl:text><xsl:value-of select="$item_handle"/><xsl:text> - </xsl:text><xsl:value-of select="$item_title"/><xsl:text>']);</xsl:text></xsl:attribute>

	      <img alt="MS PowerPoint file" src="{concat($theme-path, '/images_icon/DB-file_format_icons/powerpoint_icon-18x18.png')}" style="height:20px;width:20px;text-decoration:none;" title="MS PowerPoint file"/>
      </a>
                </xsl:when>

              <xsl:when test="$mimetype='application/vnd.ms-excel'">
                <a>
                    <xsl:attribute name="class">
                      <xsl:text>image-link</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="href">
                      <xsl:value-of select="mets:FLocat/@xlink:href"/>
                    </xsl:attribute>

                    <xsl:attribute name="onclick">
                      <xsl:text>_gaq.push(['_trackEvent', 'MSExcel Download', 'Item View','</xsl:text><xsl:value-of select="$owningcollname"/><xsl:text> - </xsl:text><xsl:value-of select="$item_handle"/><xsl:text> - </xsl:text><xsl:value-of select="$item_title"/><xsl:text>']);</xsl:text></xsl:attribute>

	      <img alt="MS Excel file" src="{concat($theme-path, '/images_icon/DB-file_format_icons/excel_icon-18x18.png')}" style="height:20px;width:20px;text-decoration:none;" title="MS Excel file"/>
      </a>
                </xsl:when>


                <xsl:when test="$mimetype='image/jpeg'">
                <a>
                    <xsl:attribute name="class">
                      <xsl:text>image-link</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="href">
                      <xsl:value-of select="mets:FLocat/@xlink:href"/>
                    </xsl:attribute>

                    <xsl:attribute name="onclick">
                      <xsl:text>_gaq.push(['_trackEvent', 'JPEG Download', 'Item View','</xsl:text><xsl:value-of select="$owningcollname"/><xsl:text> - </xsl:text><xsl:value-of select="$item_handle"/><xsl:text> - </xsl:text><xsl:value-of select="$item_title"/><xsl:text>']);</xsl:text></xsl:attribute>

	      <img alt="JPEG file" src="{concat($theme-path, '/images_icon/DB-file_format_icons/jpeg_icon-18x18.png')}" style="height:20px;width:20px;text-decoration:none;" title="JPEG file"/>
      </a>
                </xsl:when>

                <xsl:when test="$mimetype='image/tiff'">
                <a>
                    <xsl:attribute name="class">
                      <xsl:text>image-link</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="href">
                      <xsl:value-of select="mets:FLocat/@xlink:href"/>
                    </xsl:attribute>

                    <xsl:attribute name="onclick">
                      <xsl:text>_gaq.push(['_trackEvent', 'TIFF Download', 'Item View','</xsl:text><xsl:value-of select="$owningcollname"/><xsl:text> - </xsl:text><xsl:value-of select="$item_handle"/><xsl:text> - </xsl:text><xsl:value-of select="$item_title"/><xsl:text>']);</xsl:text></xsl:attribute>

	      <img alt="TIFF file" src="{concat($theme-path, '/images_icon/DB-file_format_icons/tiff_icon-18x18.png')}" style="height:20px;width:20px;text-decoration:none;" title="TIFF file"/>
      </a>
                </xsl:when>


                <xsl:when test="$mimetype='image/gif' or @MIMETYPE='image/png' or @MIMETYPE='image/jp2'or @MIMETYPE='image/x-photo-cd'">
		<a>
                    <xsl:attribute name="class">
                      <xsl:text>image-link</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="href">
                      <xsl:value-of select="mets:FLocat/@xlink:href"/>
                    </xsl:attribute>

                    <xsl:attribute name="onclick">
                      <xsl:text>_gaq.push(['_trackEvent', 'IMAGE Download', 'Item View','</xsl:text><xsl:value-of select="$owningcollname"/><xsl:text> - </xsl:text><xsl:value-of select="$item_handle"/><xsl:text> - </xsl:text><xsl:value-of select="$item_title"/><xsl:text>']);</xsl:text></xsl:attribute>

	      <img alt="Image file" src="{concat($theme-path, '/images_icon/DB-file_format_icons/generic_image_icon-18x18.png')}" style="height:20px;width:20px;text-decoration:none;" title="Image file"/>
      </a>
                </xsl:when>


                <xsl:when test="$mimetype='video/mpeg' or @MIMETYPE='video/quicktime'">
                <a>
                    <xsl:attribute name="class">
                      <xsl:text>image-link</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="href">
                      <xsl:value-of select="mets:FLocat/@xlink:href"/>
                    </xsl:attribute>

                    <xsl:attribute name="onclick">
                      <xsl:text>_gaq.push(['_trackEvent', 'VIDEO Download', 'Item View','</xsl:text><xsl:value-of select="$owningcollname"/><xsl:text> - </xsl:text><xsl:value-of select="$item_handle"/><xsl:text> - </xsl:text><xsl:value-of select="$item_title"/><xsl:text>']);</xsl:text></xsl:attribute>

	      <img alt="Video file" src="{concat($theme-path, '/images_icon/DB-file_format_icons/video_icon18x18.png')}" style="height:20px;width:20px;text-decoration:none;" title="Vidoe file"/>
      </a>
                </xsl:when>


                <xsl:when test="$mimetype='audio/x-aiff' or @MIMETYPE='audio/basic' or @MIMETYPE='audio/x-wav' or @MIMETYPE='audio/x-mpeg' or @MIMETYPE='audio/x-pn-realaudio' or @MIMETYPE='audio/mp3' or @MIMETYPE='audio/mp4a-latm'">
                <a>
                    <xsl:attribute name="class">
                      <xsl:text>image-link</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="href">
                      <xsl:value-of select="mets:FLocat/@xlink:href"/>
                    </xsl:attribute>

                    <xsl:attribute name="onclick">
                      <xsl:text>_gaq.push(['_trackEvent', 'AUDIO Download', 'Item View','</xsl:text><xsl:value-of select="$owningcollname"/><xsl:text> - </xsl:text><xsl:value-of select="$item_handle"/><xsl:text> - </xsl:text><xsl:value-of select="$item_title"/><xsl:text>']);</xsl:text></xsl:attribute>

	      <img alt="Audio file" src="{concat($theme-path, '/images_icon/DB-file_format_icons/audio_icon18x18.png')}" style="height:20px;width:20px;text-decoration:none;" title="Audio file"/>
      </a>
                </xsl:when>


                <xsl:when test="$mimetype='application/zip'">
                <a>
                    <xsl:attribute name="class">
                      <xsl:text>image-link</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="href">
                      <xsl:value-of select="mets:FLocat/@xlink:href"/>
                    </xsl:attribute>

                    <xsl:attribute name="onclick">
                      <xsl:text>_gaq.push(['_trackEvent', 'ZIP Download', 'Item View','</xsl:text><xsl:value-of select="$owningcollname"/><xsl:text> - </xsl:text><xsl:value-of select="$item_handle"/><xsl:text> - </xsl:text><xsl:value-of select="$item_title"/><xsl:text>']);</xsl:text></xsl:attribute>

	      <img alt="Zip file" src="{concat($theme-path, '/images_icon/DB-file_format_icons/zip_icon-18x18.png')}" style="height:20px;width:20px;text-decoration:none;" title="Zip file"/>
      </a>
                </xsl:when>


                <xsl:when test="$mimetype='hidden'">

                </xsl:when>


                <xsl:when test="$mimetype='text/html'">
                <a>
                    <xsl:attribute name="class">
                      <xsl:text>image-link</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="href">
                      <xsl:value-of select="mets:FLocat/@xlink:href"/>
                    </xsl:attribute>

                    <xsl:attribute name="onclick">
                      <xsl:text>_gaq.push(['_trackEvent', 'HTML Download', 'Item View','</xsl:text><xsl:value-of select="$owningcollname"/><xsl:text> - </xsl:text><xsl:value-of select="$item_handle"/><xsl:text> - </xsl:text><xsl:value-of select="$item_title"/><xsl:text>']);</xsl:text></xsl:attribute>

	      <img alt="HTML" src="{concat($theme-path, '/images_icon/DB-file_format_icons/html_icon-18x18.PNG')}" style="height:20px;width:20px;text-decoration:none;" title="HTML"/>
      </a>

                </xsl:when>


                <xsl:otherwise>
                <a>
                    <xsl:attribute name="class">
                      <xsl:text>image-link</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="href">
                      <xsl:value-of select="mets:FLocat/@xlink:href"/>
                    </xsl:attribute>

                    <xsl:attribute name="onclick">
                      <xsl:text>_gaq.push(['_trackEvent', 'OTHER Download', 'Item View','</xsl:text><xsl:value-of select="$owningcollname"/><xsl:text> - </xsl:text><xsl:value-of select="$item_handle"/><xsl:text> - </xsl:text><xsl:value-of select="$item_title"/><xsl:text>']);</xsl:text></xsl:attribute>

                      <img alt="Unidentified file format" src="{concat($theme-path, '/images_icon/DB-file_format_icons/generic_bitstream18x18.png')}" style="height:20px;width:20px;text-decoration:none;" title="Unidentified file format"/>
                </a>
                </xsl:otherwise>

              </xsl:choose>


    </xsl:template>

    <!-- Generate the license information from the file section -->
    <xsl:template match="mets:fileGrp[@USE='CC-LICENSE']" mode="simple">
        <li><a href="{mets:file/mets:FLocat[@xlink:title='license_text']/@xlink:href}"><i18n:text>xmlui.dri2xhtml.structural.link_cc</i18n:text></a></li>
    </xsl:template>

    <!-- Generate the license information from the file section -->
    <xsl:template match="mets:fileGrp[@USE='LICENSE']" mode="simple">
        <li><a href="{mets:file/mets:FLocat[@xlink:title='license.txt']/@xlink:href}"><i18n:text>xmlui.dri2xhtml.structural.link_original_license</i18n:text></a></li>
    </xsl:template>

    <!--
    File Type Mapping template

    This maps format MIME Types to human friendly File Type descriptions.
    Essentially, it looks for a corresponding 'key' in your messages.xml of this
    format: xmlui.dri2xhtml.mimetype.{MIME Type}

    (e.g.) <message key="xmlui.dri2xhtml.mimetype.application/pdf">PDF</message>

    If a key is found, the translated value is displayed as the File Type (e.g. PDF)
    If a key is NOT found, the MIME Type is displayed by default (e.g. application/pdf)
    -->
    <xsl:template name="getFileTypeDesc">
        <xsl:param name="mimetype"/>

        <!--Build full key name for MIME type (format: xmlui.dri2xhtml.mimetype.{MIME type})-->
        <xsl:variable name="mimetype-key">xmlui.dri2xhtml.mimetype.<xsl:value-of select='$mimetype'/></xsl:variable>

        <!--Lookup the MIME Type's key in messages.xml language file.  If not found, just display MIME Type-->
        <i18n:text i18n:key="{$mimetype-key}"><xsl:value-of select="$mimetype"/></i18n:text>
    </xsl:template>


</xsl:stylesheet>

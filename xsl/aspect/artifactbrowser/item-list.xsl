<!--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

-->
<!--
    Rendering of a list of items (e.g. in a search or
    browse results page)

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
    xmlns:confman="org.dspace.core.ConfigurationManager"
    exclude-result-prefixes="xalan encoder i18n dri mets dim xlink xsl util confman">

    <xsl:output indent="yes"/>
<xsl:decimal-format name="num"/>
    <!--these templates are modfied to support the 2 different item list views that
    can be configured with the property 'xmlui.theme.mirage.item-list.emphasis' in dspace.cfg-->

    <xsl:template name="itemSummaryList-DIM">
        <xsl:variable name="itemWithdrawn" select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim/@withdrawn" />


        <xsl:variable name="href">
            <xsl:choose>
                <xsl:when test="$itemWithdrawn">
                    <xsl:value-of select="@OBJEDIT"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="@OBJID"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="emphasis" select="confman:getProperty('xmlui.theme.mirage.item-list.emphasis')"/>
        <xsl:choose>
            <xsl:when test="'file' = $emphasis">


                <div class="item-wrapper clearfix">

                <xsl:apply-templates select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim"
                                     mode="itemSummaryList-DIM-metadata"><xsl:with-param name="href" select="$href"/></xsl:apply-templates>

                <xsl:apply-templates select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim" mode="artifact-preview3"><xsl:with-param name="href" select="$href"/></xsl:apply-templates>


		<xsl:apply-templates select="./mets:fileSec" mode="artifact-preview2"><xsl:with-param name="href" select="$href"/></xsl:apply-templates>
	</div>
	<br/>
            </xsl:when>
            <xsl:otherwise>

                <xsl:apply-templates select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim"
                                     mode="itemSummaryList-DIM-metadata"><xsl:with-param name="href" select="$href"/></xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--handles the rendering of a single item in a list in file mode-->
    <xsl:template match="dim:dim" mode="itemSummaryList-DIM-file">
        <xsl:param name="href"/>
        <xsl:variable name="metadataWidth" select="675 - $thumbnail.maxwidth - 30"/>
        <div class="item-metadata" style="width: {$metadataWidth}px;">
            <span class="bold"><i18n:text>xmlui.dri2xhtml.pioneer.title</i18n:text><xsl:text>:</xsl:text></span>
            <span class="content" style="width: {$metadataWidth - 110}px;">
                <xsl:element name="a">
                    <xsl:attribute name="href">
                        <xsl:value-of select="$href"/>
                    </xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="dim:field[@element='title']">
                            <xsl:value-of select="dim:field[@element='title'][1]/node()"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.no-title</i18n:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:element>
            </span>
            <span class="Z3988">
                <xsl:attribute name="title">
                    <xsl:call-template name="renderCOinS"/>
                </xsl:attribute>
                &#xFEFF; <!-- non-breaking space to force separating the end tag -->
            </span>
            <span class="bold"><i18n:text>xmlui.dri2xhtml.pioneer.author</i18n:text><xsl:text>:</xsl:text></span>
            <span class="content" style="width: {$metadataWidth - 110}px;">
                <xsl:choose>
                    <xsl:when test="dim:field[@element='contributor'][@qualifier='author']">
                        <xsl:for-each select="dim:field[@element='contributor'][@qualifier='author']">
                            <span>
                                <xsl:if test="@authority">
                                    <xsl:attribute name="class">
                                        <xsl:text>ds-dc_contributor_author-authority</xsl:text>
                                    </xsl:attribute>
                                </xsl:if>
                                <xsl:copy-of select="node()"/>
                            </span>
                            <xsl:if test="count(following-sibling::dim:field[@element='contributor'][@qualifier='author']) != 0">
                                <xsl:text>; </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:when test="dim:field[@element='creator']">
                        <xsl:for-each select="dim:field[@element='creator']">
                            <xsl:copy-of select="node()"/>
                            <xsl:if test="count(following-sibling::dim:field[@element='creator']) != 0">
                                <xsl:text>; </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:when test="dim:field[@element='contributor']">
                        <xsl:for-each select="dim:field[@element='contributor']">
                            <xsl:copy-of select="node()"/>
                            <xsl:if test="count(following-sibling::dim:field[@element='contributor']) != 0">
                                <xsl:text>; </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.no-author</i18n:text>
                    </xsl:otherwise>
                </xsl:choose>
            </span>
            <xsl:if test="dim:field[@element='date' and @qualifier='issued'] or dim:field[@element='publisher']">
                <span class="bold"><i18n:text>xmlui.dri2xhtml.pioneer.date</i18n:text><xsl:text>:</xsl:text></span>
                <span class="content" style="width: {$metadataWidth - 110}px;">
                    <xsl:value-of
                            select="substring(dim:field[@element='date' and @qualifier='issued']/node(),1,10)"/>
                </span>
            </xsl:if>
        </div>
    </xsl:template>

    <!--handles the rendering of a single item in a list in metadata mode-->
    <xsl:template match="dim:dim" mode="itemSummaryList-DIM-metadata">
        <xsl:param name="href"/>
        <div class="artifact-description">
            <div class="artifact-title">
                <xsl:element name="a">
                    <xsl:attribute name="href">
                        <xsl:value-of select="$href"/>
                    </xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="dim:field[@element='title']">
                            <xsl:value-of select="dim:field[@element='title'][1]/node()"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.no-title</i18n:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:element>
                <span class="Z3988">
                    <xsl:attribute name="title">
                        <xsl:call-template name="renderCOinS"/>
                    </xsl:attribute>
                    &#xFEFF; <!-- non-breaking space to force separating the end tag -->
                </span>
            </div>
            <div class="artifact-info">
                <span class="author auth_more_list">
                    <xsl:choose>
                        <xsl:when test="dim:field[@element='contributor'][@qualifier='author']">
                            <xsl:for-each select="dim:field[@element='contributor'][@qualifier='author']">
                                <span>
                                  <xsl:if test="@authority">
                                    <xsl:attribute name="class"><xsl:text>ds-dc_contributor_author-authority</xsl:text></xsl:attribute>
                                  </xsl:if>
                                  <xsl:copy-of select="node()"/>
                                </span>
                                <xsl:if test="count(following-sibling::dim:field[@element='contributor'][@qualifier='author']) != 0">
                                    <xsl:text>; </xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:when test="dim:field[@element='creator']">
                            <xsl:for-each select="dim:field[@element='creator']">
                                <xsl:copy-of select="node()"/>
                                <xsl:if test="count(following-sibling::dim:field[@element='creator']) != 0">
                                    <xsl:text>; </xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:when test="dim:field[@element='contributor']">
                            <xsl:for-each select="dim:field[@element='contributor']">
                                <xsl:copy-of select="node()"/>
                                <xsl:if test="count(following-sibling::dim:field[@element='contributor']) != 0">
                                    <xsl:text>; </xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.no-author</i18n:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </span>
                <xsl:text> </xsl:text>
                <xsl:if test="dim:field[@element='date' and @qualifier='issued'] or dim:field[@element='publisher']">
	                <span class="publisher-date">
	                    <xsl:text>(</xsl:text>
	                    <xsl:if test="dim:field[@element='publisher']">
	                        <span class="publisher">
	                            <xsl:copy-of select="dim:field[@element='publisher']/node()"/>
	                        </span>
	                        <xsl:text>, </xsl:text>
	                    </xsl:if>
	                    <span class="date">
	                        <xsl:value-of select="substring(dim:field[@element='date' and @qualifier='issued']/node(),1,10)"/>
	                    </span>
	                    <xsl:text>)</xsl:text>
	                </span>
                </xsl:if>
            </div>
            <!--got rif of abastract as Jim requested.-->





        </div>
    </xsl:template>




    <xsl:template match="mets:fileSec" mode="artifact-preview">
        <xsl:param name="href"/>
  <xsl:value-of select="."/>
        <div class="thumbnail-wrapper">
            <div class="artifact-preview">
                <a class="image-link" href="{$href}">
                    <xsl:choose>
                        <xsl:when test="mets:fileGrp[@USE='THUMBNAIL']">
                            <img alt="Thumbnail">
                                <xsl:attribute name="src">
                                    <xsl:value-of
                                            select="mets:fileGrp[@USE='THUMBNAIL']/mets:file/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                                </xsl:attribute>
                            </img>
                        </xsl:when>
                        <xsl:otherwise>
                            <img alt="Icon" src="{concat($theme-path, '/images/mime.png')}" style="height: {$thumbnail.maxheight}px;"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </a>
            </div>
        </div>
    </xsl:template>



<xsl:template match="mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim" mode="artifact-preview3">
        <xsl:param name="href"/>
           

    <xsl:variable name='item_title'><xsl:value-of select="/mets:METS/mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim/dim:field[@element='title']"/></xsl:variable>


    <xsl:variable name='full_item_handle'><xsl:value-of select="/mets:METS/mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim/dim:field[@element='identifier' and @qualifier='uri'][contains(.,'TEMP-BOGUS')]"/></xsl:variable>

   <xsl:variable name="item_handle" select="substring( $full_item_handle,23, 1000 )"/>


    <xsl:variable name='owningcollname'><xsl:value-of select="/mets:METS/mets:dmdSec/mets:mdWrap/mets:xmlData/dim:dim/dim:field[@element='owningcollname']"/></xsl:variable>

        <div class="thumbnail-wrapper">
            <div class="artifact-preview">            

              <xsl:for-each select="dim:field[@element='description'][@qualifier='hathi']">
                  <a>
                <xsl:element name="a">
                    <xsl:attribute name="class">
                      <xsl:text>image-link</xsl:text>
                    </xsl:attribute>

                  <xsl:if test="(contains(.,': http'))">
                            <xsl:attribute name="href">
                              <xsl:value-of select="substring-after(.,': ')"/>
                            </xsl:attribute>
                </xsl:if>
                 <xsl:if test="not(contains(.,': http'))">
                            <xsl:attribute name="href">
                              <xsl:copy-of select="."/>
                            </xsl:attribute>

                </xsl:if>


                    <xsl:attribute name="onclick">
                      <xsl:text>_gaq.push(['_trackEvent', 'HATHI Download', 'Item List','</xsl:text><xsl:value-of select="$owningcollname"/><xsl:text> - </xsl:text><xsl:value-of select="$item_handle"/><xsl:text> - </xsl:text><xsl:value-of select="$item_title"/><xsl:text>']);</xsl:text></xsl:attribute>

                  </xsl:element>
                  <img alt="HathiTrust Viewer" src="{concat($theme-path, '/images_icon/DB-file_format_icons/hathi_trust_icon18x18.png')}" style="height:20px;width:20px;text-decoration:none;" title="HathiTrust Viewer"/>
                </a>
              </xsl:for-each>
             
            </div>
        </div>
    </xsl:template>


     <xsl:template name="itemDetailList-DIM">
         <xsl:call-template name="itemSummaryList-DIM"/>
     </xsl:template>



<xsl:template match="mets:fileSec" mode="artifact-preview2">
  

        <xsl:param name="href"/>



        <div class="thumbnail-wrapper" style="text-indent: 30px;">
            <div class="artifact-preview">            


            <!--
            For BIo, must have this in description:Access restricted to on-site users at the UM Biological Station.
                 For Bentley myustbe: Access restricted to Bentley Users Only.
            -->
<xsl:variable name="smallcase" select="'abcdefghijklmnopqrstuvwxyz'" />
<xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />

     <xsl:variable name="UMRestrictedMsg">
            <xsl:for-each select="mets:fileGrp[@USE='CONTENT']/mets:file/mets:FLocat">

              <xsl:if
                test="contains(translate(@xlink:href,$smallcase,$uppercase), translate('isallowed=n',$smallcase,$uppercase))">
                <xsl:value-of select="123" />

              </xsl:if>

            </xsl:for-each>
    </xsl:variable>


      <xsl:variable name="UMRestricted">
            <xsl:for-each select="mets:fileGrp[@USE='CONTENT']/mets:file/mets:FLocat">

              <xsl:if
                test="contains(translate(@xlink:label,$smallcase,$uppercase), translate('Restricted to U',$smallcase,$uppercase))">
                <xsl:value-of select="123" />

              </xsl:if>

            </xsl:for-each>
    </xsl:variable>


      <xsl:variable name="BioRestricted">
            <xsl:for-each select="mets:fileGrp[@USE='CONTENT']/mets:file/mets:FLocat">

                <xsl:if test="(contains(@xlink:label,'Access restricted to on-site users at the U-M Biological Station'))">
                  <xsl:value-of select="123" />
                </xsl:if>
              </xsl:for-each>
    </xsl:variable>

      <xsl:variable name="BentleyRestricted">
            <xsl:for-each select="mets:fileGrp[@USE='CONTENT']/mets:file/mets:FLocat">

                <xsl:if test="(contains(@xlink:label,'Access restricted to Bentley'))">
                  <xsl:value-of select="123" />
                </xsl:if>
              </xsl:for-each>
    </xsl:variable>

    <xsl:variable name='requestcopy'><xsl:value-of select="/mets:METS/mets:dmdSec/mets:mdWrap/mets:xmlData/dim:dim/dim:field[@element='requestcopy']"/></xsl:variable>

    <xsl:variable name='owningcollname'><xsl:value-of select="/mets:METS/mets:dmdSec/mets:mdWrap/mets:xmlData/dim:dim/dim:field[@element='owningcollname']"/></xsl:variable>


<xsl:choose>

<xsl:when test ="$requestcopy != '' ">	
  <img alt="Request Copy" src="{concat($theme-path, '/images/lock.gif')}" style="height:20px;width:20px;text-decoration:none;" title="Request Copy"/>
</xsl:when>

<xsl:when test ="$UMRestricted != '' and $UMRestrictedMsg = '' and $BioRestricted = '' and $BentleyRestricted = '' ">
  <img alt="Restricted to current U-M faculty, staff, and students" src="{concat($theme-path, '/images_icon/DB-file_format_icons/u-m_campus_only_access_icon.png')}" style="height:20px;width:20px;text-decoration:none;" title="Restricted to current U-M faculty, staff, and students"/>
</xsl:when>

<xsl:when test ="$UMRestrictedMsg != '' and $UMRestricted = '' and $BioRestricted = '' and $BentleyRestricted = '' ">
  <img alt="Restricted to current U-M faculty, staff, and students" src="{concat($theme-path, '/images_icon/DB-file_format_icons/u-m_campus_only_access_icon.png')}" style="height:20px;width:20px;text-decoration:none;" title="Restricted to current U-M faculty, staff, and students"/>
</xsl:when>

<xsl:when test ="$BioRestricted != '' and $BentleyRestricted = '' and $UMRestrictedMsg = '' and $UMRestricted = '' ">
  <img alt="Restricted to on-site access at Biological Station" src="{concat($theme-path, '/images_icon/DB-file_format_icons/u-m_campus_only_access_icon.png')}" style="height:20px;width:20px;text-decoration:none;" title="Restricted to on-site access at Biological Station"/>
</xsl:when>

<xsl:when test ="$BentleyRestricted != '' and $BioRestricted = '' and $UMRestrictedMsg = '' and $UMRestricted = '' ">
  <img alt="Restricted to on-site access at Bentley Historical Library" src="{concat($theme-path, '/images_icon/DB-file_format_icons/u-m_campus_only_access_icon.png')}" style="height:20px;width:20px;text-decoration:none;" title="Restricted to on-site access at Bentley Historical Library"/>
</xsl:when>

<xsl:when test ="$UMRestricted != '' or $UMRestrictedMsg != '' or $BioRestricted != '' or $BentleyRestricted != '' ">
  <img alt="Access restricted; see individual files" src="{concat($theme-path, '/images_icon/DB-file_format_icons/u-m_campus_only_access_icon.png')}" style="height:20px;width:20px;text-decoration:none;" title="Access restricted; see individual files"/>
</xsl:when>


</xsl:choose>

      <xsl:variable name="primaryBitstreamId">

        <xsl:value-of select="/mets:METS/mets:structMap[@TYPE='LOGICAL']/mets:div[@TYPE='DSpace Item']/mets:fptr/@FILEID" />
      </xsl:variable>


         <xsl:choose>

      <xsl:when test="/mets:METS/mets:fileSec/mets:fileGrp[@USE='CONTENT']/mets:file[@ID=$primaryBitstreamId]/@MIMETYPE='text/html'">

        <a>
          <xsl:element name="a">
            <xsl:attribute name="class">
              <xsl:text>image-link</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="href">
              <xsl:value-of select="/mets:METS/mets:fileSec/mets:fileGrp[@USE='CONTENT']/mets:file[@ID=$primaryBitstreamId][@MIMETYPE='text/html']/mets:FLocat/@xlink:href"/>
              
            </xsl:attribute>
	  <img alt="HTML" src="{concat($theme-path, '/images_icon/DB-file_format_icons/html_icon-18x18.PNG')}" style="height:20px;width:20px;text-decoration:none;" title="HTML"/>
  </xsl:element>
	</a>

<xsl:text>  (</xsl:text>

        <xsl:choose>
          <xsl:when test="/mets:METS/mets:fileSec/mets:fileGrp[@USE='CONTENT']/mets:file[@ID=$primaryBitstreamId][@MIMETYPE='text/html']/@SIZE &lt; 1024">
            <xsl:value-of select="format-number(/mets:METS/mets:fileSec/mets:fileGrp[@USE='CONTENT']/mets:file[@ID=$primaryBitstreamId][@MIMETYPE='text/html']/@SIZE,'#.#', 'num')"/> 
            <i18n:text>xmlui.dri2xhtml.METS-1.0.size-bytes</i18n:text>
          </xsl:when>
          <xsl:when test="/mets:METS/mets:fileSec/mets:fileGrp[@USE='CONTENT']/mets:file[@ID=$primaryBitstreamId][@MIMETYPE='text/html']/@SIZE &lt; 1024 * 1024">
            <xsl:value-of select="format-number(/mets:METS/mets:fileSec/mets:fileGrp[@USE='CONTENT']/mets:file[@ID=$primaryBitstreamId][@MIMETYPE='text/html']/@SIZE div (1024),'#.#', 'num')"/> 
            <i18n:text>xmlui.dri2xhtml.METS-1.0.size-kilobytes</i18n:text>
          </xsl:when>
          <xsl:when test="/mets:METS/mets:fileSec/mets:fileGrp[@USE='CONTENT']/mets:file[@ID=$primaryBitstreamId][@MIMETYPE='text/html']/@SIZE &lt; 1024 * 1024 * 1024">                              
          <xsl:value-of select="format-number(/mets:METS/mets:fileSec/mets:fileGrp[@USE='CONTENT']/mets:file[@ID=$primaryBitstreamId][@MIMETYPE='text/html']/@SIZE div (1024 * 1024),'#.#', 'num')"/> 
          <i18n:text>xmlui.dri2xhtml.METS-1.0.size-megabytes</i18n:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="format-number(/mets:METS/mets:fileSec/mets:fileGrp[@USE='CONTENT']/mets:file[@ID=$primaryBitstreamId][@MIMETYPE='text/html']/@SIZE div (1024 * 1024 * 1024),'#.#', 'num')"/> 
          <i18n:text>xmlui.dri2xhtml.METS-1.0.size-gigabytes</i18n:text>
        </xsl:otherwise>
      </xsl:choose>

<xsl:text>  )</xsl:text>

      </xsl:when>
      <xsl:otherwise>




    <xsl:variable name='full_item_handle'><xsl:value-of select="/mets:METS/mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim/dim:field[@element='identifier' and @qualifier='uri'][contains(.,'TEMP-BOGUS')]"/></xsl:variable>


    <xsl:variable name='item_title'><xsl:value-of select="/mets:METS/mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim/dim:field[@element='title']"/></xsl:variable>

   <xsl:variable name="item_handle" select="substring( $full_item_handle,23, 1000 )"/>




        <xsl:for-each select="mets:fileGrp[@USE='CONTENT']/mets:file">

              <xsl:choose>

                <xsl:when test="@MIMETYPE='application/pdf'">
                <a>
                    <xsl:attribute name="class">
                      <xsl:text>image-link</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="href">
                      <xsl:value-of select="mets:FLocat/@xlink:href"/>
                    </xsl:attribute>

                    <xsl:attribute name="onclick">
                      <xsl:text>_gaq.push(['_trackEvent', 'PDF Download', 'Item List','</xsl:text><xsl:value-of select="$owningcollname"/><xsl:text> - </xsl:text><xsl:value-of select="$item_handle"/><xsl:text> - </xsl:text><xsl:value-of select="$item_title"/><xsl:text>']);</xsl:text></xsl:attribute>

                  <img alt="PDF file" src="{concat($theme-path, '/images_icon/DB-file_format_icons/pdf_icon-18x18.png')}" style="height:20px;width:20px;text-decoration:none;" title="PDF file"/>
                </a>
                </xsl:when>



                <xsl:when test="@MIMETYPE='text/plain'">
                <a>
                    <xsl:attribute name="class">
                      <xsl:text>image-link</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="href">
                      <xsl:value-of select="mets:FLocat/@xlink:href"/>
                    </xsl:attribute>

                    <xsl:attribute name="onclick">
                      <xsl:text>_gaq.push(['_trackEvent', 'TXT Download', 'Item List','</xsl:text><xsl:value-of select="$owningcollname"/><xsl:text> - </xsl:text><xsl:value-of select="$item_handle"/><xsl:text> - </xsl:text><xsl:value-of select="$item_title"/><xsl:text>']);</xsl:text></xsl:attribute>

                  <img alt="TXT file" src="{concat($theme-path, '/images_icon/DB-file_format_icons/text_icon-18x18.png')}" style="height:20px;width:20px;text-decoration:none;" title="TXT file"/>
                </a>
                </xsl:when>

              <xsl:when test="@MIMETYPE='application/msword'">
                  <a>
                    <xsl:attribute name="class">
                      <xsl:text>image-link</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="href">
                      <xsl:value-of select="mets:FLocat/@xlink:href"/>
                    </xsl:attribute>

                    <xsl:attribute name="onclick">
                      <xsl:text>_gaq.push(['_trackEvent', 'MSWord Download', 'Item List','</xsl:text><xsl:value-of select="$owningcollname"/><xsl:text> - </xsl:text><xsl:value-of select="$item_handle"/><xsl:text> - </xsl:text><xsl:value-of select="$item_title"/><xsl:text>']);</xsl:text></xsl:attribute>

                  <img alt="MS Word file" src="{concat($theme-path, '/images_icon/DB-file_format_icons/word_icon-18x18.png')}" style="height:20px;width:20px;text-decoration:none;" title="MS Word file"/>
                </a>
                </xsl:when>


              <xsl:when test="@MIMETYPE='application/vnd.ms-powerpoint'">
                  <a>
                    <xsl:attribute name="class">
                      <xsl:text>image-link</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="href">
                      <xsl:value-of select="mets:FLocat/@xlink:href"/>
                    </xsl:attribute>

                    <xsl:attribute name="onclick">
                      <xsl:text>_gaq.push(['_trackEvent', 'MSPowerPoint Download', 'Item List','</xsl:text><xsl:value-of select="$owningcollname"/><xsl:text> - </xsl:text><xsl:value-of select="$item_handle"/><xsl:text> - </xsl:text><xsl:value-of select="$item_title"/><xsl:text>']);</xsl:text></xsl:attribute>

                  <img alt="MS PowerPoint file" src="{concat($theme-path, '/images_icon/DB-file_format_icons/powerpoint_icon-18x18.png')}" style="height:20px;width:20px;text-decoration:none;" title="MS PowerPoint file"/>
                </a>
                </xsl:when>

              <xsl:when test="@MIMETYPE='application/vnd.ms-excel'">
                  <a>
                    <xsl:attribute name="class">
                      <xsl:text>image-link</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="href">
                      <xsl:value-of select="mets:FLocat/@xlink:href"/>
                    </xsl:attribute>

                    <xsl:attribute name="onclick">
                      <xsl:text>_gaq.push(['_trackEvent', 'MSExcel Download', 'Item List','</xsl:text><xsl:value-of select="$owningcollname"/><xsl:text> - </xsl:text><xsl:value-of select="$item_handle"/><xsl:text> - </xsl:text><xsl:value-of select="$item_title"/><xsl:text>']);</xsl:text></xsl:attribute>

                  <img alt="MS Excel file" src="{concat($theme-path, '/images_icon/DB-file_format_icons/excel_icon-18x18.png')}" style="height:20px;width:20px;text-decoration:none;" title="MS Excel file"/>
                </a>
                </xsl:when>


                <xsl:when test="@MIMETYPE='image/jpeg'">
                  <a>
                    <xsl:attribute name="class">
                      <xsl:text>image-link</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="href">
                      <xsl:value-of select="mets:FLocat/@xlink:href"/>
                    </xsl:attribute>

                    <xsl:attribute name="onclick">
                      <xsl:text>_gaq.push(['_trackEvent', 'JPEG Download', 'Item List','</xsl:text><xsl:value-of select="$owningcollname"/><xsl:text> - </xsl:text><xsl:value-of select="$item_handle"/><xsl:text> - </xsl:text><xsl:value-of select="$item_title"/><xsl:text>']);</xsl:text></xsl:attribute>

                  <img alt="JPEG file" src="{concat($theme-path, '/images_icon/DB-file_format_icons/jpeg_icon-18x18.png')}" style="height:20px;width:20px;text-decoration:none;" title="JPEG file"/>
                </a>
                </xsl:when>

                <xsl:when test="@MIMETYPE='image/tiff'">
                  <a>
                    <xsl:attribute name="class">
                      <xsl:text>image-link</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="href">
                      <xsl:value-of select="mets:FLocat/@xlink:href"/>
                    </xsl:attribute>

                    <xsl:attribute name="onclick">
                      <xsl:text>_gaq.push(['_trackEvent', 'TIFF Download', 'Item List','</xsl:text><xsl:value-of select="$owningcollname"/><xsl:text> - </xsl:text><xsl:value-of select="$item_handle"/><xsl:text> - </xsl:text><xsl:value-of select="$item_title"/><xsl:text>']);</xsl:text></xsl:attribute>

                  <img alt="TIFF file" src="{concat($theme-path, '/images_icon/DB-file_format_icons/tiff_icon-18x18.png')}" style="height:20px;width:20px;text-decoration:none;" title="TIFF file"/>
                </a>
                </xsl:when>


                <xsl:when test="@MIMETYPE='image/gif' or @MIMETYPE='image/png' or @MIMETYPE='image/jp2'or @MIMETYPE='image/x-photo-cd'">
                  <a>
                    <xsl:attribute name="class">
                      <xsl:text>image-link</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="href">
                      <xsl:value-of select="mets:FLocat/@xlink:href"/>
                    </xsl:attribute>

                    <xsl:attribute name="onclick">
                      <xsl:text>_gaq.push(['_trackEvent', 'IMAGE Download', 'Item List','</xsl:text><xsl:value-of select="$owningcollname"/><xsl:text> - </xsl:text><xsl:value-of select="$item_handle"/><xsl:text> - </xsl:text><xsl:value-of select="$item_title"/><xsl:text>']);</xsl:text></xsl:attribute>

                  <img alt="Image file" src="{concat($theme-path, '/images_icon/DB-file_format_icons/generic_image_icon-18x18.png')}" style="height:20px;width:20px;text-decoration:none;" title="Image file"/>
                </a>
                </xsl:when>


                <xsl:when test="@MIMETYPE='video/mpeg' or @MIMETYPE='video/quicktime'">
                  <a>
                    <xsl:attribute name="class">
                      <xsl:text>image-link</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="href">
                      <xsl:value-of select="mets:FLocat/@xlink:href"/>
                    </xsl:attribute>

                    <xsl:attribute name="onclick">
                      <xsl:text>_gaq.push(['_trackEvent', 'VIDEO Download', 'Item List','</xsl:text><xsl:value-of select="$owningcollname"/><xsl:text> - </xsl:text><xsl:value-of select="$item_handle"/><xsl:text> - </xsl:text><xsl:value-of select="$item_title"/><xsl:text>']);</xsl:text></xsl:attribute>

                  <img alt="Video file" src="{concat($theme-path, '/images_icon/DB-file_format_icons/video_icon18x18.png')}" style="height:20px;width:20px;text-decoration:none;" title="Video file"/>
                </a>
                </xsl:when>


                <xsl:when test="@MIMETYPE='audio/x-aiff' or @MIMETYPE='audio/basic' or @MIMETYPE='audio/x-wav' or @MIMETYPE='audio/x-mpeg' or @MIMETYPE='audio/x-pn-realaudio' or @MIMETYPE='audio/mp3'">
                  <a>
                    <xsl:attribute name="class">
                      <xsl:text>image-link</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="href">
                      <xsl:value-of select="mets:FLocat/@xlink:href"/>
                    </xsl:attribute>

                    <xsl:attribute name="onclick">
                      <xsl:text>_gaq.push(['_trackEvent', 'AUDIO Download', 'Item List','</xsl:text><xsl:value-of select="$owningcollname"/><xsl:text> - </xsl:text><xsl:value-of select="$item_handle"/><xsl:text> - </xsl:text><xsl:value-of select="$item_title"/><xsl:text>']);</xsl:text></xsl:attribute>

                  <img alt="Audio file" src="{concat($theme-path, '/images_icon/DB-file_format_icons/audio_icon18x18.png')}" style="height:20px;width:20px;text-decoration:none;" title="Audio file"/>
                </a>
                </xsl:when>


                <xsl:when test="@MIMETYPE='application/zip'">
                  <a>
                    <xsl:attribute name="class">
                      <xsl:text>image-link</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="href">
                      <xsl:value-of select="mets:FLocat/@xlink:href"/>
                    </xsl:attribute>

                    <xsl:attribute name="onclick">
                      <xsl:text>_gaq.push(['_trackEvent', 'ZIP Download', 'Item List','</xsl:text><xsl:value-of select="$owningcollname"/><xsl:text> - </xsl:text><xsl:value-of select="$item_handle"/><xsl:text> - </xsl:text><xsl:value-of select="$item_title"/><xsl:text>']);</xsl:text></xsl:attribute>

                  <img alt="Zip file" src="{concat($theme-path, '/images_icon/DB-file_format_icons/zip_icon-18x18.png')}" style="height:20px;width:20px;text-decoration:none;" title="Zip file"/>
                </a>
                </xsl:when>

                <xsl:when test="@MIMETYPE='hidden'">

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
                      <xsl:text>_gaq.push(['_trackEvent', 'OTHER Download', 'Item List','</xsl:text><xsl:value-of select="$owningcollname"/><xsl:text> - </xsl:text><xsl:value-of select="$item_handle"/><xsl:text> - </xsl:text><xsl:value-of select="$item_title"/><xsl:text>']);</xsl:text></xsl:attribute>

                  <img alt="Unidentified file format" src="{concat($theme-path, '/images_icon/DB-file_format_icons/generic_bitstream18x18.png')}" style="height:20px;width:20px;text-decoration:none;" title="Unidentified file format"/>
                </a>
                </xsl:otherwise>
              </xsl:choose>

              <xsl:choose>
                <xsl:when test="@MIMETYPE='hidden'">

                </xsl:when>
                <xsl:otherwise>


              <span>
<xsl:text>  (</xsl:text>

                        <xsl:choose>
                            <xsl:when test="@SIZE &lt; 1024">
                                <xsl:value-of select="format-number(@SIZE,'#.#', 'num')"/> 
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-bytes</i18n:text>
                            </xsl:when>
                            <xsl:when test="@SIZE &lt; 1024 * 1024">
                                <xsl:value-of select="format-number(@SIZE div (1024),'#.#', 'num')"/> 
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-kilobytes</i18n:text>
                            </xsl:when>
                            <xsl:when test="@SIZE &lt; 1024 * 1024 * 1024">                              
                                <xsl:value-of select="format-number(@SIZE div (1024 * 1024),'#.#', 'num')"/> 
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-megabytes</i18n:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="format-number(@SIZE div (1024 * 1024 * 1024),'#.#', 'num')"/> 
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-gigabytes</i18n:text>
                            </xsl:otherwise>
                        </xsl:choose>

<xsl:text>)</xsl:text>
</span>
                </xsl:otherwise>
              </xsl:choose>

              </xsl:for-each>

      </xsl:otherwise>
    </xsl:choose>
            </div>
        </div>
    </xsl:template>




</xsl:stylesheet>

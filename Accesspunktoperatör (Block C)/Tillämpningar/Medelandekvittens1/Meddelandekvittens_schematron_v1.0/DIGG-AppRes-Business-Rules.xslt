<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xsl:stylesheet xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                xmlns:saxon="http://saxon.sf.net/"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:schold="http://www.ascc.net/xml/schematron"
                xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                xmlns:xhtml="http://www.w3.org/1999/xhtml"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2"
                xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2"
                xmlns:app="urn:oasis:names:specification:ubl:schema:xsd:ApplicationResponse-2"
                xmlns:ext="urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2"
                xmlns:qdt="urn:oasis:names:specification:ubl:schema:xsd:QualifiedDataTypes-2"
                xmlns:udt="urn:oasis:names:specification:ubl:schema:xsd:UnqualifiedDataTypes-2"
                xmlns:ccts-cct="urn:un:unece:uncefact:data:specification:CoreComponentTypeSchemaModule:2"
                xmlns:u="utils"
                version="2.0"><!--Implementers: please note that overriding process-prolog or process-root is 
    the preferred method for meta-stylesheets to use where possible. -->
   <xsl:param name="archiveDirParameter"/>
   <xsl:param name="archiveNameParameter"/>
   <xsl:param name="fileNameParameter"/>
   <xsl:param name="fileDirParameter"/>
   <xsl:variable name="document-uri">
      <xsl:value-of select="document-uri(/)"/>
   </xsl:variable>
   <!--PHASES-->
   <!--PROLOG-->
   <xsl:output xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
               method="xml"
               omit-xml-declaration="no"
               standalone="yes"
               indent="yes"/>
   <!--XSD TYPES FOR XSLT2-->
   <!--KEYS AND FUNCTIONS-->
   <!--DEFAULT RULES-->
   <!--MODE: SCHEMATRON-SELECT-FULL-PATH-->
   <!--This mode can be used to generate an ugly though full XPath for locators-->
   <xsl:template match="*" mode="schematron-select-full-path">
      <xsl:apply-templates select="." mode="schematron-get-full-path"/>
   </xsl:template>
   <!--MODE: SCHEMATRON-FULL-PATH-->
   <!--This mode can be used to generate an ugly though full XPath for locators-->
   <xsl:template match="*" mode="schematron-get-full-path">
      <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
      <xsl:text>/</xsl:text>
      <xsl:choose>
         <xsl:when test="namespace-uri()=''">
            <xsl:value-of select="name()"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>*:</xsl:text>
            <xsl:value-of select="local-name()"/>
            <xsl:text>[namespace-uri()='</xsl:text>
            <xsl:value-of select="namespace-uri()"/>
            <xsl:text>']</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="preceding"
                    select="count(preceding-sibling::*[local-name()=local-name(current())                                   and namespace-uri() = namespace-uri(current())])"/>
      <xsl:text>[</xsl:text>
      <xsl:value-of select="1+ $preceding"/>
      <xsl:text>]</xsl:text>
   </xsl:template>
   <xsl:template match="@*" mode="schematron-get-full-path">
      <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
      <xsl:text>/</xsl:text>
      <xsl:choose>
         <xsl:when test="namespace-uri()=''">@<xsl:value-of select="name()"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>@*[local-name()='</xsl:text>
            <xsl:value-of select="local-name()"/>
            <xsl:text>' and namespace-uri()='</xsl:text>
            <xsl:value-of select="namespace-uri()"/>
            <xsl:text>']</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <!--MODE: SCHEMATRON-FULL-PATH-2-->
   <!--This mode can be used to generate prefixed XPath for humans-->
   <xsl:template match="node() | @*" mode="schematron-get-full-path-2">
      <xsl:for-each select="ancestor-or-self::*">
         <xsl:text>/</xsl:text>
         <xsl:value-of select="name(.)"/>
         <xsl:if test="preceding-sibling::*[name(.)=name(current())]">
            <xsl:text>[</xsl:text>
            <xsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
            <xsl:text>]</xsl:text>
         </xsl:if>
      </xsl:for-each>
      <xsl:if test="not(self::*)">
         <xsl:text/>/@<xsl:value-of select="name(.)"/>
      </xsl:if>
   </xsl:template>
   <!--MODE: SCHEMATRON-FULL-PATH-3-->
   <!--This mode can be used to generate prefixed XPath for humans 
	(Top-level element has index)-->
   <xsl:template match="node() | @*" mode="schematron-get-full-path-3">
      <xsl:for-each select="ancestor-or-self::*">
         <xsl:text>/</xsl:text>
         <xsl:value-of select="name(.)"/>
         <xsl:if test="parent::*">
            <xsl:text>[</xsl:text>
            <xsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
            <xsl:text>]</xsl:text>
         </xsl:if>
      </xsl:for-each>
      <xsl:if test="not(self::*)">
         <xsl:text/>/@<xsl:value-of select="name(.)"/>
      </xsl:if>
   </xsl:template>
   <!--MODE: GENERATE-ID-FROM-PATH -->
   <xsl:template match="/" mode="generate-id-from-path"/>
   <xsl:template match="text()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.text-', 1+count(preceding-sibling::text()), '-')"/>
   </xsl:template>
   <xsl:template match="comment()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.comment-', 1+count(preceding-sibling::comment()), '-')"/>
   </xsl:template>
   <xsl:template match="processing-instruction()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.processing-instruction-', 1+count(preceding-sibling::processing-instruction()), '-')"/>
   </xsl:template>
   <xsl:template match="@*" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.@', name())"/>
   </xsl:template>
   <xsl:template match="*" mode="generate-id-from-path" priority="-0.5">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:text>.</xsl:text>
      <xsl:value-of select="concat('.',name(),'-',1+count(preceding-sibling::*[name()=name(current())]),'-')"/>
   </xsl:template>
   <!--MODE: GENERATE-ID-2 -->
   <xsl:template match="/" mode="generate-id-2">U</xsl:template>
   <xsl:template match="*" mode="generate-id-2" priority="2">
      <xsl:text>U</xsl:text>
      <xsl:number level="multiple" count="*"/>
   </xsl:template>
   <xsl:template match="node()" mode="generate-id-2">
      <xsl:text>U.</xsl:text>
      <xsl:number level="multiple" count="*"/>
      <xsl:text>n</xsl:text>
      <xsl:number count="node()"/>
   </xsl:template>
   <xsl:template match="@*" mode="generate-id-2">
      <xsl:text>U.</xsl:text>
      <xsl:number level="multiple" count="*"/>
      <xsl:text>_</xsl:text>
      <xsl:value-of select="string-length(local-name(.))"/>
      <xsl:text>_</xsl:text>
      <xsl:value-of select="translate(name(),':','.')"/>
   </xsl:template>
   <!--Strip characters-->
   <xsl:template match="text()" priority="-1"/>
   <!--SCHEMA SETUP-->
   <xsl:template match="/">
      <svrl:schematron-output xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                              title="Regler för DIGG Kvittensmeddelande"
                              schemaVersion="iso">
         <xsl:comment>
            <xsl:value-of select="$archiveDirParameter"/>   
		 <xsl:value-of select="$archiveNameParameter"/>  
		 <xsl:value-of select="$fileNameParameter"/>  
		 <xsl:value-of select="$fileDirParameter"/>
         </xsl:comment>
         <svrl:ns-prefix-in-attribute-values uri="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2"
                                             prefix="cbc"/>
         <svrl:ns-prefix-in-attribute-values uri="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2"
                                             prefix="cac"/>
         <svrl:ns-prefix-in-attribute-values uri="urn:oasis:names:specification:ubl:schema:xsd:ApplicationResponse-2"
                                             prefix="app"/>
         <svrl:ns-prefix-in-attribute-values uri="urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2"
                                             prefix="ext"/>
         <svrl:ns-prefix-in-attribute-values uri="urn:oasis:names:specification:ubl:schema:xsd:QualifiedDataTypes-2"
                                             prefix="qdt"/>
         <svrl:ns-prefix-in-attribute-values uri="urn:oasis:names:specification:ubl:schema:xsd:UnqualifiedDataTypes-2"
                                             prefix="udt"/>
         <svrl:ns-prefix-in-attribute-values uri="urn:un:unece:uncefact:data:specification:CoreComponentTypeSchemaModule:2"
                                             prefix="ccts-cct"/>
         <svrl:ns-prefix-in-attribute-values uri="http://www.w3.org/2001/XMLSchema" prefix="xs"/>
         <svrl:ns-prefix-in-attribute-values uri="utils" prefix="u"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M10"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M11"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M12"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M13"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M14"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M15"/>
      </svrl:schematron-output>
   </xsl:template>
   <!--SCHEMATRON PATTERNS-->
   <svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Regler för DIGG Kvittensmeddelande</svrl:text>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="/app:ApplicationResponse/cac:DocumentResponse/cac:DocumentReference/cac:Attachment | /app:ApplicationResponse/cac:DocumentResponse/cac:DocumentReference/cac:IssuerParty | /app:ApplicationResponse/cac:DocumentResponse/cac:DocumentReference/cac:ResultOfVerification | /app:ApplicationResponse/cac:DocumentResponse/cac:DocumentReference/cac:ValidityPeriod | /app:ApplicationResponse/cac:DocumentResponse/cac:DocumentReference/cbc:CopyIndicator | /app:ApplicationResponse/cac:DocumentResponse/cac:DocumentReference/cbc:DocumentDescription | /app:ApplicationResponse/cac:DocumentResponse/cac:DocumentReference/cbc:DocumentStatusCode | /app:ApplicationResponse/cac:DocumentResponse/cac:DocumentReference/cbc:DocumentType | /app:ApplicationResponse/cac:DocumentResponse/cac:DocumentReference/cbc:DocumentTypeCode | /app:ApplicationResponse/cac:DocumentResponse/cac:DocumentReference/cbc:ID[@schemeAgencyID] | /app:ApplicationResponse/cac:DocumentResponse/cac:DocumentReference/cbc:ID[@schemeAgencyName] | /app:ApplicationResponse/cac:DocumentResponse/cac:DocumentReference/cbc:ID[@schemeDataURI] | /app:ApplicationResponse/cac:DocumentResponse/cac:DocumentReference/cbc:ID[@schemeID] | /app:ApplicationResponse/cac:DocumentResponse/cac:DocumentReference/cbc:ID[@schemeName] | /app:ApplicationResponse/cac:DocumentResponse/cac:DocumentReference/cbc:ID[@schemeURI] | /app:ApplicationResponse/cac:DocumentResponse/cac:DocumentReference/cbc:ID[@schemeVersionID] | /app:ApplicationResponse/cac:DocumentResponse/cac:DocumentReference/cbc:IssueDate | /app:ApplicationResponse/cac:DocumentResponse/cac:DocumentReference/cbc:IssueTime | /app:ApplicationResponse/cac:DocumentResponse/cac:DocumentReference/cbc:LanguageID | /app:ApplicationResponse/cac:DocumentResponse/cac:DocumentReference/cbc:LocaleCode | /app:ApplicationResponse/cac:DocumentResponse/cac:DocumentReference/cbc:UUID | /app:ApplicationResponse/cac:DocumentResponse/cac:DocumentReference/cbc:VersionID | /app:ApplicationResponse/cac:DocumentResponse/cac:DocumentReference/cbc:XPath | /app:ApplicationResponse/cac:DocumentResponse/cac:IssuerParty | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:LineReference/cac:DocumentReference | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:LineReference/cbc:LineID[@schemeAgencyID] | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:LineReference/cbc:LineID[@schemeAgencyName] | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:LineReference/cbc:LineID[@schemeDataURI] | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:LineReference/cbc:LineID[@schemeID] | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:LineReference/cbc:LineID[@schemeName] | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:LineReference/cbc:LineID[@schemeURI] | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:LineReference/cbc:LineID[@schemeVersionID] | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:LineReference/cbc:LineStatusCode | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:LineReference/cbc:UUID | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cac:Status/cac:Condition | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cac:Status/cbc:ConditionCode | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cac:Status/cbc:Description | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cac:Status/cbc:IndicationIndicator | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cac:Status/cbc:Percent | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cac:Status/cbc:ReferenceDate | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cac:Status/cbc:ReferenceTime | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cac:Status/cbc:ReliabilityPercent | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cac:Status/cbc:SequenceID | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cac:Status/cbc:StatusReasonCode[@languageID] | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cac:Status/cbc:StatusReasonCode[@listAgencyID] | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cac:Status/cbc:StatusReasonCode[@listAgencyName] | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cac:Status/cbc:StatusReasonCode[@listID] | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cac:Status/cbc:StatusReasonCode[@listName] | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cac:Status/cbc:StatusReasonCode[@listSchemeURI] | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cac:Status/cbc:StatusReasonCode[@listURI] | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cac:Status/cbc:StatusReasonCode[@listVersionID] | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cac:Status/cbc:StatusReasonCode[@name] | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cac:Status/cbc:StatusReason[@languageID] | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cac:Status/cbc:StatusReason[@languageLocaleID] | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cac:Status/cbc:Text | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cbc:Description | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cbc:EffectiveDate | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cbc:EffectiveTime | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cbc:ReferenceID | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cbc:ResponseCode[@languageID] | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cbc:ResponseCode[@listAgencyID] | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cbc:ResponseCode[@listAgencyName] | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cbc:ResponseCode[@listID] | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cbc:ResponseCode[@listName] | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cbc:ResponseCode[@listSchemeURI] | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cbc:ResponseCode[@listURI] | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cbc:ResponseCode[@listVersionID] | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cbc:ResponseCode[@name] | /app:ApplicationResponse/cac:DocumentResponse/cac:RecipientParty | /app:ApplicationResponse/cac:DocumentResponse/cac:Response/cac:Status | /app:ApplicationResponse/cac:DocumentResponse/cac:Response/cbc:Description | /app:ApplicationResponse/cac:DocumentResponse/cac:Response/cbc:EffectiveDate | /app:ApplicationResponse/cac:DocumentResponse/cac:Response/cbc:EffectiveTime | /app:ApplicationResponse/cac:DocumentResponse/cac:Response/cbc:ReferenceID | /app:ApplicationResponse/cac:DocumentResponse/cac:Response/cbc:ResponseCode[@languageID] | /app:ApplicationResponse/cac:DocumentResponse/cac:Response/cbc:ResponseCode[@listAgencyID] | /app:ApplicationResponse/cac:DocumentResponse/cac:Response/cbc:ResponseCode[@listAgencyName] | /app:ApplicationResponse/cac:DocumentResponse/cac:Response/cbc:ResponseCode[@listID] | /app:ApplicationResponse/cac:DocumentResponse/cac:Response/cbc:ResponseCode[@listName] | /app:ApplicationResponse/cac:DocumentResponse/cac:Response/cbc:ResponseCode[@listSchemeURI] | /app:ApplicationResponse/cac:DocumentResponse/cac:Response/cbc:ResponseCode[@listURI] | /app:ApplicationResponse/cac:DocumentResponse/cac:Response/cbc:ResponseCode[@listVersionID] | /app:ApplicationResponse/cac:DocumentResponse/cac:Response/cbc:ResponseCode[@name] | /app:ApplicationResponse/cac:ReceiverParty/cac:AgentParty | /app:ApplicationResponse/cac:ReceiverParty/cac:Contact | /app:ApplicationResponse/cac:ReceiverParty/cac:FinancialAccount | /app:ApplicationResponse/cac:ReceiverParty/cac:Language | /app:ApplicationResponse/cac:ReceiverParty/cac:PartyIdentification | /app:ApplicationResponse/cac:ReceiverParty/cac:PartyLegalEntity | /app:ApplicationResponse/cac:ReceiverParty/cac:PartyName | /app:ApplicationResponse/cac:ReceiverParty/cac:PartyTaxScheme | /app:ApplicationResponse/cac:ReceiverParty/cac:Person | /app:ApplicationResponse/cac:ReceiverParty/cac:PhysicalLocation | /app:ApplicationResponse/cac:ReceiverParty/cac:PostalAddress | /app:ApplicationResponse/cac:ReceiverParty/cac:PowerOfAttorney | /app:ApplicationResponse/cac:ReceiverParty/cac:ServiceProviderParty | /app:ApplicationResponse/cac:ReceiverParty/cbc:EndpointID[@schemeAgencyID] | /app:ApplicationResponse/cac:ReceiverParty/cbc:EndpointID[@schemeAgencyName] | /app:ApplicationResponse/cac:ReceiverParty/cbc:EndpointID[@schemeDataURI] | /app:ApplicationResponse/cac:ReceiverParty/cbc:EndpointID[@schemeName] | /app:ApplicationResponse/cac:ReceiverParty/cbc:EndpointID[@schemeURI] | /app:ApplicationResponse/cac:ReceiverParty/cbc:EndpointID[@schemeVersionID] | /app:ApplicationResponse/cac:ReceiverParty/cbc:IndustryClassificationCode | /app:ApplicationResponse/cac:ReceiverParty/cbc:LogoReferenceID | /app:ApplicationResponse/cac:ReceiverParty/cbc:MarkAttentionIndicator | /app:ApplicationResponse/cac:ReceiverParty/cbc:MarkCareIndicator | /app:ApplicationResponse/cac:ReceiverParty/cbc:WebsiteURI | /app:ApplicationResponse/cac:SenderParty/cac:AgentParty | /app:ApplicationResponse/cac:SenderParty/cac:Contact | /app:ApplicationResponse/cac:SenderParty/cac:FinancialAccount | /app:ApplicationResponse/cac:SenderParty/cac:Language | /app:ApplicationResponse/cac:SenderParty/cac:PartyIdentification | /app:ApplicationResponse/cac:SenderParty/cac:PartyLegalEntity | /app:ApplicationResponse/cac:SenderParty/cac:PartyName | /app:ApplicationResponse/cac:SenderParty/cac:PartyTaxScheme | /app:ApplicationResponse/cac:SenderParty/cac:Person | /app:ApplicationResponse/cac:SenderParty/cac:PhysicalLocation | /app:ApplicationResponse/cac:SenderParty/cac:PostalAddress | /app:ApplicationResponse/cac:SenderParty/cac:PowerOfAttorney | /app:ApplicationResponse/cac:SenderParty/cac:ServiceProviderParty | /app:ApplicationResponse/cac:SenderParty/cbc:EndpointID[@schemeAgencyID] | /app:ApplicationResponse/cac:SenderParty/cbc:EndpointID[@schemeAgencyName] | /app:ApplicationResponse/cac:SenderParty/cbc:EndpointID[@schemeDataURI] | /app:ApplicationResponse/cac:SenderParty/cbc:EndpointID[@schemeName] | /app:ApplicationResponse/cac:SenderParty/cbc:EndpointID[@schemeURI] | /app:ApplicationResponse/cac:SenderParty/cbc:EndpointID[@schemeVersionID] | /app:ApplicationResponse/cac:SenderParty/cbc:IndustryClassificationCode | /app:ApplicationResponse/cac:SenderParty/cbc:LogoReferenceID | /app:ApplicationResponse/cac:SenderParty/cbc:MarkAttentionIndicator | /app:ApplicationResponse/cac:SenderParty/cbc:MarkCareIndicator | /app:ApplicationResponse/cac:SenderParty/cbc:WebsiteURI | /app:ApplicationResponse/cac:Signature | /app:ApplicationResponse/cbc:CustomizationID[@schemeAgencyID] | /app:ApplicationResponse/cbc:CustomizationID[@schemeAgencyName] | /app:ApplicationResponse/cbc:CustomizationID[@schemeDataURI] | /app:ApplicationResponse/cbc:CustomizationID[@schemeID] | /app:ApplicationResponse/cbc:CustomizationID[@schemeName] | /app:ApplicationResponse/cbc:CustomizationID[@schemeURI] | /app:ApplicationResponse/cbc:CustomizationID[@schemeVersionID] | /app:ApplicationResponse/cbc:ID[@schemeAgencyID] | /app:ApplicationResponse/cbc:ID[@schemeAgencyName] | /app:ApplicationResponse/cbc:ID[@schemeDataURI] | /app:ApplicationResponse/cbc:ID[@schemeID] | /app:ApplicationResponse/cbc:ID[@schemeName] | /app:ApplicationResponse/cbc:ID[@schemeURI] | /app:ApplicationResponse/cbc:ID[@schemeVersionID] | /app:ApplicationResponse/cbc:Note | /app:ApplicationResponse/cbc:ProfileExecutionID | /app:ApplicationResponse/cbc:ProfileID[@schemeAgencyID] | /app:ApplicationResponse/cbc:ProfileID[@schemeAgencyName] | /app:ApplicationResponse/cbc:ProfileID[@schemeDataURI] | /app:ApplicationResponse/cbc:ProfileID[@schemeID] | /app:ApplicationResponse/cbc:ProfileID[@schemeName] | /app:ApplicationResponse/cbc:ProfileID[@schemeURI] | /app:ApplicationResponse/cbc:ProfileID[@schemeVersionID] | /app:ApplicationResponse/cbc:ResponseDate | /app:ApplicationResponse/cbc:ResponseTime | /app:ApplicationResponse/cbc:UBLVersionID | /app:ApplicationResponse/cbc:UUID | /app:ApplicationResponse/cbc:VersionID | /app:ApplicationResponse/ext:UBLExtensions"
                 priority="1000"
                 mode="M10">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/app:ApplicationResponse/cac:DocumentResponse/cac:DocumentReference/cac:Attachment | /app:ApplicationResponse/cac:DocumentResponse/cac:DocumentReference/cac:IssuerParty | /app:ApplicationResponse/cac:DocumentResponse/cac:DocumentReference/cac:ResultOfVerification | /app:ApplicationResponse/cac:DocumentResponse/cac:DocumentReference/cac:ValidityPeriod | /app:ApplicationResponse/cac:DocumentResponse/cac:DocumentReference/cbc:CopyIndicator | /app:ApplicationResponse/cac:DocumentResponse/cac:DocumentReference/cbc:DocumentDescription | /app:ApplicationResponse/cac:DocumentResponse/cac:DocumentReference/cbc:DocumentStatusCode | /app:ApplicationResponse/cac:DocumentResponse/cac:DocumentReference/cbc:DocumentType | /app:ApplicationResponse/cac:DocumentResponse/cac:DocumentReference/cbc:DocumentTypeCode | /app:ApplicationResponse/cac:DocumentResponse/cac:DocumentReference/cbc:ID[@schemeAgencyID] | /app:ApplicationResponse/cac:DocumentResponse/cac:DocumentReference/cbc:ID[@schemeAgencyName] | /app:ApplicationResponse/cac:DocumentResponse/cac:DocumentReference/cbc:ID[@schemeDataURI] | /app:ApplicationResponse/cac:DocumentResponse/cac:DocumentReference/cbc:ID[@schemeID] | /app:ApplicationResponse/cac:DocumentResponse/cac:DocumentReference/cbc:ID[@schemeName] | /app:ApplicationResponse/cac:DocumentResponse/cac:DocumentReference/cbc:ID[@schemeURI] | /app:ApplicationResponse/cac:DocumentResponse/cac:DocumentReference/cbc:ID[@schemeVersionID] | /app:ApplicationResponse/cac:DocumentResponse/cac:DocumentReference/cbc:IssueDate | /app:ApplicationResponse/cac:DocumentResponse/cac:DocumentReference/cbc:IssueTime | /app:ApplicationResponse/cac:DocumentResponse/cac:DocumentReference/cbc:LanguageID | /app:ApplicationResponse/cac:DocumentResponse/cac:DocumentReference/cbc:LocaleCode | /app:ApplicationResponse/cac:DocumentResponse/cac:DocumentReference/cbc:UUID | /app:ApplicationResponse/cac:DocumentResponse/cac:DocumentReference/cbc:VersionID | /app:ApplicationResponse/cac:DocumentResponse/cac:DocumentReference/cbc:XPath | /app:ApplicationResponse/cac:DocumentResponse/cac:IssuerParty | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:LineReference/cac:DocumentReference | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:LineReference/cbc:LineID[@schemeAgencyID] | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:LineReference/cbc:LineID[@schemeAgencyName] | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:LineReference/cbc:LineID[@schemeDataURI] | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:LineReference/cbc:LineID[@schemeID] | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:LineReference/cbc:LineID[@schemeName] | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:LineReference/cbc:LineID[@schemeURI] | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:LineReference/cbc:LineID[@schemeVersionID] | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:LineReference/cbc:LineStatusCode | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:LineReference/cbc:UUID | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cac:Status/cac:Condition | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cac:Status/cbc:ConditionCode | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cac:Status/cbc:Description | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cac:Status/cbc:IndicationIndicator | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cac:Status/cbc:Percent | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cac:Status/cbc:ReferenceDate | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cac:Status/cbc:ReferenceTime | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cac:Status/cbc:ReliabilityPercent | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cac:Status/cbc:SequenceID | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cac:Status/cbc:StatusReasonCode[@languageID] | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cac:Status/cbc:StatusReasonCode[@listAgencyID] | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cac:Status/cbc:StatusReasonCode[@listAgencyName] | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cac:Status/cbc:StatusReasonCode[@listID] | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cac:Status/cbc:StatusReasonCode[@listName] | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cac:Status/cbc:StatusReasonCode[@listSchemeURI] | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cac:Status/cbc:StatusReasonCode[@listURI] | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cac:Status/cbc:StatusReasonCode[@listVersionID] | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cac:Status/cbc:StatusReasonCode[@name] | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cac:Status/cbc:StatusReason[@languageID] | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cac:Status/cbc:StatusReason[@languageLocaleID] | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cac:Status/cbc:Text | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cbc:Description | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cbc:EffectiveDate | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cbc:EffectiveTime | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cbc:ReferenceID | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cbc:ResponseCode[@languageID] | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cbc:ResponseCode[@listAgencyID] | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cbc:ResponseCode[@listAgencyName] | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cbc:ResponseCode[@listID] | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cbc:ResponseCode[@listName] | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cbc:ResponseCode[@listSchemeURI] | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cbc:ResponseCode[@listURI] | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cbc:ResponseCode[@listVersionID] | /app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cbc:ResponseCode[@name] | /app:ApplicationResponse/cac:DocumentResponse/cac:RecipientParty | /app:ApplicationResponse/cac:DocumentResponse/cac:Response/cac:Status | /app:ApplicationResponse/cac:DocumentResponse/cac:Response/cbc:Description | /app:ApplicationResponse/cac:DocumentResponse/cac:Response/cbc:EffectiveDate | /app:ApplicationResponse/cac:DocumentResponse/cac:Response/cbc:EffectiveTime | /app:ApplicationResponse/cac:DocumentResponse/cac:Response/cbc:ReferenceID | /app:ApplicationResponse/cac:DocumentResponse/cac:Response/cbc:ResponseCode[@languageID] | /app:ApplicationResponse/cac:DocumentResponse/cac:Response/cbc:ResponseCode[@listAgencyID] | /app:ApplicationResponse/cac:DocumentResponse/cac:Response/cbc:ResponseCode[@listAgencyName] | /app:ApplicationResponse/cac:DocumentResponse/cac:Response/cbc:ResponseCode[@listID] | /app:ApplicationResponse/cac:DocumentResponse/cac:Response/cbc:ResponseCode[@listName] | /app:ApplicationResponse/cac:DocumentResponse/cac:Response/cbc:ResponseCode[@listSchemeURI] | /app:ApplicationResponse/cac:DocumentResponse/cac:Response/cbc:ResponseCode[@listURI] | /app:ApplicationResponse/cac:DocumentResponse/cac:Response/cbc:ResponseCode[@listVersionID] | /app:ApplicationResponse/cac:DocumentResponse/cac:Response/cbc:ResponseCode[@name] | /app:ApplicationResponse/cac:ReceiverParty/cac:AgentParty | /app:ApplicationResponse/cac:ReceiverParty/cac:Contact | /app:ApplicationResponse/cac:ReceiverParty/cac:FinancialAccount | /app:ApplicationResponse/cac:ReceiverParty/cac:Language | /app:ApplicationResponse/cac:ReceiverParty/cac:PartyIdentification | /app:ApplicationResponse/cac:ReceiverParty/cac:PartyLegalEntity | /app:ApplicationResponse/cac:ReceiverParty/cac:PartyName | /app:ApplicationResponse/cac:ReceiverParty/cac:PartyTaxScheme | /app:ApplicationResponse/cac:ReceiverParty/cac:Person | /app:ApplicationResponse/cac:ReceiverParty/cac:PhysicalLocation | /app:ApplicationResponse/cac:ReceiverParty/cac:PostalAddress | /app:ApplicationResponse/cac:ReceiverParty/cac:PowerOfAttorney | /app:ApplicationResponse/cac:ReceiverParty/cac:ServiceProviderParty | /app:ApplicationResponse/cac:ReceiverParty/cbc:EndpointID[@schemeAgencyID] | /app:ApplicationResponse/cac:ReceiverParty/cbc:EndpointID[@schemeAgencyName] | /app:ApplicationResponse/cac:ReceiverParty/cbc:EndpointID[@schemeDataURI] | /app:ApplicationResponse/cac:ReceiverParty/cbc:EndpointID[@schemeName] | /app:ApplicationResponse/cac:ReceiverParty/cbc:EndpointID[@schemeURI] | /app:ApplicationResponse/cac:ReceiverParty/cbc:EndpointID[@schemeVersionID] | /app:ApplicationResponse/cac:ReceiverParty/cbc:IndustryClassificationCode | /app:ApplicationResponse/cac:ReceiverParty/cbc:LogoReferenceID | /app:ApplicationResponse/cac:ReceiverParty/cbc:MarkAttentionIndicator | /app:ApplicationResponse/cac:ReceiverParty/cbc:MarkCareIndicator | /app:ApplicationResponse/cac:ReceiverParty/cbc:WebsiteURI | /app:ApplicationResponse/cac:SenderParty/cac:AgentParty | /app:ApplicationResponse/cac:SenderParty/cac:Contact | /app:ApplicationResponse/cac:SenderParty/cac:FinancialAccount | /app:ApplicationResponse/cac:SenderParty/cac:Language | /app:ApplicationResponse/cac:SenderParty/cac:PartyIdentification | /app:ApplicationResponse/cac:SenderParty/cac:PartyLegalEntity | /app:ApplicationResponse/cac:SenderParty/cac:PartyName | /app:ApplicationResponse/cac:SenderParty/cac:PartyTaxScheme | /app:ApplicationResponse/cac:SenderParty/cac:Person | /app:ApplicationResponse/cac:SenderParty/cac:PhysicalLocation | /app:ApplicationResponse/cac:SenderParty/cac:PostalAddress | /app:ApplicationResponse/cac:SenderParty/cac:PowerOfAttorney | /app:ApplicationResponse/cac:SenderParty/cac:ServiceProviderParty | /app:ApplicationResponse/cac:SenderParty/cbc:EndpointID[@schemeAgencyID] | /app:ApplicationResponse/cac:SenderParty/cbc:EndpointID[@schemeAgencyName] | /app:ApplicationResponse/cac:SenderParty/cbc:EndpointID[@schemeDataURI] | /app:ApplicationResponse/cac:SenderParty/cbc:EndpointID[@schemeName] | /app:ApplicationResponse/cac:SenderParty/cbc:EndpointID[@schemeURI] | /app:ApplicationResponse/cac:SenderParty/cbc:EndpointID[@schemeVersionID] | /app:ApplicationResponse/cac:SenderParty/cbc:IndustryClassificationCode | /app:ApplicationResponse/cac:SenderParty/cbc:LogoReferenceID | /app:ApplicationResponse/cac:SenderParty/cbc:MarkAttentionIndicator | /app:ApplicationResponse/cac:SenderParty/cbc:MarkCareIndicator | /app:ApplicationResponse/cac:SenderParty/cbc:WebsiteURI | /app:ApplicationResponse/cac:Signature | /app:ApplicationResponse/cbc:CustomizationID[@schemeAgencyID] | /app:ApplicationResponse/cbc:CustomizationID[@schemeAgencyName] | /app:ApplicationResponse/cbc:CustomizationID[@schemeDataURI] | /app:ApplicationResponse/cbc:CustomizationID[@schemeID] | /app:ApplicationResponse/cbc:CustomizationID[@schemeName] | /app:ApplicationResponse/cbc:CustomizationID[@schemeURI] | /app:ApplicationResponse/cbc:CustomizationID[@schemeVersionID] | /app:ApplicationResponse/cbc:ID[@schemeAgencyID] | /app:ApplicationResponse/cbc:ID[@schemeAgencyName] | /app:ApplicationResponse/cbc:ID[@schemeDataURI] | /app:ApplicationResponse/cbc:ID[@schemeID] | /app:ApplicationResponse/cbc:ID[@schemeName] | /app:ApplicationResponse/cbc:ID[@schemeURI] | /app:ApplicationResponse/cbc:ID[@schemeVersionID] | /app:ApplicationResponse/cbc:Note | /app:ApplicationResponse/cbc:ProfileExecutionID | /app:ApplicationResponse/cbc:ProfileID[@schemeAgencyID] | /app:ApplicationResponse/cbc:ProfileID[@schemeAgencyName] | /app:ApplicationResponse/cbc:ProfileID[@schemeDataURI] | /app:ApplicationResponse/cbc:ProfileID[@schemeID] | /app:ApplicationResponse/cbc:ProfileID[@schemeName] | /app:ApplicationResponse/cbc:ProfileID[@schemeURI] | /app:ApplicationResponse/cbc:ProfileID[@schemeVersionID] | /app:ApplicationResponse/cbc:ResponseDate | /app:ApplicationResponse/cbc:ResponseTime | /app:ApplicationResponse/cbc:UBLVersionID | /app:ApplicationResponse/cbc:UUID | /app:ApplicationResponse/cbc:VersionID | /app:ApplicationResponse/ext:UBLExtensions"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="false()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="false()">
               <xsl:attribute name="id">R1-APP</xsl:attribute>
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Endast XML-element och attribut som angivits i denna specifikation får användas</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M10"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M10"/>
   <xsl:template match="@*|node()" priority="-2" mode="M10">
      <xsl:apply-templates select="*" mode="M10"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="/app:ApplicationResponse" priority="1007" mode="M11">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/app:ApplicationResponse"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="exists(cbc:CustomizationID)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="exists(cbc:CustomizationID)">
               <xsl:attribute name="id">R9-APP</xsl:attribute>
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>CustomizationID är obligatoriskt. Element och attribut ska anges i enlighet med den tillåtna kardinalitet som framgår i syntaxmappningen.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="exists(cbc:ProfileID)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="exists(cbc:ProfileID)">
               <xsl:attribute name="id">R9-APP</xsl:attribute>
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>ProfileID är obligatoriskt. Element och attribut ska anges i enlighet med den tillåtna kardinalitet som framgår i syntaxmappningen.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="exists(cbc:IssueTime)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="exists(cbc:IssueTime)">
               <xsl:attribute name="id">R9-APP</xsl:attribute>
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>IssueTime är obligatoriskt. Element och attribut ska anges i enlighet med den tillåtna kardinalitet som framgår i syntaxmappningen.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="count(cac:DocumentResponse)=1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(cac:DocumentResponse)=1">
               <xsl:attribute name="id">R9-APP</xsl:attribute>
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>ApplicationResponse/DocumentResponse ska anges 1 gång. Element och attribut ska anges i enlighet med den tillåtna kardinalitet som framgår i syntaxmappningen.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M11"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="/app:ApplicationResponse/cac:DocumentResponse"
                 priority="1006"
                 mode="M11">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/app:ApplicationResponse/cac:DocumentResponse"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="count(cac:DocumentReference)=1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(cac:DocumentReference)=1">
               <xsl:attribute name="id">R9-APP</xsl:attribute>
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>ApplicationResponse/DocumentResponse/DocumentReference ska anges 1 gång. Element och attribut ska anges i enlighet med den tillåtna kardinalitet som framgår i syntaxmappningen.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M11"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="/app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse"
                 priority="1005"
                 mode="M11">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="count(cac:Response)=1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(cac:Response)=1">
               <xsl:attribute name="id">R9-APP</xsl:attribute>
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>ApplicationResponse/DocumentResponse/LineResponse/Response ska anges 1 gång. Element och attribut ska anges i enlighet med den tillåtna kardinalitet som framgår i syntaxmappningen.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M11"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="/app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response"
                 priority="1004"
                 mode="M11">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="count(cbc:ResponseCode)=1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(cbc:ResponseCode)=1">
               <xsl:attribute name="id">R9-APP</xsl:attribute>
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>ApplicationResponse/DocumentResponse/LineResponse/Response/ResponseCode ska anges 1 gång. Element och attribut ska anges i enlighet med den tillåtna kardinalitet som framgår i syntaxmappningen.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="count(cac:Status)=1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(cac:Status)=1">
               <xsl:attribute name="id">R9-APP</xsl:attribute>
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>ApplicationResponse/DocumentResponse/LineResponse/Response/Status ska anges 1 gång. Element och attribut ska anges i enlighet med den tillåtna kardinalitet som framgår i syntaxmappningen.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M11"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="/app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cac:Status"
                 priority="1003"
                 mode="M11">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cac:Status"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="count(cbc:StatusReason)=1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(cbc:StatusReason)=1">
               <xsl:attribute name="id">R9-APP</xsl:attribute>
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>ApplicationResponse/DocumentResponse/LineResponse/Response/Status/StatusReason ska anges 1 gång. Element och attribut ska anges i enlighet med den tillåtna kardinalitet som framgår i syntaxmappningen.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M11"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="/app:ApplicationResponse/cac:DocumentResponse/cac:Response"
                 priority="1002"
                 mode="M11">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/app:ApplicationResponse/cac:DocumentResponse/cac:Response"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="count(cbc:ResponseCode)=1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(cbc:ResponseCode)=1">
               <xsl:attribute name="id">R9-APP</xsl:attribute>
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>ApplicationResponse/DocumentResponse/Response/ResponseCode ska anges 1 gång. Element och attribut ska anges i enlighet med den tillåtna kardinalitet som framgår i syntaxmappningen.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M11"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="/app:ApplicationResponse/cac:ReceiverParty"
                 priority="1001"
                 mode="M11">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/app:ApplicationResponse/cac:ReceiverParty"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="count(cbc:EndpointID)=1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(cbc:EndpointID)=1">
               <xsl:attribute name="id">R9-APP</xsl:attribute>
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>ApplicationResponse/ReceiverParty/EndpointID" ska anges 1 gång. Element och attribut ska anges i enlighet med den tillåtna kardinalitet som framgår i syntaxmappningen.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="cbc:EndpointID/@schemeID"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="cbc:EndpointID/@schemeID">
               <xsl:attribute name="id">R9-APP</xsl:attribute>
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>EndpointID/@schemeID är obligatorisk att ange. Element och attribut ska anges i enlighet med den tillåtna kardinalitet som framgår i syntaxmappningen.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M11"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="/app:ApplicationResponse/cac:SenderParty"
                 priority="1000"
                 mode="M11">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/app:ApplicationResponse/cac:SenderParty"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="count(cbc:EndpointID)=1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count(cbc:EndpointID)=1">
               <xsl:attribute name="id">R9-APP</xsl:attribute>
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>ApplicationResponse/SenderParty/EndpointID" ska anges 1 gång. Element och attribut ska anges i enlighet med den tillåtna kardinalitet som framgår i syntaxmappningen.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="cbc:EndpointID/@schemeID"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="cbc:EndpointID/@schemeID">
               <xsl:attribute name="id">R9-APP</xsl:attribute>
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>EndpointID/@schemeID är obligatorisk att ange. Element och attribut ska anges i enlighet med den tillåtna kardinalitet som framgår i syntaxmappningen.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M11"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M11"/>
   <xsl:template match="@*|node()" priority="-2" mode="M11">
      <xsl:apply-templates select="*" mode="M11"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="//*[not(*) and not(normalize-space())]"
                 priority="1000"
                 mode="M12">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="//*[not(*) and not(normalize-space())]"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="false() or (namespace-uri(.)='http://www.w3.org/2001/04/xmlenc#' or namespace-uri(.)='http://www.w3.org/2000/09/xmldsig#')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="false() or (namespace-uri(.)='http://www.w3.org/2001/04/xmlenc#' or namespace-uri(.)='http://www.w3.org/2000/09/xmldsig#')">
               <xsl:attribute name="id">R2-APP</xsl:attribute>
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Tomma element eller attribut får inte anges</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M12"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M12"/>
   <xsl:template match="@*|node()" priority="-2" mode="M12">
      <xsl:apply-templates select="*" mode="M12"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="/app:ApplicationResponse" priority="1002" mode="M13">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/app:ApplicationResponse"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="normalize-space(cbc:CustomizationID)='urn:fdc:digg.se:edelivery:messagetype:response:1'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="normalize-space(cbc:CustomizationID)='urn:fdc:digg.se:edelivery:messagetype:response:1'">
               <xsl:attribute name="id">R3-APP</xsl:attribute>
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>CustomizationID måste ha korrekt värde enligt kodlista</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="normalize-space(cbc:ProfileID)='bdx:noprocess'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="normalize-space(cbc:ProfileID)='bdx:noprocess'">
               <xsl:attribute name="id">R4-APP</xsl:attribute>
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>ProfileID måste ha korrekt värde enligt kodlista</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M13"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="/app:ApplicationResponse/cac:DocumentResponse/cac:Response/cbc:ResponseCode"
                 priority="1001"
                 mode="M13">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/app:ApplicationResponse/cac:DocumentResponse/cac:Response/cbc:ResponseCode"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="normalize-space(.)='REJECTED' or normalize-space(.)='ACCEPTED'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="normalize-space(.)='REJECTED' or normalize-space(.)='ACCEPTED'">
               <xsl:attribute name="id">R5-APP</xsl:attribute>
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Kvittenskod (cac:DocumentResponse/cbc:ResponseCode) ska använda giltig kod enligt kodlista</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M13"/>
   </xsl:template>
   <!--RULE -->
   <xsl:template match="/app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cbc:ResponseCode"
                 priority="1000"
                 mode="M13">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/app:ApplicationResponse/cac:DocumentResponse/cac:LineResponse/cac:Response/cbc:ResponseCode"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="normalize-space(.)='SV' or normalize-space(.)='BV' or normalize-space(.)='SIG'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="normalize-space(.)='SV' or normalize-space(.)='BV' or normalize-space(.)='SIG'">
               <xsl:attribute name="id">R6-APP</xsl:attribute>
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>Orsakskod (cac:LineResponse/cac:Response/cbc:ResponseCode) ska använda giltig kod enligt kodlista
</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M13"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M13"/>
   <xsl:template match="@*|node()" priority="-2" mode="M13">
      <xsl:apply-templates select="*" mode="M13"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="/app:ApplicationResponse/cac:DocumentResponse/cac:Response[cbc:ResponseCode='ACCEPTED']"
                 priority="1000"
                 mode="M14">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/app:ApplicationResponse/cac:DocumentResponse/cac:Response[cbc:ResponseCode='ACCEPTED']"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="not(exists(//cac:LineResponse))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(exists(//cac:LineResponse))">
               <xsl:attribute name="id">R7-APP</xsl:attribute>
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>En kvittens med status ACCEPTED ska inte ha några orsakskoder</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M14"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M14"/>
   <xsl:template match="@*|node()" priority="-2" mode="M14">
      <xsl:apply-templates select="*" mode="M14"/>
   </xsl:template>
   <!--PATTERN -->
   <!--RULE -->
   <xsl:template match="/app:ApplicationResponse/cac:DocumentResponse/cac:Response[cbc:ResponseCode='REJECTED']"
                 priority="1000"
                 mode="M15">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/app:ApplicationResponse/cac:DocumentResponse/cac:Response[cbc:ResponseCode='REJECTED']"/>
      <!--ASSERT -->
      <xsl:choose>
         <xsl:when test="exists(//cac:LineResponse)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="exists(//cac:LineResponse)">
               <xsl:attribute name="id">R8-APP</xsl:attribute>
               <xsl:attribute name="flag">fatal</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>En kvittens med status REJECTED måste ha minst en orsakskod</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M15"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M15"/>
   <xsl:template match="@*|node()" priority="-2" mode="M15">
      <xsl:apply-templates select="*" mode="M15"/>
   </xsl:template>
</xsl:stylesheet>

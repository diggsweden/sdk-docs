# Säker digital kommunikation
## Domibus P-mode

TODO introduktionstext

Inera info 
https://inera.atlassian.net/wiki/spaces/OISDK/pages/2793865227/Konfiguration+av+Certifikat+-+Accesspunkt#eDelivery/AS4

## eDelivery/AS4 
De kryptografiska säkerhetsfunktionerna för kommunikation med protokollet eDelivery/AS4 konfigureras i Accesspunkten.

Accesspunktens certifikat (publika nyckel) laddas även upp till metadatatjänst SMP (i samband med accesspunktsoperatörens registrering av deltagare till DIGG).

## PMode
Anpassning av konfiguration Processing Mode (PMode) krävs för korrekt hantering av aktuella certifikat i eDelivery.

Se Konfiguration [Domibus](../P-mode/p-mode.xml) Accesspunkt för ett komplett exempel på PMode-konfiguration.


## PartyId
“Common Name” (CN) i organisationens certifikat måste överensstämma med PartyId “name” i accespunktens PMode-konfiguration. Common Name för eDelivery/AS4-certifikat bestäms av utgivaren (DIGG).

Exempel nedan, ```CN = AP0001-SDK-QA```


```xml
<parties>
  <partyIdTypes>
      <partyIdType name="partyTypeUrn" value="urn:fdc:digg.se:edelivery:transportprofile:as4:partytype:ap"/>
  </partyIdTypes>
  <party name="AP0001-SDK-QA" endpoint="https://at-ap-sdk.ipaas.inera.se/domibus/services/msh">
      <identifier partyId="AP0001-SDK-QA" partyIdType="partyTypeUrn"/>
  </party>
</parties>
```
### Security
För att lita på meddelanden från avsändare vars certifikat är utställd av godkända och betrodda CAs (DIGG eDelivery CA) behöver “security” konfigureras enligt:


```xml
<securities>
			<security name="eDeliveryAS4Policy_BST" 
			policy="eDeliveryAS4Policy_BST.xml" 
			signatureMethod="RSA_SHA256"/>
</securities>
```
Elementet refereras vid namn från andra delar i XML-strukturen - “legConfiguration” attribut “security”. Vid byte av “name” ovan (ej strikt nödvändigt, gamla kan behållas) behöver attributet “security” i “legConfiguration” uppdateras:


```xml
<legConfigurations>
         <legConfiguration name="messageWithAttachment"
                       service="messageService"
                       action="messageAction"
                       defaultMpc="defaultMpc"
                       reliability="AS4Reliability"
                       security="eDeliveryAS4Policy_BST"<!-- Referens till Security.name -->
                       receptionAwareness="receptionAwareness"
                       propertySet="eDeliveryPropertySet"
                       payloadProfile="MessageProfile"
                       errorHandling="demoErrorHandling"
                       compressPayloads="true"/><!-- Adjusted security attribute For Dyn. Disc. -->
         <legConfiguration name="messageReceipt"
                       service="receiptService"
                       action="receiptAction"
                       defaultMpc="defaultMpc"
                       reliability="AS4Reliability"
                       security="eDeliveryAS4Policy_BST"<!-- Referens till Security.name -->
                       receptionAwareness="receptionAwareness"
                       propertySet="eDeliveryPropertySet"
                       payloadProfile="MessageProfile"
                       errorHandling="demoErrorHandling"
                       compressPayloads="true"/><!-- Adjusted security attribute For Dyn. Disc. -->
      </legConfigurations>
```
### Keystore
Transportlagrets keystore för eDelivery/AS4 utgörs av användarorganisationens privata nyckel samt certifikat.

Keystore konfigureras i Domibus med följande attribut i domibus.properties.


```
domibus.security.keystore.type=$DOMIBUS_SECURITY_KEYSTORE_TYPE
domibus.security.keystore.location=$DOMIBUS_SECURITY_KEYSTORE_LOCATION
domibus.security.keystore.password=$DOMIBUS_SECURITY_KEYSTORE_PASSWORD
```

### Truststore
Transportlagrets truststore för eDelivery/AS4 behöver innehålla  :

Certifikatkedja för eDelivery/AS4. Används för att etablera tillit till andra accesspunkters certifikat. 

Certifikatkedja för SMP. Detta används för att validera signaturen på information från Metadatatjänst SMP.

Båda certifikatkedjor ovan tillhandahålls av DIGG och är specifika per miljö (ex. QA / PROD) - se Anslutningsinformation - [Certifikatskedjor](/Certifikatskedjor/).

Truststore konfigureras i Domibus med följande attribut i domibus.properties.

```
domibus.security.truststore.type=$DOMIBUS_SECURITY_KEYSTORE_TYPE
domibus.security.truststore.location=$DOMIBUS_SECURITY_KEYSTORE_LOCATION
domibus.security.truststore.password=$DOMIBUS_SECURITY_KEYSTORE_PASSWORD
```

### Transportkryptering (HTTPS/TLS)

Transportlagrets transportkryptering sker över nätverksprotokollet HTTPS/TLS och kräver en separat uppsättning certifikat.

Dessa servercertifikat skall ha CN (“Common Name”) satt till det publikt adresserbara domännamn som gäller för Accesspunkten

#### Introduktion
Konfigurationen för TLS beror på den infrastruktur som används, framför accesspunkten har man vanligtvis ett skalskydd i form av en sk. Reverse Proxy. Den komponent som agerar klient respektive server måste konfigureras korrekt för att kommunikationen skall fungera.

Accesspunkter i SDK kommunicerar över internet med det krypterade nätverksprotokollet TLS och ömsesidig TLS-autentisering - sk “Two-way”  eller “Mutual TLS Authentication” - benämns vidare mTLS. mTLS utökar standard-TLS genom att även klienten måste presentera ett för servern betrott certifikat.

Grunden för autentisering via TLS är tillit till certifikat mellan parterna (klient och server), en part anses vara autentiserad i det fall denne kan presentera ett certifikat som den andra parten kan validera är utställt av en betrodd certifikatutfärdare. 

### Keystore
Keystore innehåller certifikat som skickas till motparten i syfte att autentisera parter (mTLS) samt kryptera nätverkstrafiken över internet.

Transportlagrets keystore för transportkryptering (TLS) och mTLS utgörs av privat nyckel samt certifikat (och publik nyckel).

### Truststore
Truststore innehåller certifikat som syftar till att autentisera motpart när denne skickar sitt certifikat. 

Transportlagrets truststore för transportkryptering (TLS) behöver innehålla certifikatkedja till godkänd certifikatutställare för TLS inom SDK (SITHS) - så att man litar på / autentiserar anrop där parten kan presentera ett certifikat som är utfärdat av korrekt CA.

Exempel nedan lägger till certifikatkedja för SITHS TEST till en ny Truststore. (Exempel med Java 11. Sedan Java 9 är standarformatet PKCS12. Java 8 använder legacy JKS.) 


```
keytool -importcert -alias 'TEST SITHS e-id Function CA v1' -storepass changeit -noprompt -trustcacerts -file siths-may2020-keystores/test_siths_e-id_function_ca_v1.cer -keystore siths_test_common_tls_truststore.p12
keytool -importcert -alias 'TEST SITHS e-id Root CA v2' -storepass changeit -noprompt -trustcacerts -file siths-may2020-keystores/test_siths_e-id_root_ca_v2.cer -keystore siths_test_common_tls_truststore.p12
keytool --list -storepass changeit -v -keystore siths_test_common_tls_truststore.p12
```
Se Certifikat för nedladdning av [Certifikatskedjor](/Certifikatskedjor/).

### Konfiguration av accesspunkt Domibus
Klientkonfiguration
Domibus använder sig av mjukvarubiblioteket Apache CXF för utgående kommunikation. På transportlagernivå behöver biblioteket konfigureras med Keystore och Truststore för mTLS. Detta beskrivs i Domibus Admin Guide kapitel 14 “TLS Configuration”.

Exempel på Apache CXF klientkonfiguration som används i SDKs Testbädd, notera användandet av miljövariabler för att ange pekare till Trust- och Keystores.


```xml
<http-conf:tlsClientParameters disableCNCheck="true" secureSocketProtocol="TLSv1.2"
        xmlns:http-conf="http://cxf.apache.org/transports/http/configuration"
                               xmlns:security="http://cxf.apache.org/configuration/security">
    <security:trustManagers>
        <security:keyStore type="${domibus.security.tls.truststore.type}" password="${domibus.security.tls.truststore.password}"
                           file="${domibus.security.tls.truststore}"/><!-- Absolute path and file name -->
    </security:trustManagers>
    <security:keyManagers keyPassword="${domibus.security.tls.keystore.password}">
        <security:keyStore type="${domibus.security.tls.keystore.type}" password="${domibus.security.tls.keystore.password}"
                           file="${domibus.security.tls.keystore}"/><!-- Absolute path and file name -->
    </security:keyManagers>
</http-conf:tlsClientParameters>
```

### Serverkonfiguration
Ett rekommenderat mönster är att inkommande TLS-trafik termineras i ett skalskydd inom en nätverkssegment som har tillgång till internet (DMZ). I det scenariot är accesspunkten inte server. “Servern” är den part som terminerar TLS-trafiken. 

I det fall man låter Domibus vara faktiskt termineringspunkt (server): 

Keystore och Truststore för mTLS måste konfigureras för aktuell serverttyp ex Apache Tomcat. Se Domibus Admin Guide kapitel 14 “TLS Configuration” - sektion “Server Side Configuration” för mer information. 
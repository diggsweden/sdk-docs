# Säker digital kommunikation

## Truststore - SDK QA
Paketerade truststores för miljön SDK QA
Tillhandahålls både som p12 och jks

Nedan finns truststores att ladda ned sorterat på komponent (lager) och miljö. Filerna är endast tänkta som hjälp för en organisation att komma igång med att bygga upp sin egen truststore.
Lösenordet är det samma till samtliga filer: p@ssword

Följande kommandon kan t.ex. användas för att ta del av innehållet i filerna:

openssl:
openssl pkcs12 -legacy -nokeys -info -in <fil> -passin pass:p@ssword

keytool:
keytool -list -v -keystore <fil> -storepass p@ssword -storetype pkcs12

### Meddelandetjänst

Används i följande gränssnitt:

Meddelandetjänst -> Certifikatpubliceringstjänst

Certifikatpubliceringstjänst -> Meddelandetjänst

Notera: O2O-certifikatens CA behöver inte inkluderas i truststore. Integriteten ges genom TLS samt eventuell siganturvalidering av SMP-metadata med nedanstående certifikat.


| Filnamn                         | Innehåll (PKCS12)                                          |
| --------------------------------- | ------------------------------------------------------------- |
| o2o-sdk-qa.p12 | SDK-QA Certifikatkedja SMP<br /> -Rot CA eDelivery SMP-QA |


### Accesspunkt
Används i följande gränssnitt:

Accesspunkt -> Accesspunkt

Accesspunkt -> SMP

SMP -> Accesspunkt

| Filnamn                         | Innehåll (PKCS12)                                          |
| --------------------------------- | ------------------------------------------------------------- |
|as4-sdk-qa-truststore.p12 | SDK-QA Certifikatkedja AP<br />-Accesspunkt CA-SDK-QA<br />-Rot CA eDelivery Accesspunkt-QA<br /><br />SDK-QA Certifikatkedja SMP<br />-Rot CA eDelivery SMP-QA |


### Accesspunkt / Termineringspunkt (transportlager)
Används i följande gränssnitt:

Accesspunkt -> Termineringspunkt (Accesspunkt)

| Filnamn                         | Innehåll (PKCS12)                                          |
| --------------------------------- | ------------------------------------------------------------- |
|mtls-opentest-truststore.p12 | SDK-QA Certifikatkedja AP<br />-Accesspunkt CA-SDK-QA<br />-Rot CA eDelivery Accesspunkt-QA<br /><br />SDK-QA Certifikatkedja SMP<br />-Rot CA eDelivery SMP-QA |



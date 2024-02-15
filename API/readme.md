# Säker digital kommunikation

## API MT/MK

B1.4.2 - SDK_Rekommendation API MT-MK

Aktörer så som leverantörer och deltagarorganisationer har efterfrågat en API-standardisering för informationsutbyte mellan accesspunkt, meddelandetjänst och meddelandeklient.

* Deltagarorganisationer efterfrågar API för att underlätta kravställning mot leverantörer och minska risk för leverantörsinlåsning.
* Leverantörer efterfrågar standardiserade gränssnitt för att underlätta utveckling och anpassning av systemkomponenter/mjukvara.

SDK API (“standardiserat API“) är primärt framtaget för att standardisera informationsöverföring mellan serverkomponenterna “meddelandetjänst” (MT) och “meddelandeklient/verksamhetssystem” (MK).
SDK API ska möjliggöra en så kallad “lös koppling” mellan komponenterna MT och MK.

* SDK API är framtaget för att stödja “system till system”-kommunikation.
* SDK API stödjer dokument typ (mMeddelandetyp) “urn:riv:infrastructure:messaging:MessageWithAttachments:3“.

SDK API (REST API) är beskrivet (kontrakt) enligt
specifikationen openAPI (version 3.1.x) och är utformat enligt/inspirerat av
JSON:API.


[Länk till dokumentation B1.4.2 Rekommendation API MT/MK](../API/B1.4.2%20-%20Rekommendation%20API%20MT-MK.pdf)

[Länk openAPI specifikation för API MT/MK](../API/sdk-api-restful.yml)


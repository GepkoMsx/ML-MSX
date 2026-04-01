(ctrl+shift +v)
# High-Speed Commando's (H-serie)
Deze zijn geoptimaliseerd voor snelheid en werken op byte-niveau zonder rekening te houden met individuele pixels (behalve de coördinaten). 
Ze ondersteunen geen logische operaties. 

- HMMM (High-speed Move VRAM to VRAM): Kopieert een rechthoekig blok razendsnel van de ene plek in het video-geheugen naar de andere.
- HMMV (High-speed Move VDP to VRAM): Vult een rechthoekig gebied in het VRAM met één specifieke kleur.
- HMMC (High-speed Move CPU to VRAM): Verplaatst data van de CPU (RAM) naar een rechthoekig gebied in het VRAM.
- HMCM (High-speed Move VRAM to CPU): Verplaatst data vanuit een rechthoekig gebied in het VRAM terug naar de CPU.
- YMMM (High-speed Move VRAM to VRAM, Y-direction): Een variant van HMMM die alleen in de verticale richting (Y) verschuift, vaak gebruikt voor snelle scrolling. 

# Logical Commando's (L-serie)
Deze commando's werken op pixel-niveau en laten je logische operaties loslaten op de data (zoals AND, OR, XOR of NOT).  
Ze zijn iets trager dan de H-serie maar bieden meer flexibiliteit. 

- LMMM (Logical Move VRAM to VRAM): Kopieert een blok met gebruik van logische operaties.
- LMMV (Logical Move VDP to VRAM): Vult een gebied met een kleur via een logische operatie.
- LMMC (Logical Move CPU to VRAM): Stuurt pixeldata van de CPU naar VRAM met logische bewerkingen.
- LMCM (Logical Move VRAM to CPU): Leest pixels uit VRAM naar de CPU. 

### Wist je dat? 
Hoewel deze commando's bedoeld zijn voor de bitmap-modi (Screen 5 t/m 8),  
kunnen ze op een MSX2 ook in Screen 0 t/m 4 gebruikt worden als je het scherm tijdelijk uitschakelt.

# registers
|Register |	Naam |	Functie |
|---|---|---|
|R#32 / R#33 |	SX	|Source X (Bron X-coördinaat)
|R#34 / R#35 |	SY	|Source Y (Bron Y-coördinaat)
|R#36 / R#37 |	DX	|Destination X (Bestemming X)
|R#38 / R#39 |	DY	|Destination Y (Bestemming Y)
|R#40 / R#41 |	NX	|Number X (Breedte in pixels)
|R#42 / R#43 | 	NY	|Number Y (Hoogte in pixels)
|R#44|	CLR	|Color (Kleur-byte of data-byte)
|R#45|	ARG	|Argument (Richting, Pagina en Logische Operatie)
|R#46|	CMD	|Command (De "Smaak" van het commando)

# Gebruikte waarden
|Commando|	Smaak	             |   Gebruikt deze registers	             |   CMD Code (R#46)|
|---|---|---|---|
|HMMM	|    VRAM -> VRAM (Snel)	|    SX, SY, DX, DY, NX, NY, 00， ARG	|    0xD0|
|LMMM	|    VRAM -> VRAM (Logisch)	|SX, SY, DX, DY, NX, NY, 00， ARG	   | 0x90|
|HMMV	|    VDP -> VRAM (Vullen)	|        DX, DY, NX, NY, CLR, ARG	   | 0xC0|
|LMMV	|    VDP -> VRAM (Logisch)	|        DX, DY, NX, NY, CLR, ARG	   | 0x80|
|HMMC	|    CPU -> VRAM (Snel)	    |        DX, DY, NX, NY, CLR, ARG	   | 0xF0|
|LMMC	|    CPU -> VRAM (Logisch)	|        DX, DY, NX, NY, CLR, ARG	   | 0xB0|
|HMCM	|    VRAM -> CPU (Snel)	    |SX, SY, 00, 00, NX, NY, 00， ARG	   | 0xE0  * NX != 0|
|LMCM	|    VRAM -> CPU (Logisch)	|SX, SY, 00, 00, NX, NY, 00， ARG	   | 0xA0|
|YMMM	|    Y-Verschuiving	        |SY, 00, DX, DY, 00, NY, 00， ARG	   | 0xE0  * NX = 0|
    
## Het Argument Register (R#45)
Dit register is de "finetuning" van je commando:  
- Bit 0-3 (LOp): Alleen voor de L-serie, bepaalt hoe je de kleur vervangt:
  - 0x00: IMP (D = S) Overschrijven (Standaard)
  - 0x01: AND (D = S AND D)	Alleen pixels die in beide staan blijven over
  - 0x02: OR (D = S OR D)	Kleuren "optellen" (vaak voor transparantie)
  - 0x03: XOR (D = S XOR D)	Kleuren omkeren (handig voor cursors)
  - 0x04: NOT (D = NOT S)	De bronkleur inverteren
  - Add 0x08 to make transaprant verion: (color 0 not used)
- Bit 4 (DIX): Richting X (0 = Rechts, 1 = Links).
- Bit 5 (DIY): Richting Y (0 = Omlaag, 1 = Omhoog).
- Bit 6 (MXS): Bron-pagina (altijd 0 = VRAM).
- Bit 7 (MXD): Bestemmings-pagina. (altijd 0 = VRAM)

Voor een normale H* is ARG dus 0x00

## Het Color register (R#44):
Alleen van toepassing voor *MMV en *MMC commando's:
- LMMV en HMMV: de vulkleur
- LMMC en HMMC: de kleur van het eerste pixel. Rest via poort 0x9B


# De 15-byte structuur 
|code | bytes | omschrijving |
|---|---|---|
|SX, SY |4 bytes| Bron-coördinaten  (soms niet van toepassing)  |
|DX, DY |4 bytes| Bestemmings-coördinaten  |
|NX, NY |4 bytes| Breedte en Hoogte  |
|CLR |1 byte| Kleur of data-byte  |
|ARG |1 byte| Richting en VRAM-pagina instellingen  |
|CMD |1 byte| Het eigenlijke commando  |

In de macro zijn SX, SY optioneel, ligt aan het commando, en het commando wordt door de macro verstuurd.   
Dit leidt tot een datablok van 10 of 14 bytes ipv altijd 15.
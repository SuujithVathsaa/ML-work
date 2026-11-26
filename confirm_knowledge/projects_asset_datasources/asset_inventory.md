# Confirm asset inventory (interpreted from Confirm_Asset_Features_with_attributes.xlsx)

Asset code and name carried down through merged / blank cells. `Required` is the workbook's YES/NO flag (mandatory in Confirm), **not** an include/exclude flag - every entry is included.

| Asset code | Asset name | Measurements | Attributes | Observations | Proposed data-source name |
|---|---|---|---|---|---|
| AA | Arboricultural Asset | 1 | 2 | 6 | Information Team – Asset Arboricultural Asset |
| DATS | Drainage Asset - Trash Screen | 1 | 3 | 7 | Information Team – Asset Drainage Asset - Trash Screen |
| DAGA | Drainage Asset - Gully | 1 | 2 | 6 | Information Team – Asset Drainage Asset - Gully |
| STBR | ST:Bridges & Culverts | 9 | 22 | 16 | Information Team – Asset ST:Bridges & Culverts |
| SRWP | ST:Retaining Wall Panel | 5 | 2 | 28 | Information Team – Asset ST:Retaining Wall Panel |
| STRW | ST:Retaining Wall | 5 | 20 | 15 | Information Team – Asset ST:Retaining Wall |
| STDM | ST:Dam | 5 | 10 | 0 | Information Team – Asset ST:Dam |
| SPAN | ST:Structure Span | 7 | 6 | 47 | Information Team – Asset ST:Structure Span |
| WGBC | Winter Asset - Bin | 3 | 10 | 2 | Information Team – Asset Winter Asset - Bin |
| WGPC | Winter Asset - Pile | 3 | 10 | 1 | Information Team – Asset Winter Asset - Pile |
| DAMA | Drainage Asset - Manholes | 2 | 8 | 3 | Information Team – Asset Drainage Asset - Manholes |
| DALA | Drainage Asset - Linear Asset | 1 | 5 | 0 | Information Team – Asset Drainage Asset - Linear Asset |
| **Total** | 12 assets | 43 | 100 | 131 | |

## AA – Arboricultural Asset
Data source: **Information Team – Asset Arboricultural Asset**

**Measurements** (1)

| Code | Name | Required |
|---|---|---|
| NO | Number Of | YES |

**Attributes** (2)

| Code | Name | Required |
|---|---|---|
| TALO | Tree Asset Likeley Owner | YES |
| TAT | Tree Asset Type | YES |

**Observations** (6)

| Code | Name | Required |
|---|---|---|
| WC | Work Completed | NO |
| TAH | Tree Asset Height | YES |
| TAG | Tree Asset Girth | YES |
| TACS | Tree Asset Crown Spread | YES |
| TAOC | Tree Asset Overall Condition | YES |
| TAM | Tree Asset Maturity | YES |


## DATS – Drainage Asset - Trash Screen
Data source: **Information Team – Asset Drainage Asset - Trash Screen**

**Measurements** (1)

| Code | Name | Required |
|---|---|---|
| NO | Number Of | NO |

**Attributes** (3)

| Code | Name | Required |
|---|---|---|
| DAFD | Drainage - Direction of Flow | YES |
| DOWN | Drainage - Likely Ownership | YES |
| TMR | Traffic Management Requirement | YES |

**Observations** (7)

| Code | Name | Required |
|---|---|---|
| WCON | Weather Condition | NO |
| SH02 | Confined Space | YES |
| SH04 | Deep Water | YES |
| SH05 | Difficult Access | YES |
| GCI | Asset Condition Information | YES |
| SLOA | Silt Level On Arrival | YES |
| GCON | Gully Containments | YES |


## DAGA – Drainage Asset - Gully
Data source: **Information Team – Asset Drainage Asset - Gully**

**Measurements** (1)

| Code | Name | Required |
|---|---|---|
| NO | Number Of | NO |

**Attributes** (2)

| Code | Name | Required |
|---|---|---|
| GAT | Gully Asset Type | YES |
| TMR | Traffic Management Requirement | YES |

**Observations** (6)

| Code | Name | Required |
|---|---|---|
| GCI | Asset Condition Information | YES |
| GACC | Accessibility | YES |
| SLOA | Silt Level On Arrival | YES |
| ACT | Action Taken | YES |
| GSOD | State On Departure | YES |
| GCON | Gully Containments | YES |


## STBR – ST:Bridges & Culverts
Data source: **Information Team – Asset ST:Bridges & Culverts**

**Measurements** (9)

| Code | Name | Required |
|---|---|---|
| NO | Number Of | NO |
| S001 | S:Skew (P) | NO |
| S002 | S:Width Between Parapets | NO |
| S003 | S:Carriageway Width | YES |
| S004 | S:Length | YES |
| S005 | S:Headroom | NO |
| S006 | S:No. Of Spans | NO |
| S007 | S:No. Of Construction Spans | YES |
| STCA | TK:Average Critical Headroom | YES |

**Attributes** (22)

| Code | Name | Required |
|---|---|---|
| ENST | TK:Environmentally Sensitive | NO |
| HERG | TK:Heritage | NO |
| LOC1 | TK:Location Type | NO |
| OBC1 | TK:Obstacle Crossed | NO |
| OBCS | TK:Obstacle Crossed Salted | NO |
| ROSA | TK:Route Salted | NO |
| RTL1 | TK:Route Traffic Level | NO |
| RTS1 | TK:Route Type Supported | NO |
| S006 | S:Parish | NO |
| S008 | S:Ancient Monument | NO |
| S009 | TK:Planning Conservation Area | NO |
| S011 | S:Listed Grade | NO |
| S014 | S:Prn | NO |
| S015 | S:Shn | NO |
| S017 | S:Signed Weight Restriction | YES |
| S018 | S:Abnormal Load Route | YES |
| S019 | S:Amenity Weight Restriction | NO |
| S024 | S:Caution | NO |
| S040 | S:Over | NO |
| STSF | TK:Strategy to be Followed | NO |
| SUST | TK:Substandard Structure | NO |
| SWLS | TK:Walls | NO |

**Observations** (16)

| Code | Name | Required |
|---|---|---|
| SH01 | Anti-Social Environment | NO |
| SH02 | Confined Space | NO |
| SH03 | Dangerous Structure | NO |
| SH04 | Deep Water | NO |
| SH05 | Difficult Access | NO |
| SH06 | Gated Access | NO |
| SH07 | Habitat | NO |
| SH08 | Hazardous Environment | NO |
| SH09 | No Footway / Verge | NO |
| SH10 | Parking | NO |
| SH11 | Soft Silt | NO |
| SH12 | Trash Screen | NO |
| SH13 | Other | NO |
| STEC | Engineer Comments | NO |
| STIC | Inspector Comments | NO |
| STWR | Work Required | NO |


## SRWP – ST:Retaining Wall Panel
Data source: **Information Team – Asset ST:Retaining Wall Panel**

**Measurements** (5)

| Code | Name | Required |
|---|---|---|
| NO | Number Of | NO |
| S009 | S:Construction Length | YES |
| S012 | S:Width | YES |
| S013 | S:Span Area | YES |
| S014 | S:No. Of Construction Forms | YES |

**Attributes** (2)

| Code | Name | Required |
|---|---|---|
| RWC1 | S:RW-Structural Form | YES |
| RWC2 | S:RW-Material Type | YES |

**Observations** (28)

| Code | Name | Required |
|---|---|---|
| WE20 | 20/Services | NO |
| WE21 | 21/Other | NO |
| WE22 | 22/Other | NO |
| WE23 | 23/Other | NO |
| WE24 | 24/Other | NO |
| BCIA | BCI Average | NO |
| BCIC | BCI Critical | NO |
| WE25 | 25/Retaining Wall | NO |
| WE26 | 26/Structural Earthworks | NO |
| WE01 | 01/Foundations | NO |
| WE02 | 02/Retaining Wall/Primary | NO |
| WE03 | 03/Retaining Wall/Secondary | NO |
| WE04 | 04/Parapet beam/plinth | NO |
| WE05 | 05/Drainage | NO |
| WE06 | 06/Movement/expansion joints | NO |
| WE07 | 07/Surface finishes:wall | NO |
| WE08 | 08/Surf.finishes:hrail/parapet | NO |
| WE09 | 09/Handrail/parapet/saf.fences | NO |
| WE10 | 10/Carriageway-Top of Wall | NO |
| WE11 | 11/Carriageway-Foot of Wall | NO |
| WE12 | 12/Footway/Verge-Top of Wall | NO |
| WE13 | 13/Footway/Verge-Foot of Wall | NO |
| WE14 | 14/Embankment-Top of Wall | NO |
| WE15 | 15/Embankment-Foot of Wall | NO |
| WE16 | 16/Invert/river bed | NO |
| WE17 | 17/Aprons | NO |
| WE18 | 18/Signs | NO |
| WE19 | 19/Lighting | NO |


## STRW – ST:Retaining Wall
Data source: **Information Team – Asset ST:Retaining Wall**

**Measurements** (5)

| Code | Name | Required |
|---|---|---|
| NO | Number Of | NO |
| S015 | S:CW Width Above Wall | YES |
| S016 | S:Wall Length | YES |
| S017 | S:Max Retained Height | YES |
| S018 | S:No. Of Sections | YES |

**Attributes** (20)

| Code | Name | Required |
|---|---|---|
| ENST | TK:Environmentally Sensitive | NO |
| HERG | TK:Heritage | NO |
| LOC1 | TK:Location Type | NO |
| ROSA | TK:Route Salted | NO |
| RTAF | TK:Route Type Adjacent to foot | NO |
| RTAT | TK:Route Type Adjacent to top | NO |
| RTFS | TK:Route Type Adj foot Salted | NO |
| RTL1 | TK:Route Traffic Level | NO |
| S006 | S:Parish | NO |
| S008 | S:Ancient Monument | NO |
| S009 | TK:Planning Conservation Area | NO |
| S011 | S:Listed Grade | NO |
| S014 | S:Prn | NO |
| S015 | S:Shn | NO |
| S018 | S:Abnormal Load Route | NO |
| S024 | S:Caution | NO |
| S040 | S:Over | NO |
| STSF | TK:Strategy to be Followed | NO |
| SUST | TK:Substandard Structure | NO |
| SWLS | TK:Walls | NO |

**Observations** (15)

| Code | Name | Required |
|---|---|---|
| SH01 | Anti-Social Environment | NO |
| SH02 | Confined Space | NO |
| SH03 | Dangerous Structure | NO |
| SH04 | Deep Water | NO |
| SH05 | Difficult Access | NO |
| SH06 | Gated Access | NO |
| SH07 | Habitat | NO |
| SH08 | Hazardous Environment | NO |
| SH09 | No Footway / Verge | NO |
| SH10 | Parking | NO |
| SH11 | Soft Silt | NO |
| SH13 | Other | NO |
| STEC | Engineer Comments | NO |
| STIC | Inspector Comments | NO |
| STWR | Work Required | NO |


## STDM – ST:Dam
Data source: **Information Team – Asset ST:Dam**

**Measurements** (5)

| Code | Name | Required |
|---|---|---|
| NO | Number Of | NO |
| OTWL | S: Overflow / Top Water Level | YES |
| S009 | S:Construction Length | YES |
| S017 | S:Max Retained Height | YES |
| SCAP | S: Storage Capacity | YES |

**Attributes** (10)

| Code | Name | Required |
|---|---|---|
| DCON | S: Date Constructed | YES |
| DESI | S: Designation | NO |
| FCAT | S: Flood Category | NO |
| RTAT | TK:Route Type Adjacent to top | NO |
| S006 | S:Parish | NO |
| S008 | S:Ancient Monument | NO |
| S011 | S:Listed Grade | NO |
| S031 | S:Comments | NO |
| S041 | S:Construction | NO |
| USE | S: Use | NO |

**Observations** (0) – none in workbook


## SPAN – ST:Structure Span
Data source: **Information Team – Asset ST:Structure Span**

**Measurements** (7)

| Code | Name | Required |
|---|---|---|
| NO | Number Of | NO |
| S008 | S:Span No | YES |
| S009 | S:Construction Length | YES |
| S010 | S:Skew (C) | NO |
| S011 | S:Square Span | YES |
| S012 | S:Width | YES |
| S013 | S:Span Area | YES |

**Attributes** (6)

| Code | Name | Required |
|---|---|---|
| BTC1 | S:BTC-Primary Deck Element | NO |
| BTC2 | S:BTC-Prim Deck Elem Material | NO |
| BTC3 | S:BTC-Secondary Deck Element | NO |
| BTC4 | S:BTC-Sec Deck Elem Material | NO |
| S045 | S:Span Description | NO |
| S046 | S:Span Number Description | NO |

**Observations** (47)

| Code | Name | Required |
|---|---|---|
| BCIA | BCI Average | NO |
| BCIC | BCI Critical | NO |
| BE43 | 43/Chamber/Cellar/Vault | NO |
| BE44 | 44/Culvert | NO |
| BE45 | 45/Subway: Pipe | NO |
| BE01 | 01/Primary Deck Element | NO |
| BE02 | 02/Sec.Deck Elem/s Transv Beam | NO |
| BE03 | 03/Sec.Deck Element/s Other | NO |
| BE04 | 04/Half joints | NO |
| BE05 | 05/Tie beam/rod | NO |
| BE06 | 06/Parapet beam or cantilever | NO |
| BE07 | 07/Deck bracing | NO |
| BE08 | 08/Foundations | NO |
| BE09 | 09/Abutments(inc.arch spring) | NO |
| BE10 | 10/Spandrel wall/head wall | NO |
| BE11 | 11/Pier/column | NO |
| BE12 | 12/Cross-head/capping beam | NO |
| BE13 | 13/Bearings | NO |
| BE14 | 14/Bearing plinth/shelf | NO |
| BE15 | 15/Superstructure drainage | NO |
| BE16 | 16/Substructure drainage | NO |
| BE17 | 17/Water proofing | NO |
| BE18 | 18/Movement/expansion joints | NO |
| BE19 | 19/Finishes:deck elements | NO |
| BE20 | 20/Finishes:substructure elem | NO |
| BE21 | 21/Finishes:parapet/saf.fences | NO |
| BE22 | 22/Access/walkways/gantries | NO |
| BE23 | 23/Handrail/parapet/saf.fences | NO |
| BE24 | 24/Carriageway surfacing | NO |
| BE25 | 25/Fway/verge/fbrdge surfacing | NO |
| BE26 | 26/Invert/river bed | NO |
| BE27 | 27/Aprons | NO |
| BE28 | 28/Fend/c-water/collisn protct | NO |
| BE29 | 29/River training works | NO |
| BE30 | 30/Revetment/batter paving | NO |
| BE31 | 31/Wing walls | NO |
| BE32 | 32/Retaining walls | NO |
| BE33 | 33/Embankments | NO |
| BE34 | 34/Machinery | NO |
| BE35 | 35/Apprch rails/barriers/walls | NO |
| BE36 | 36/Signs | NO |
| BE37 | 37/Lighting | NO |
| BE38 | 38/Services | NO |
| BE39 | 39/Other | NO |
| BE40 | 40/Other | NO |
| BE41 | 41/Other | NO |
| BE42 | 42/Other | NO |


## WGBC – Winter Asset - Bin
Data source: **Information Team – Asset Winter Asset - Bin**

**Measurements** (3)

| Code | Name | Required |
|---|---|---|
| GRAD | Gradient (%) | YES |
| NO | Number Of | NO |
| VOL | Volume (m3) | YES |

**Attributes** (10)

| Code | Name | Required |
|---|---|---|
| KPA | Known Problem Area | YES |
| OAP | Only Access Point | YES |
| PTRE | Persons Available To Treat | YES |
| PWA | Distance to Next Asset | YES |
| SLFB | Suitable Location For Asset | YES |
| SPR | Speed Of Road Assessed | YES |
| SRA | Speed Of Road Joining | YES |
| TRET | Is Road on treated Network | YES |
| WASL | Strategic Level | YES |
| WTA | Winter - Type of Asset | YES |

**Observations** (2)

| Code | Name | Required |
|---|---|---|
| GCI | Asset Condition Information | NO |
| SAOA | Stockpile Amount On Arrival | NO |


## WGPC – Winter Asset - Pile
Data source: **Information Team – Asset Winter Asset - Pile**

**Measurements** (3)

| Code | Name | Required |
|---|---|---|
| GRAD | Gradient (%) | YES |
| NO | Number Of | NO |
| VOL | Volume (m3) | YES |

**Attributes** (10)

| Code | Name | Required |
|---|---|---|
| KPA | Known Problem Area | YES |
| OAP | Only Access Point | YES |
| PTRE | Persons Available To Treat | YES |
| PWA | Distance to Next Asset | YES |
| SLFB | Suitable Location For Asset | YES |
| SPR | Speed Of Road Assessed | YES |
| SRA | Speed Of Road Joining | YES |
| TRET | Is Road on treated Network | YES |
| WASL | Strategic Level | YES |
| WTA | Winter - Type of Asset | YES |

**Observations** (1)

| Code | Name | Required |
|---|---|---|
| SAOA | Stockpile Amount On Arrival | NO |


## DAMA – Drainage Asset - Manholes
Data source: **Information Team – Asset Drainage Asset - Manholes**

**Measurements** (2)

| Code | Name | Required |
|---|---|---|
| DMDI | Manhole - Depth to Invert | YES |
| NO | Number Of | NO |

**Attributes** (8)

| Code | Name | Required |
|---|---|---|
| DACI | Drainage - Asset - Condition | YES |
| DAFD | Drainage - Direction of Flow | YES |
| DMKR | Drainage - Manhole - Keys Req | YES |
| DMTY | Drainage - Manhole - Type | YES |
| DOWN | Drainage - Likely Ownership | YES |
| DPIS | Drainage - Pipe Size - In | YES |
| DPOS | Drainage - Pipe Size - Out | YES |
| TMR | Traffic Management Requirement | YES |

**Observations** (3)

| Code | Name | Required |
|---|---|---|
| SLOA | Silt Level On Arrival | NO |
| ACT | Action Taken | NO |
| GSOD | State On Departure | NO |


## DALA – Drainage Asset - Linear Asset
Data source: **Information Team – Asset Drainage Asset - Linear Asset**

**Measurements** (1)

| Code | Name | Required |
|---|---|---|
| NO | Number Of | YES |

**Attributes** (5)

| Code | Name | Required |
|---|---|---|
| DAFD | Drainage - Direction of Flow | YES |
| DAOT | Drainage - Outfall Location | YES |
| DLAT | Drainage - Linear Asset Type | YES |
| DOWN | Drainage - Likely Ownership | YES |
| DPIS | Drainage - Pipe Size - In | YES |

**Observations** (0) – none in workbook


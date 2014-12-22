; Data appears to consist of a length byte followed by
; that number of words.
Data_7B25:
	.db $04
	.dw $2003 $2103 $2203 $2103
	
Data_7B2E:
	.db $04
	.dw $2000 $2100 $2200 $2100

Data_7B37:
	.db $02
	.dw $2403 $2303

Data_7B3C:
	.db $02
	.dw $2504 $2304

Data_7B41:
	.db $02
	.dw $2703 $2603

Data_7B46:
	.db $02
	.dw $2804 $2604

Data_7B4B:
	.db $02
	.dw $2A03 $2903

Data_7B50:
	.db $02
	.dw $2B04 $2904

Data_7B55:
	.db $02
	.dw $2D03 $2C03

Data_7B5A:
	.db $02
	.dw $2E04 $2C04
	
Data_7B5F:
	.db $02
	.dw $2F03 $3003

Data_7B64:
	.db $02
	.dw $3103 $3203
	
Data_7B69:
	.db $04
	.dw $3703 $3803 $3703 $3203

Data_7B72:
	.db $04
	.dw $3503 $3603 $3503 $3203

Data_7B7B:
	.db $04
	.dw $3903 $3A03 $3903 $3003

Data_7B84:
	.db $04
	.dw $3303 $3403 $3303 $3003
	
; Unused?
Data_7B8D:
	.db $02
	.dw $3B04 $3C04

Data_7B92:
	.db $04
	.dw $3D02 $3E02 $3F02 $400A

Data_7B9B:
	.db $08
	.dw $4500 $4400 $4300 $4200 $4200 $4300 $4400 $4500

Data_7BAC:	
	.db $03
	.dw $4503 $4603 $4503
	
Data_7BB3:
	.db $03
	.dw $4703 $4803 $4703

Data_7BBA:
	.db $03
	.dw $4903 $4A03 $4903

Data_7BC1:
	.db $03
	.dw $4B03 $4C03 $4B03

Data_7BC8:
	.db $02
	.dw $4E06 $4F02
	
Data_7BCD:
	.db $02
	.dw $5106 $5002

Data_7BD2:
	.db $02
	.dw $5306 $5202

Data_7BD7:
	.db $02
	.dw $5506 $5402

; Is the $0003 an error?
Data_7BDC:
	.db $03
	.dw $0003 $5901 $5801
	
Data_7BE3:
	.db $03
	.dw $5A07 $5903 $5803

Data_7BEA:
	.db $03
	.dw $5F07 $5E03 $5D03

Data_7BF1:
	.db $03
	.dw $6207 $6103 $6003

Data_7BF8:
	.db $03
	.dw $5C07 $5B03 $5B03
	
Data_7BFF:
	.db $02
	.dw $5B03 $5B03

Data_7C04:
	.db $02
	.dw $5803 $5903

Data_7C09:
	.db $02
	.dw $5D03 $5E03
	
Data_7C0E:
	.db $02
	.dw $6003 $6103
	
Data_7C13:
	.db $02
	.dw $6603 $6703

Data_7C18:
	.db $03
	.dw $6903 $6A03 $6B03
	
Data_7C1F:
	.db $06
	.dw $A402 $A502 $A602 $A502 $A402 $6C02
	
Data_7C2C:
	.db $06
	.dw $A102 $A202 $A302 $A202 $A102 $6D02
	
Data_7C39:
	.db $06
	.dw $A702 $A802 $A902 $A802 $A702 $6F02
	
Data_7C46:
	.db $06
	.dw $AA02 $AB02 $AC02 $AB02 $AA02 $6E02
	
Data_7C53:
	.db $02
	.dw $7304 $7404

Data_7C58:
	.db $02
	.dw $8103 $8203
	
Data_7C5D:
	.db $02
	.dw $8A03 $8B03
	
Data_7C62:
	.db $02
	.dw $8403 $8503
	
Data_7C67:
	.db $02
	.dw $8703 $8803
	
Data_7C6C:
	.db $02
	.dw $8304 $8204
	
Data_7C71:
	.db $02
	.dw $8C04 $8B04
	
Data_7C76:
	.db $02
	.dw $8604 $8504
	
Data_7C7B:
	.db $02
	.dw $8904 $8704
	
Data_7C80:
	.db $02
	.dw $7803 $7903
	
Data_7C85:
	.db $02
	.dw $7A03 $7B03

Data_7C8A:
	.db $02
	.dw $7E03 $7F03
	
Data_7C8F:
	.db $02
	.dw $7C03 $7D03
	
Data_7C94:
	.db $02
	.dw $6303 $6403
	
Data_7C99:
	.db $03
	.dw $7503 $7603 $7720
	
Data_7CA0:
	.db $02
	.dw $9002 $8F20
	
Data_7CA5:
	.db $02
	.dw $8E02 $8D20
	
Data_7CAA:
	.db $02
	.dw $9202 $9120
	
Data_7CAF:
	.db $02
	.dw $9402 $9320

Data_7CB4:
	.db $04
	.dw $9704 $9B04 $9F04 $9B04

Data_7CBD:
	.db $04
	.dw $9804 $9C04 $A004 $9C04

Data_7CC6:
	.db $04
	.dw $9504 $9904 $9D04 $9904

Data_7CCF:
	.db $04
	.dw $9604 $9A04 $9E04 $9A04

Data_7CD8:
	.db $04
	.dw $AF04 $B304 $B704 $B304

Data_7CE1:
	.db $04
	.dw $B004 $B404 $B804 $B404

Data_7CEA:
	.db $04
	.dw $AD04 $B104 $B504 $B104

Data_7CF3:
	.db $04
	.dw $AE04 $B204 $B604 $B204

; Unused?
Data_7CFC:
	.db $02
	.dw $B905 $BA05

; Unused?
Data_7D01:
	.db $02
	.dw $BC04 $BB04
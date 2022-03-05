.segment "HEADER"
.byte "NES"
.byte $1a
.byte $02 
.byte $01 
.byte %00000001 
.byte $00
.byte $00
.byte $00
.byte $00
.byte $00, $00, $00, $00, $00 
.segment "ZEROPAGE"
world: .res 2
.segment "STARTUP"
Reset:
    SEI
    CLD 

    LDX #$40
    STX $4017

    LDX #$FF
    TXS

    INX 

    STX $2000
    STX $2001

    STX $4010

:
    BIT $2002
    BPL :-

    TXA

CLEARMEM:
    STA $0000, X 
    STA $0100, X 
    STA $0300, X
    STA $0400, X
    STA $0500, X
    STA $0600, X
    STA $0700, X
    LDA #$FF
    STA $0200, X 
    LDA #$00
    INX
    BNE CLEARMEM    

:
    BIT $2002
    BPL :-

    LDA #$02
    STA $4014
    NOP


    LDA #$3F
    STA $2006
    LDA #$00
    STA $2006

    LDX #$00

LoadPalettes:
    LDA PaletteData, X
    STA $2007
    INX
    CPX #$20
    BNE LoadPalettes    

    ; Initialize world to point to world data
    LDA #<WorldData ; Grabbing the low byte of world data
    STA world ; 
    LDA #>WorldData ; Grabbing the high byte
    STA world+1 ;Store it into the world variable plus a byte into it's second byte

    ; Setup address in PPU for nametable data
    BIT $2002 ; read from 2002 to reset the 2006 address
    LDA #$20 ; Load the high byte
    STA $2006
    LDA #$00 ; Load the low byte
    STA $2006


    LDX #$00
    LDY #$00
LoadWorld:
    LDA (world), Y
    STA $2007
    INY 
    CPX #$03
    BNE :+
    CPY #$C0
    BEQ DoneLoadingWorld
:
    CPY #$00
    BNE LoadWorld
    INX
    INC world+1
    JMP LoadWorld

DoneLoadingWorld:
    LDX #$00

SetAttributes:
    LDA #$55
    STA $2007
    INX
    CPX #$40
    BNE SetAttributes

    LDX #$00
    LDY #$00  

LoadSprites:
    LDA SpriteData, X
    STA $0200, X
    INX
    CPX #$20
    BNE LoadSprites    

; Enable interrupts
    CLI

    LDA #%10010000 ; enable NMI change background to use second chr set of tiles ($1000)
    STA $2000
    ; Enabling sprites and background for left-most 8 pixels
    ; Enable sprites and background
    LDA #%00011110
    STA $2001

Loop:
    JMP Loop

NMI:
    LDA #$02
    STA $4014
    RTI

PaletteData:
  .byte $22,$29,$1A,$0F,$22,$36,$17,$0f,$22,$30,$21,$0f,$22,$27,$17,$0F
  .byte $22,$16,$27,$18,$22,$1A,$30,$27,$22,$16,$30,$27,$22,$0F,$36,$17

WorldData:
    .incbin "world.bin"

SpriteData:
  .byte $08, $00, $00, $08
  .byte $08, $01, $00, $10
  .byte $10, $02, $00, $08
  .byte $10, $03, $00, $10
  .byte $18, $04, $00, $08
  .byte $18, $05, $00, $10
  .byte $20, $06, $00, $08
  .byte $20, $07, $00, $10

.segment "VECTORS"
    .word NMI
    .word Reset
    ; 
.segment "CHARS"
    .incbin "mariotest.chr"
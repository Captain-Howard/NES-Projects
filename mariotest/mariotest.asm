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
.segment "STARTUP"
Reset:
    SEI 
    CLD 

    ; Disable sound IRQ
    LDX #$40
    STX $4017

    ; Initialize the stack register
    LDX #$FF
    TXS

    INX

    ; Zero out the PPU registers
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
    
; wait for vblank

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

    LDX #$00
    
LoadSprites:
    LDA SpriteData, X
    STA $0200, X
    INX
    CPX #$20
    BNE LoadSprites    

    LDX #$00
    LDY #$00
    LDA $2002
    LDA #$20
    STA $2006
    LDA #$00
    STA $2006
    
ClearNametable:
    STA $2007
    INX
    BNE ClearNametable
    INY
    CPY #$08
    BNE ClearNametable
    
; Enable interrupts
    CLI

    LDA #%10010000
    STA $2000
    
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
  .byte $22,$29,$1A,$0F,$22,$36,$17,$0f,$22,$30,$21,$0f,$22,$27,$17,$0F  ;background palette data
  .byte $22,$16,$27,$18,$22,$1A,$30,$27,$22,$16,$30,$27,$22,$0F,$36,$17  ;sprite palette data

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
     
.segment "CHARS"
    .incbin "mariotest.chr"

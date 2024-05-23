;------------------------
; Assembly Code
;------------------------
#define __SFR_OFFSET 0x00
#include "avr/io.h"
;------------------------
.global SPI_MAX7219_init
.global MAX7219_display
.global HC_SR04_sensor
.global main
;===============================================================
main:
      LDI R21, 0xFF   
      OUT DDRD, R21               ; Menjadikan pin D sebagai output
      ;-----------------------------------------------------------
      RCALL SPI_MAX7219_init
      RCALL MAX7219_display
      ;-----------------------------------------------------------
main_loop:
      RCALL HC_SR04_sensor
      RJMP main_loop
;===============================================================
HC_SR04_sensor:
      SBI   DDRB, 1             ;pin PB1 as o/p (Trigger)
      CBI   DDRB, 0             ;pin PB0 as i/p (Echo)
      ;-----------------------------------------------------------
trigger_pulse:
      SBI   PORTB, 1
      CBI   PORTD, 1
      RCALL delay_timer0
      CBI   PORTB, 1            ;send 10us high pulse to sensor
      ;-----------------------------------------------------------
      RCALL echo_PW             ;compute Echo pulse width count
      ;-----------------------------------------------------------
      RCALL compare
      ;-----------------------------------------------------------    
      RCALL byte_to_decimal     ;covert & display on MAX7219
      ;-----------------------------------------------------------
      RCALL delay_ms
      RJMP  trigger_pulse
;===============================================================
echo_PW:
      LDI   R20, 0b00000000
      STS   TCCR1A, R20         ;Timer 1 normal mode
      LDI   R20, 0b11000101     ;set for rising edge detection &
      STS   TCCR1B, R20         ;prescaler=1024, noise cancellation ON
      ;-----------------------------------------------------------
wait_rising_edge: 
      IN    R21, TIFR1
      SBRS  R21, ICF1
      RJMP  wait_rising_edge    ;loop until rising edge is detected
      ;-----------------------------------------------------------
      LDS   R16, ICR1L          ;store count value at rising edge
      ;-----------------------------------------------------------
      OUT   TIFR1, R21          ;clear flag for falling edge detection
      LDI   R20, 0b10000101
      STS   TCCR1B, R20         ;set for falling edge detection
      ;-----------------------------------------------------------
wait_falling_edge: 
      IN    R21, TIFR1
      SBRS  R21, ICF1
      RJMP  wait_falling_edge   ;loop until falling edge is detected
      ;-----------------------------------------------------------
      LDS   R28, ICR1L          ;store count value at falling edge
      ;-----------------------------------------------------------
      SUB   R28, R16            ;count diff R22 = R22 - R16
      ADD   R28, 17
      OUT   TIFR1, R21          ;clear flag for next sensor reading
      RET
;=============================================================================================
; COMPARE
;=============================================================================================
compare:
      CPI R28, 40
      BRCS emergency_lock
      CPI R28, 75
      BRCS warning
      ;-----------------------------------------------------------
      ; Normal Mode
      CBI PORTD, 5  ; RED
      CBI PORTD, 6  ; YELLOW
      SBI PORTD, 7  ; GREEN
      ;-----------------------------------------------------------
      ; Disable buzzer
      CBI PORTD, 3
      ;-----------------------------------------------------------
      RJMP skip
;===============================================================
emergency_lock:
      SBI PORTD, 1              ; Activate motor to lock door
      ;-----------------------------------------------------------
      ; Enable buzzer
      SBI PORTD, 3
      ;-----------------------------------------------------------
      ; LED RED
      SBI PORTD, 5  ; RED
      CBI PORTD, 6  ; YELLOW
      CBI PORTD, 7  ; GREEN
      ;-----------------------------------------------------------
      RJMP skip
;===============================================================
warning:
      ; Enable buzzer
      SBI PORTD, 3
      ;-----------------------------------------------------------
      ; LED YELLOW
      CBI PORTD, 5  ; RED
      SBI PORTD, 6  ; Yellow
      CBI PORTD, 7  ; GREEN
      ;-----------------------------------------------------------
      RJMP skip
;===============================================================   
skip:
      RET
;===============================================================
SPI_MAX7219_init:
.equ  SCK, 5
.equ  MOSI, 3
.equ  SS, 2
;--------------------------------------------------------------
      LDI   R17, (1<<MOSI)|(1<<SCK)|(1<<SS)
      OUT   DDRB, R17         ;set MOSI, SCK, SS as o/p
      ;--------------------------------------------------------
      LDI   R17, (1<<SPE)|(1<<MSTR)|(1<<SPR0)
      OUT   SPCR, R17         ;enable SPI as master, fsck=fosc/16
      ;--------------------------------------------------------
      LDI   R17, 0x0A         ;set segment intensity (0 to 15)
      LDI   R18, 8            ;intensity level = 8
      RCALL send_bytes        ;send command & data to MAX7219
      ;--------------------------------------------------------
      LDI   R17, 0x09         ;set decoding mode command
      LDI   R18, 0b00110000   ;decoding byte
      RCALL send_bytes        ;send command & data to MAX7219
      ;--------------------------------------------------------
      LDI   R17, 0x0B         ;set scan limit command
      LDI   R18, 0x07         ;8 digits connected to MAX7219
      RCALL send_bytes        ;send command & data to MAX7219
      ;--------------------------------------------------------
      LDI   R17, 0x0C         ;set turn ON/OFF command
      LDI   R18, 0x01         ;turn ON MAX7219
      RCALL send_bytes        ;send command & data to MAX7219
      ;--------------------------------------------------------
      RET
;==============================================================
MAX7219_display:
      LDI   R17, 0x08         ;select digit 7
      LDI   R18, 0x00         ;data = d
      RCALL send_bytes        ;send command & data to MAX7219
      ;--------------------------------------------------------
      LDI   R17, 0x07         ;select digit 6
      LDI   R18, 0x00         ;data = space
      RCALL send_bytes        ;send command & data to MAX7219
      ;--------------------------------------------------------
      LDI   R17, 0x04         ;select digit 3
      LDI   R18, 0x00         ;data = space
      RCALL send_bytes        ;send command & data to MAX7219
      ;--------------------------------------------------------
      ; Sending the bytes to MAX 7219 Display
      LDI   R17, 0x03         ;select digit 2
      LDI   R18, 0x0D         ;data = c
      RCALL send_bytes        ;send command & data to MAX7219
      ;--------------------------------------------------------
      LDI   R17, 0x02         ;select digit 1
      LDI   R18, 0b00010101   ;data = (paruh pertama karakter 'm')
      RCALL send_bytes        ;send command & data to MAX7219
      ;--------------------------------------------------------
      LDI   R17, 0x01         ;select digit 0
      LDI   R18, 0b00010101   ;data = (paruh kedua karakter 'm')
      RCALL send_bytes        ;send command & data to MAX7219
      ;--------------------------------------------------------
      RET
;==============================================================
send_bytes:
      CBI   PORTB, SS         ;enable slave device MAX7219
      OUT   SPDR, R17         ;transmit command
      ;--------------------------------------------------------
wait_tx1:  IN    R19, SPSR
      SBRS  R19, SPIF         ;wait for byte transmission
      RJMP  wait_tx1          ;to complete
      ;--------------------------------------------------------
      OUT   SPDR, R18         ;transmit data
      ;--------------------------------------------------------
wait_tx2:  IN    R19, SPSR
      SBRS  R19, SPIF         ;wait for byte transmission
      RJMP  wait_tx2          ;to complete
      ;--------------------------------------------------------
      SBI   PORTB, SS         ;disable slave device MAX7219
      RET
;==============================================================
byte_to_decimal:
      CLR   R26               ;set counter1, initial value 0
      CLR   R27               ;set counter2, initial value 0
      ;--------------------------------------------------------
cnvrt_100:  CPI   R28, 100    ;compare R28 with 100
Ret:  BRMI  cnvrt_10          ;jump when R28 < 100
      INC   R26               ;increment counter1 by 1
      SUBI  R28, 100          ;R28 = R28 - 100
      RJMP  cnvrt_100
      ;--------------------------------------------------------
cnvrt_10:  CPI   R28, 10      ;compare R28 with 10
      BRMI  display_digits    ;jump when R28 < 10
      INC   R27               ;increment counter2 by 1
      SUBI  R28, 10           ;R28 = R28 - 10
      RJMP  cnvrt_10
      ;--------------------------------------------------------  
display_digits:  MOV   R18, R27
      LDI   R17, 0x06         ;select digit 5 for MSD
      RCALL send_bytes        ;send command & data to MAX7219
      ;--------------------------------------------------------
      MOV   R18, R28
      LDI   R17, 0x05         ;select digit 4 for LSD
      RCALL send_bytes        ;send command & data to MAX7219    
      ;--------------------------------------------------------
      RET
;===============================================================
;delay subroutines
;===============================================================
delay_timer0:                 ;10 usec delay via Timer 0
      CLR   R20
      OUT   TCNT0, R20          ;initialize timer0 with count=0
      LDI   R20, 20
      OUT   OCR0A, R20          ;OCR0 = 20
      LDI   R20, 0b00001010
      OUT   TCCR0B, R20         ;timer0: CTC mode, prescaler 8
      ;-----------------------------------------------------------
l0:   IN    R20, TIFR0          ;get TIFR0 byte & check
      SBRS  R20, OCF0A          ;if OCF0=1, skip next instruction
      RJMP  l0                  ;else, loop back & check OCF0 flag
      ;-----------------------------------------------------------
      CLR   R20
      OUT   TCCR0B, R20         ;stop timer0
      ;-----------------------------------------------------------
      LDI   R20, (1<<OCF0A)
      OUT   TIFR0, R20          ;clear OCF0 flag
      RET
;===============================================================
delay_ms:
      LDI   R21, 255
l6:   LDI   R22, 255
l7:   LDI   R23, 50
l8:   DEC   R23
      BRNE  l8
      DEC   R22
      BRNE  l7
      DEC   R21
      BRNE  l6
      RET
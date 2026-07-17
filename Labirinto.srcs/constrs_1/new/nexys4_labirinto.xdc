## =====================================================
## nexys4_labirinto.xdc
## File dei constraint per il progetto Labirinto RISC-V
## Scheda: Digilent Nexys 4 (Artix-7 XC7A100T-CSG324)
## Top-level: system_top
##
## Mappa: clock 100 MHz, reset (CPU_RESETN), accelerometro ADXL362
## integrato (SPI), uscite VGA, LED, display 7 segmenti, switch, pulsanti.
## =====================================================

## =====================================================
## CLOCK 100 MHz (pin E3)
## =====================================================
set_property -dict { PACKAGE_PIN E3  IOSTANDARD LVCMOS33 } [get_ports { clk }];
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports { clk }];

## Clock derivato per la CPU (25 MHz, generato dal divisore interno)
create_generated_clock -name cpu_clk -source [get_ports clk] -divide_by 4 [get_pins cpu_clk_reg/Q]
## =====================================================
## RESET -> pulsante rosso CPU_RESETN (pin C12)
## ATTENZIONE: e' ATTIVO BASSO (premuto = 0).
## Il codice usa rst attivo alto: vedi nota in fondo al file.
## =====================================================
set_property -dict { PACKAGE_PIN C12 IOSTANDARD LVCMOS33 } [get_ports { rst }];

## =====================================================
## ACCELEROMETRO ADXL362 (integrato sulla scheda, via SPI)
## =====================================================
set_property -dict { PACKAGE_PIN F15 IOSTANDARD LVCMOS33 } [get_ports { spi_sclk }];
set_property -dict { PACKAGE_PIN F14 IOSTANDARD LVCMOS33 } [get_ports { spi_mosi }];
set_property -dict { PACKAGE_PIN E15 IOSTANDARD LVCMOS33 } [get_ports { spi_miso }];
set_property -dict { PACKAGE_PIN D15 IOSTANDARD LVCMOS33 } [get_ports { spi_cs_n }];

## =====================================================
## USCITE VGA
## =====================================================
## Sync
set_property -dict { PACKAGE_PIN B11 IOSTANDARD LVCMOS33 } [get_ports { vga_hsync }];
set_property -dict { PACKAGE_PIN B12 IOSTANDARD LVCMOS33 } [get_ports { vga_vsync }];
## Rosso (4 bit)
set_property -dict { PACKAGE_PIN A3  IOSTANDARD LVCMOS33 } [get_ports { vga_red[0] }];
set_property -dict { PACKAGE_PIN B4  IOSTANDARD LVCMOS33 } [get_ports { vga_red[1] }];
set_property -dict { PACKAGE_PIN C5  IOSTANDARD LVCMOS33 } [get_ports { vga_red[2] }];
set_property -dict { PACKAGE_PIN A4  IOSTANDARD LVCMOS33 } [get_ports { vga_red[3] }];
## Verde (4 bit)
set_property -dict { PACKAGE_PIN C6  IOSTANDARD LVCMOS33 } [get_ports { vga_green[0] }];
set_property -dict { PACKAGE_PIN A5  IOSTANDARD LVCMOS33 } [get_ports { vga_green[1] }];
set_property -dict { PACKAGE_PIN B6  IOSTANDARD LVCMOS33 } [get_ports { vga_green[2] }];
set_property -dict { PACKAGE_PIN A6  IOSTANDARD LVCMOS33 } [get_ports { vga_green[3] }];
## Blu (4 bit)
set_property -dict { PACKAGE_PIN B7  IOSTANDARD LVCMOS33 } [get_ports { vga_blue[0] }];
set_property -dict { PACKAGE_PIN C7  IOSTANDARD LVCMOS33 } [get_ports { vga_blue[1] }];
set_property -dict { PACKAGE_PIN D7  IOSTANDARD LVCMOS33 } [get_ports { vga_blue[2] }];
set_property -dict { PACKAGE_PIN D8  IOSTANDARD LVCMOS33 } [get_ports { vga_blue[3] }];

## =====================================================
## LED (16)
## =====================================================
set_property -dict { PACKAGE_PIN H17 IOSTANDARD LVCMOS33 } [get_ports { leds[0] }];
set_property -dict { PACKAGE_PIN K15 IOSTANDARD LVCMOS33 } [get_ports { leds[1] }];
set_property -dict { PACKAGE_PIN J13 IOSTANDARD LVCMOS33 } [get_ports { leds[2] }];
set_property -dict { PACKAGE_PIN N14 IOSTANDARD LVCMOS33 } [get_ports { leds[3] }];
set_property -dict { PACKAGE_PIN R18 IOSTANDARD LVCMOS33 } [get_ports { leds[4] }];
set_property -dict { PACKAGE_PIN V17 IOSTANDARD LVCMOS33 } [get_ports { leds[5] }];
set_property -dict { PACKAGE_PIN U17 IOSTANDARD LVCMOS33 } [get_ports { leds[6] }];
set_property -dict { PACKAGE_PIN U16 IOSTANDARD LVCMOS33 } [get_ports { leds[7] }];
set_property -dict { PACKAGE_PIN V16 IOSTANDARD LVCMOS33 } [get_ports { leds[8] }];
set_property -dict { PACKAGE_PIN T15 IOSTANDARD LVCMOS33 } [get_ports { leds[9] }];
set_property -dict { PACKAGE_PIN U14 IOSTANDARD LVCMOS33 } [get_ports { leds[10] }];
set_property -dict { PACKAGE_PIN T16 IOSTANDARD LVCMOS33 } [get_ports { leds[11] }];
set_property -dict { PACKAGE_PIN V15 IOSTANDARD LVCMOS33 } [get_ports { leds[12] }];
set_property -dict { PACKAGE_PIN V14 IOSTANDARD LVCMOS33 } [get_ports { leds[13] }];
set_property -dict { PACKAGE_PIN V12 IOSTANDARD LVCMOS33 } [get_ports { leds[14] }];
set_property -dict { PACKAGE_PIN V11 IOSTANDARD LVCMOS33 } [get_ports { leds[15] }];

## =====================================================
## DISPLAY 7 SEGMENTI - segmenti (attivi bassi)
## =====================================================
set_property -dict { PACKAGE_PIN T10 IOSTANDARD LVCMOS33 } [get_ports { seg[0] }];
set_property -dict { PACKAGE_PIN R10 IOSTANDARD LVCMOS33 } [get_ports { seg[1] }];
set_property -dict { PACKAGE_PIN K16 IOSTANDARD LVCMOS33 } [get_ports { seg[2] }];
set_property -dict { PACKAGE_PIN K13 IOSTANDARD LVCMOS33 } [get_ports { seg[3] }];
set_property -dict { PACKAGE_PIN P15 IOSTANDARD LVCMOS33 } [get_ports { seg[4] }];
set_property -dict { PACKAGE_PIN T11 IOSTANDARD LVCMOS33 } [get_ports { seg[5] }];
set_property -dict { PACKAGE_PIN L18 IOSTANDARD LVCMOS33 } [get_ports { seg[6] }];
## punto decimale
set_property -dict { PACKAGE_PIN H15 IOSTANDARD LVCMOS33 } [get_ports { dp }];
## anodi (8 cifre)
set_property -dict { PACKAGE_PIN J17 IOSTANDARD LVCMOS33 } [get_ports { an[0] }];
set_property -dict { PACKAGE_PIN J18 IOSTANDARD LVCMOS33 } [get_ports { an[1] }];
set_property -dict { PACKAGE_PIN T9  IOSTANDARD LVCMOS33 } [get_ports { an[2] }];
set_property -dict { PACKAGE_PIN J14 IOSTANDARD LVCMOS33 } [get_ports { an[3] }];
set_property -dict { PACKAGE_PIN P14 IOSTANDARD LVCMOS33 } [get_ports { an[4] }];
set_property -dict { PACKAGE_PIN T14 IOSTANDARD LVCMOS33 } [get_ports { an[5] }];
set_property -dict { PACKAGE_PIN K2  IOSTANDARD LVCMOS33 } [get_ports { an[6] }];
set_property -dict { PACKAGE_PIN U13 IOSTANDARD LVCMOS33 } [get_ports { an[7] }];

## =====================================================
## SWITCH (16)
## =====================================================
set_property -dict { PACKAGE_PIN U9  IOSTANDARD LVCMOS33 } [get_ports { switches[0] }];
set_property -dict { PACKAGE_PIN U8  IOSTANDARD LVCMOS33 } [get_ports { switches[1] }];
set_property -dict { PACKAGE_PIN R7  IOSTANDARD LVCMOS33 } [get_ports { switches[2] }];
set_property -dict { PACKAGE_PIN R6  IOSTANDARD LVCMOS33 } [get_ports { switches[3] }];
set_property -dict { PACKAGE_PIN R5  IOSTANDARD LVCMOS33 } [get_ports { switches[4] }];
set_property -dict { PACKAGE_PIN V7  IOSTANDARD LVCMOS33 } [get_ports { switches[5] }];
set_property -dict { PACKAGE_PIN V6  IOSTANDARD LVCMOS33 } [get_ports { switches[6] }];
set_property -dict { PACKAGE_PIN V5  IOSTANDARD LVCMOS33 } [get_ports { switches[7] }];
set_property -dict { PACKAGE_PIN U4  IOSTANDARD LVCMOS33 } [get_ports { switches[8] }];
set_property -dict { PACKAGE_PIN V2  IOSTANDARD LVCMOS33 } [get_ports { switches[9] }];
set_property -dict { PACKAGE_PIN U2  IOSTANDARD LVCMOS33 } [get_ports { switches[10] }];
set_property -dict { PACKAGE_PIN T3  IOSTANDARD LVCMOS33 } [get_ports { switches[11] }];
set_property -dict { PACKAGE_PIN T1  IOSTANDARD LVCMOS33 } [get_ports { switches[12] }];
set_property -dict { PACKAGE_PIN R3  IOSTANDARD LVCMOS33 } [get_ports { switches[13] }];
set_property -dict { PACKAGE_PIN P3  IOSTANDARD LVCMOS33 } [get_ports { switches[14] }];
set_property -dict { PACKAGE_PIN P4  IOSTANDARD LVCMOS33 } [get_ports { switches[15] }];

## =====================================================
## PULSANTI (5) - non usati dal gioco ma mappati per completezza
## Se il gioco non li usa, meglio rimuoverli dall'entity (vedi nota 2).
## =====================================================
set_property -dict { PACKAGE_PIN N17 IOSTANDARD LVCMOS33 } [get_ports { buttons[0] }];
set_property -dict { PACKAGE_PIN M18 IOSTANDARD LVCMOS33 } [get_ports { buttons[1] }];
set_property -dict { PACKAGE_PIN P17 IOSTANDARD LVCMOS33 } [get_ports { buttons[2] }];
set_property -dict { PACKAGE_PIN M17 IOSTANDARD LVCMOS33 } [get_ports { buttons[3] }];
set_property -dict { PACKAGE_PIN P18 IOSTANDARD LVCMOS33 } [get_ports { buttons[4] }];

## =====================================================
## Configurazione bitstream
## =====================================================
set_property CFGBVS VCCO [current_design];
set_property CONFIG_VOLTAGE 3.3 [current_design];

## =====================================================
## NOTE IMPORTANTI
## =====================================================
## 1. RESET ATTIVO BASSO: CPU_RESETN (C12) da' 0 quando premuto.
##    Il tuo codice usa rst attivo alto. Due opzioni:
##    a) invertire nel top-level: rst_interno <= not rst;
##    b) rimappare rst su un pulsante attivo alto (es. BTNC = N17).
##
## 2. Se l'entity system_top NON ha le porte buttons/switches/seg/an/dp,
##    rimuovi le righe corrispondenti per evitare errori di sintesi.

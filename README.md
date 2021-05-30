# STM32F103C8 "Blue Pill" RC-ESC Centrifuge
  
Timer 4 is configured to generate 1 PWM channel. No soft-PWM.  

## Pins
```
TIM4_CH1-TIM4_CH4 -> PB6, PB7, PB8, PB9 (PWM only outputting on PB9 currently)
Open Momentary Switch -> PA9
```  

## Requirements
Debian 9
```
$ sudo apt install build-essential gcc-arm-none-eabi gdb-multiarch
```
Get submodules (libopencm3 @d60d7802fd20821a766675545b6ef7a2207207a3)
```
git submodule update --init --recursive
```

## Compiling
```
$ make all
```
This will build libopencm3 and the controller code.
It will generate an ELF, a BIN and a HEX binary under build directory.


## Programming
Build is setup default running from offset 0x08000000 in eeprom, so without a bootloader.
Recommended usage is a Blackmagic Probe or STLinkV2 to program the .hex file.
Change these values as necessary if you want to have a bootloader.
The following will build assuming you have a bootloader sitting at the start of eeprom, and
the firmware will be chained to run from 0x08002000
```
make bootload
```

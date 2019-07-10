# name of the output files. Will generate $(OUTPUT).elf, $(OUTPUT).hex and $(OUTPUT).bin
OUTPUT  = esc_ctl

# here you can set your compiler prefix and/or tool-names
# usually there is no need to change.
# here you can set your compiler prefix and/or tool-names
# usually there is no need to change.
CC      = arm-none-eabi-gcc
OBJCOPY = arm-none-eabi-objcopy
OBJDUMP = arm-none-eabi-objdump
SIZE	= arm-none-eabi-size

# add further source files here
SRC  = src/main.c src/systick.c src/pwm.c
ASRC =
OBJ  = $(SRC:.c=.o) $(ASRC:.s=.o)

# linker settings regarding libopencm3
LOCM3_PATH = src/libopencm3
LOCM3_LIB  = $(LOCM3_PATH)/lib/libopencm3_stm32f1.a

# linkerscript comes from libopencm3
LDSCRIPT   = $(LOCM3_PATH)/lib/stm32/f1/stm32f103x8.ld
# override if we want a bootloader with the program starting at 0x08002000
LDSCRIPT_BOOTLOAD = bootload.ld

# compiler settings
OPT     = -Os
CFLAGS  = -fdata-sections -ffunction-sections -Wall -mcpu=cortex-m3 -mlittle-endian -mthumb -I $(LOCM3_PATH)/include/ $(OPT) -DSTM32F1
ASFLAGS =  $(CFLAGS)

# we use newlib-nano, which is much smaller than normal newlib.
LDFLAGS = -T $(LDSCRIPT) -L$(LOCM3_PATH)/lib -lopencm3_stm32f1 --static -nostartfiles -Wl,--gc-sections --specs=nano.specs --specs=nosys.specs

LDFLAGS_BOOTLOAD = -T $(LDSCRIPT_BOOTLOAD) -L$(LOCM3_PATH)/lib -lopencm3_stm32f1 --static -nostartfiles -Wl,--gc-sections --specs=nano.specs --specs=nosys.specs


all: $(LOCM3_LIB) $(OBJ)
	git submodule update --init --recursive
	$(CC) $(CFLAGS) $(OBJ) -o build/$(OUTPUT).elf $(LDFLAGS)
	$(OBJCOPY) -O binary build/$(OUTPUT).elf build/$(OUTPUT).bin
	$(OBJCOPY) -O ihex build/$(OUTPUT).elf build/$(OUTPUT).hex
	arm-none-eabi-size build/$(OUTPUT).elf
	ls -al build/$(OUTPUT).bin

$(LOCM3_LIB):
	make -C $(LOCM3_PATH) TARGETS=stm32/f1 $(MAKEFLAGS)

bootload: $(LOCM3_LIB) $(OBJ)
	git submodule update --init --recursive
	$(CC) $(CFLAGS) $(OBJ) -o build/$(OUTPUT).elf $(LDFLAGS_BOOTLOAD)
	$(OBJCOPY) -O binary build/$(OUTPUT).elf build/$(OUTPUT).bin
	$(OBJCOPY) -O ihex build/$(OUTPUT).elf build/$(OUTPUT).hex
	arm-none-eabi-size build/$(OUTPUT).elf
	ls -al build/$(OUTPUT).bin


%.o: %.c
	$(CC) -c $(CFLAGS) $< -o $@

%.o: %.s
	$(CC) -c $(ASFLAGS) $< -o $@

sizes:
	arm-none-eabi-size `find . -name "*.o"`

clean:
	rm -vf $(OBJ) build/$(OUTPUT).elf build/$(OUTPUT).hex build/$(OUTPUT).bin

mrproper:
	make -C $(LOCM3_PATH) clean
	make -C . clean

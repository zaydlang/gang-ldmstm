all: gang-ldmstm.S
	arm-none-eabi-gcc -nostdlib -mthumb-interwork -specs=gba.specs -B $(DEVKITARM)/arm-none-eabi/lib/ -lsysbase gang-ldmstm.S -o gang-ldmstm.out
	arm-none-eabi-objcopy gang-ldmstm.out -O binary gang-ldmstm.gba
	gbafix gang-ldmstm.gba
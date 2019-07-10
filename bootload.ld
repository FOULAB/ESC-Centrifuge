/*
 * Linker script for STM32F103 (64K flash, 20K RAM).
 *
 * This script is designed to be used for a boot loader
 * Sitting between 0x08000000 and 0x08002000 
 */

/* Define memory regions. */
MEMORY
{
	rom (rx) : ORIGIN = 0x08002000, LENGTH = 55K
	ram (rwx) : ORIGIN = 0x20000000, LENGTH = 20K
}

/* Include the common ld script. */
INCLUDE cortex-m-generic.ld

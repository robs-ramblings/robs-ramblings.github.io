#include <stddef.h>
#include <stdint.h>

#include "mmio.h"
#include "uart.h"
#include "printf.h"

intptr_t MMIO_BASE;

static uint32_t g_platform;
static uint32_t g_midr;

uint32_t get_platform()
{
  return g_platform;
}

uint32_t get_midr()
{
  return g_midr;
}

// The MMIO area base address, depends on the midr register (aka board type)
//BCM2835 reports 0x410FB767 .. MMIO Address 0x20000000  - PiA,A+,B,B+, Zero (single core arm11)
//BCM2836 reports 0x410FC073 .. MMIO Address 0x3F000000  - Pi2, quad core Cortex-A7
//BCM2837 reports 0x410FD034 .. MMIO Address 0x3F000000  - Pi3, Zero 2, quad core Cortex-A53
//BCM2711 reports 0x410fd083 .. mmio Address 0xFE000000  - Pi4, Cortex-A72

//Pi5 is not yet supported as I don't have one
//BCM2712 MMIO Address  0x1c00000000UL  Pi5 (not supported)

static inline void mmio_init(int id)
{
  switch (id) 
  {
    case 0xB76:  MMIO_BASE = 0x20000000; g_platform=1; break; // raspi1, raspi zero etc.
    case 0xC07:  MMIO_BASE = 0x3F000000; g_platform=2; break; // raspi2
    case 0xD03:  MMIO_BASE = 0x3F000000; g_platform=3; break; // raspi3 and raspi zero 2
    case 0xD08:  MMIO_BASE = 0xFE000000; g_platform=4; break; // raspi4

    //unknown id - no real good answers here, should probably crash or we could look for the mmio space
    //can't flash a light or print anything without the MMIO address
    default: 
      MMIO_BASE = 0x20000000; g_platform=1; break;  
  }
}

static void detect_platform(uint32_t midr)
{
  g_midr=midr;
  mmio_init((midr>>4)&0xfff);
}

// This function is required by printf
static void printf_uart_putc ( void*, char c)
{
	uart_putc(c);
}

extern void kernel_main();

//the MIDR register is passed in from the boot code 
#ifdef CONFIG_AARCH64
// arguments for AArch64: uint64_t dtb_ptr32, uint64_t midr, uint64_t x2, uint64_t x3
extern "C" void kernel_init(uint64_t, uint64_t midr, uint64_t, uint64_t)
#else
// arguments for AArch32: uint32_t midr, uint32_t r1, uint32_t atags
extern "C" void kernel_init(uint32_t midr, uint32_t, uint32_t)
#endif
{
  detect_platform((uint32_t)midr);

	uart_init();  //default init is 115200
  init_printf(0, printf_uart_putc);
  kernel_main();
  uart_puts("MAIN EXITED\n");
  while(1);
}
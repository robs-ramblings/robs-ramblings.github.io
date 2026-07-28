#include "pi-bare.h"

void kernel_main()
{
  uint32_t platform = get_platform();
  uint32_t midr = get_midr();

  printf("Platform = %d\n",platform);
  printf("MIDR = 0x%08x\n",midr);
}

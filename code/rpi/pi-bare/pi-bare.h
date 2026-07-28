#pragma once
#include <stddef.h>
#include <stdint.h>
#include "mmio.h"
#include "uart.h"
#include "printf.h"

// Loop <delay> times in a way that the compiler won't optimize away
inline void delay(int32_t count)
{
	asm volatile("__delay_%=: subs %[count], %[count], #1; bne __delay_%=\n"
		 : "=r"(count): [count]"0"(count) : "cc");
}

//the platform id
//1 for models A, B, A+, B+, and Zero
//2 for pi 2
//3 for pi 3 and pi Zero 2
//4 for pi 4
//
//TODO: At some point we can dive deeper and return the exact model but for now it doesn't matter
uint32_t get_platform();

//gets the ARM midr register (as read once by the startup code)
uint32_t get_midr();

#pragma once
#include <stddef.h>
#include <stdint.h>

void uart_init();
void uart_putc(uint8_t c);
uint8_t uart_getc();
void uart_puts(const char* str);

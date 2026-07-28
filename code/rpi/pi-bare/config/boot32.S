.section ".text.boot"

// Make _start global.
.globl _start

// r0 -> midr register - this is suppose to be zero but we are doing our own thing so we'll reuse it
// r1 -> 0x00000C42 - machine id
// r2 -> 0x00000100 - start of ATAGS

_start:
  //get the midr in to r0 and leave it here as we pass it to the kernel
  //if we are a single core pi, skip mpidr. 
  //We can crudely check for the single core pi by checking bits 8-5 for 0xB7
  mrc p15, 0, r0, c0, c0, 0
  lsr r5,r0,#8
  and r5,r5,#0xff
  cmp r5,#0xb7
  beq single_core

	// Shut off extra cores - this is technically valid for processors with a single core as they return 0 in mpidr
  // However it was only fully implemented in armv7, single core armv6 (which is the pi0 and pi 1) will
  // generate an exception if you read mpidr and we'll crash!
  // We should read midr and see if we are an early pi and skip this
	mrc p15, 0, r5, c0, c0, 5
	and r5, r5, #3
	cmp r5, #0
	bne halt

single_core:
	// Setup the stack to go down from the org of this file
	ldr r5, =_start
	mov sp, r5

	// Clear out bss.
	ldr r4, =__bss_start
	ldr r9, =__bss_end
	mov r5, #0
	mov r6, #0
	mov r7, #0
	mov r8, #0
	b       2f

1:
	// store multiple at r4.
	stmia r4!, {r5-r8}

	// If we are still below bss_end, loop.
2:
	cmp r4, r9
	blo 1b
	
  ldr r3, =kernel_init
	blx r3

	// halt
halt:
	wfe
	b halt
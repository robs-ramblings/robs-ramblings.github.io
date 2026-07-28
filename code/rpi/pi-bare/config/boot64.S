.section ".text.boot"
.globl _start

// x0 -> 32 bit pointer to DTB in memory (primary core only) / 0 (secondary cores)
// x1 -> machine_id (midr register)
// x2 -> 0
// x3 -> 0
// x4 -> 32 bit kernel entry point, _start location
// The start below does not use these registers
_start:
    //we don't have to park the none zero processors, with the latest firmware they are already parked
    //when this code runs but we'll do it anyway because it does no harm. 
    //It'll make things work on old firmware and and allow emulation on qemu because it doesn't run firmware or park processors
    mrs     x5, mpidr_el1
    and     x5,x5,#3
    cbnz    x5, halt

    // only core0 gets to here
    // set a stack pointer  (this gives 64bit code a 512K stack)
    ldr     x5, =_start
    mov     sp, x5

    // clear bss
    ldr     x5, =__bss_start
    ldr     w6, =__bss_size
1:  cbz     w6, 2f
    str     xzr, [x5], #8
    sub     w6, w6, #1
    cbnz    w6, 1b

    //get midr in to r1 (overwrite one of the default zero values)
    mrs     x1, midr_el1
  
    // jump to C code, should not return
2:  bl      kernel_init
    // if the kernel returns - halt
halt:
    wfe
    b halt


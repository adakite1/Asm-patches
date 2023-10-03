.nds
.include "regionSelect.asm"

.open "arm9.bin", 0x02000000

.org US_0x206D578
    ; The first place where the wavi pointer table is accessed.
    ; r1 contains the index, which is originally multiplied by 2
    ; to convert it to the byte offset, but this patch changes
    ; it to multiplying by 4 since each pointer is now 32-bits.
    ; The ldrh is also changed to an ldr instead to read a full word 
    ; instead of half as before.
    stmdb sp!, {lr}
    bl GetPointerHook
    ldmia sp!, {lr}

.org US_0x206D464
    ; As the insertion point is a non-leaf function, code for saving 
    ; the old link register can be omitted.

    ; The second place where the wavi pointer table is accessed,
    ; specifically, after the cmp at 0x206D454, only running if
    ; the pointer is not null. I'm guessing this is related to sample
    ; copying code, as only applying the first patch results in 
    ; samples playing, but playing weirdly.
    bl GetPointerHookWrapper
    nop

.org US_0x206D5B0
    ; The code used to obtain a byte offset for prgi pointer tables 
    ; is pretty much identical to the code for wavi pointer tables,
    ; but the two are still separate functions. This one is for the
    ; prgi tables.
    stmdb sp!, {lr}
    bl GetPointerHook
    ldmia sp!, {lr}

.close

.open "overlay_0036.bin", 0x023A7080
.orga 0x30F70 ; Offset relative to the start of the overlay. This is where the common area begins.
.area 0x48 ; So you don't accidentally overwrite something else
GetPointerHookWrapper:
    ; r7 = index
    ; r2 = pointer table start address
    ; returns r1 = the pointer value
    stmdb sp!, {r0, r2-r3, r7, lr}

    ; Setup the call parameters
    mov r1,r7

    ; Call
    bl GetPointerHook

    ; Get the return value
    mov r1,r0

    ldmia sp!, {r0, r2-r3, r7, pc} ; Return back to the original code
GetPointerHook: ; Define a global label so we can use it in the code above
    ; r1 = index
    ; r2 = pointer table start address
    ; returns r0 = the pointer value
    stmdb sp!, {r1-r3, lr}

    ldr r0,[r2] ; Load the first word of the pointer table

    ; Build 0xFFFFFFFF
    mvn r3,0h ; r3 = -1 (0xFFFFFFFF)
    cmp r0,r3

    ; Only run this if the previous check returned equal
    moveq r0,r1, lsl #0x2
    addeq r0,#0x4
    ldreq r0,[r2,r0]

    ; Only run this if the previous check returned not equal
    blne GetPointerNormalHook

    ; This is the original 3rd instruction, which had to be overwritten to preserve the old link register since some of the callers of this code is a leaf function
    cmp r0,0h

    ldmia sp!, {r1-r3, pc} ; Return back to the original code
GetPointerNormalHook:
    mov r0,r1, lsl #0x1
    ldrh r0,[r2,r0]

    bx lr ; Return back to the original code
.endarea
.close
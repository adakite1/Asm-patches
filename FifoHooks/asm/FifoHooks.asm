; FifoHooks v1.0.0
; Fifo hooks for easy IPC with the arm7 sub-processor.
; The hook is enabled at the same time as hook 0x7, which is the audio events hook.
; Reserves event type 18 (0x12).
; Events will be processed differently depending on if the "flag" is set on the event.
; If it is set to 0:
;  The upperbits part of any received 0x12 event will be interpreted as the address to the callback, which will be called from the respective processor.
;  The original callback arguments will be passed to the callback untouched.
;  An additional argument r3 will contain either 7 or 9 depending on which processor the callback was called from.
; If it is set to 1:
;  The upperbits part of any received 0x12 event will be interpreted as an address pointing to a struct with its first field containing the callback address.
;  The original callback arguments will be passed to the callback untouched, and r1 will still contain the address to the callback definition struct.
;  - Callback definition struct:
;  - 0x0             callback address
;  - 0x4 onwards     any data.
;  An additional argument r3 will contain either 7 or 9 depending on which processor the callback was called from.
; 
; See the offsets file for each region for information on the functions used to send messages.

.include "regionSelect.asm"

.nds

.definelabel EventType, 0x12

.open "arm9.bin", 0x02000000
	.org Arm9RegisterFifoCallbackHook
	.area 0x4
        bl Arm9RegisterCallback
	.endarea
.close
.open "arm9.bin", 0x02000000
    .org Arm9TemporaryHook
    .area 0x20
    arm9_callback_addr_literal:
        .word Arm9Callback
    Arm9RegisterCallback:
        ; Save r0 and r1
        stmdb r13!,{r0,r1,r14}

        ldr r0,=EventType
        ldr r1,[arm9_callback_addr_literal]
        bl RegisterIpcEventTypeCallback_Arm9

        ; Restore r0 and r1
        ldmia r13!,{r0,r1,r14}

        ; Original instruction
        cmp r0,#0x0

        bx lr
    .endarea
.close

.gba
.arm

.open "arm7.bin", 0x037F7E18
	.org Arm7RegisterFifoCallbackHook
	.area 0x4
        b Arm7RegisterCallback
arm7_register_callback_return:
	.endarea
.close
.open "arm9.bin", 0x02000000
    .org DSEEventsTable+(0xF7*4)
    .area 0x4
    arm7_callback_addr_literal:
        .word Arm7Callback
    .endarea

    .org DSEEventsTable+(0xF9*4) ; Actual address: 0x20B0D34 (us)
    .area 0x1C
    Arm7RegisterCallback:
        ; Save r0 and r1
        stmdb r13!,{r0,r1,r14}

        ldr r0,=EventType
        ldr r1,[arm7_callback_addr_literal]
        bl RegisterIpcEventTypeCallback_Arm7

        ; Restore r0 and r1
        ldmia r13!,{r0,r1,r14}

        ; Original instruction
        mov r0,#7h

        b arm7_register_callback_return
	.endarea
.close

.open "arm9.bin", 0x02000000
    .org DSEEventsTable+(0xB7*4) ; Actual address: 0x20B0C2C (us)
    .area 0x14
    Arm9Callback:
        ; Callback args: [event_type (7 => sound op), upperbits, flag]
        stmdb r13!,{r0-r12,r14}

        mov r3,#9 ; arm9

        b CallbackCommon
    Arm7Callback: ; Actual address: 0x20B0C38 (us)
        ; Callback args: [event_type (7 => sound op), upperbits, flag]
        stmdb r13!,{r0-r12,r14}

        b ContinueArm7Callback
	.endarea
    .org DSEEventsTable+(0xC4*4)
    .area 0x1C
    ContinueArm7Callback:
        mov r3,#7 ; arm7

        ; b CallbackCommon
    CallbackCommon:
        mov r4,r1
        ; Check if the flag is set, in which case read an address from "upperbits".
        cmp r2,1h
        moveq lr,pc
        ldreq pc,[r4]
        ; ldreq r4,[r4]
        ; blx r4 ; Unsupported by ARM v4t

        ldmia r13!,{r0-r12,r14}
        bx lr
	.endarea
.close

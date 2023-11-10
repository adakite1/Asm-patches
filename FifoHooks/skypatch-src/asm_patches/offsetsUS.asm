; These two labels are included for reference. These are the APIs for pushing events over the IPC.
; After branching, they will return a negative value if an error occurred, or zero on success, so the usual way
; to ensure a message is sent is to loop until it returns zero.
.definelabel PushToFifoArm7, 0x37FE448                  ; r0 = 32-bit message, must be formatted as follows:
; ====== MESSAGE FORMATTING ======
; Fifo messages should be formatted as follows:
; 00000000000000000000000000011111
; --------------------------*=====
; 26-bit message             5-bit event type (at most 32 event types can be registered in total)
;                           single-bit flag
.definelabel PushFormattedMessageToFifoArm9, 0x207DB20  ; r0 = event channel number (set to 0x12 for FifoHooks messages), r1 = 26-bit message, r2 = flag.

.definelabel Arm9RegisterFifoCallbackHook, 0x207D284
.definelabel RegisterIpcEventTypeCallback_Arm9, 0x207DAB0
; Derived from the end address of the arm9 entry function zero-fill, also the load address for overlay0, which is loaded in after the callback set is complete.
.definelabel Arm9TemporaryHook, 0x22BCA80 ; This hook will be overwritten by other code, but it will be used before that happens so it's ok.

.definelabel Arm7RegisterFifoCallbackHook, 0x3801EF0 ; Address before mapping:    0x238A0D8
.definelabel RegisterIpcEventTypeCallback_Arm7, 0x37FE39C ; Address before mapping: 0x2386584
.definelabel DSEEventsTable, 0x20B0950


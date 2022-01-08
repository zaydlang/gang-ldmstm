.global _start
.arm

    _start:
    .word 0xE9BF8000 @ ldm pc!, {pc} (unconditional branch to 0x0A82843D, a convenient value obtained
                     @ from the nintendo logo)
    @ b main

@ thanks marie for this template for a GBA header:
    @ compressed Nintendo logo - BIOS will reject programs without this data!
    .byte        0x24, 0xFF, 0xAE, 0x51, 0x69, 0x9A, 0xA2, 0x21, 0x3D, 0x84
    .byte        0x82, 0x0A, 0x84, 0xE4, 0x09, 0xAD, 0x11, 0x24, 0x8B, 0x98
    .byte        0xC0, 0x81, 0x7F, 0x21, 0xA3, 0x52, 0xBE, 0x19, 0x93, 0x09
    .byte        0xCE, 0x20, 0x10, 0x46, 0x4A, 0x4A, 0xF8, 0x27, 0x31, 0xEC
    .byte        0x58, 0xC7, 0xE8, 0x33, 0x82, 0xE3, 0xCE, 0xBF, 0x85, 0xF4
    .byte        0xDF, 0x94, 0xCE, 0x4B, 0x09, 0xC1, 0x94, 0x56, 0x8A, 0xC0
    .byte        0x13, 0x72, 0xA7, 0xFC, 0x9F, 0x84, 0x4D, 0x73, 0xA3, 0xCA
    .byte        0x9A, 0x61, 0x58, 0x97, 0xA3, 0x27, 0xFC, 0x03, 0x98, 0x76
    .byte        0x23, 0x1D, 0xC7, 0x61, 0x03, 0x04, 0xAE, 0x56, 0xBF, 0x38
    .byte        0x84, 0x00, 0x40, 0xA7, 0x0E, 0xFD, 0xFF, 0x52, 0xFE, 0x03
    .byte        0x6F, 0x95, 0x30, 0xF1, 0x97, 0xFB, 0xC0, 0x85, 0x60, 0xD6
    .byte        0x80, 0x25, 0xA9, 0x63, 0xBE, 0x03, 0x01, 0x4E, 0x38, 0xE2
    .byte        0xF9, 0xA2, 0x34, 0xFF, 0xBB, 0x3E, 0x03, 0x44, 0x78, 0x00
    .byte        0x90, 0xCB, 0x88, 0x11, 0x3A, 0x94, 0x65, 0xC0, 0x7C, 0x63
    .byte        0x87, 0xF0, 0x3C, 0xAF, 0xD6, 0x25, 0xE4, 0x8B, 0x38, 0x0A
    .byte        0xAC, 0x72, 0x21, 0xD4, 0xF8, 0x07

    .byte        0x6C, 0x64, 0x6D, 0x73, 0x74, 0x6D, 0x20, 0x75, 0x77, 0x75, 0, 0 
                                                    @ Game Title
    .byte        0, 0, 0, 0                         @ Game Code
    .byte        0, 0                               @ Maker Code
    .byte        0x96                               @ 96h
    .byte        0                                  @ Unit Code
    .byte        0, 0, 0, 0, 0, 0, 0, 0             @ Device Type and 7x 0
    .byte        0x69                               @ Software Version
    .byte        0xBB                               @ Header Checksum
    .byte        0, 0                               @ 2x 0

.org 0x0082843C
nintendo_logo:
    .word 0xE9BF8000 @ ldm pc!, {pc} (unconditional branch to main)
    .word 0x0
    .word 0x0
    .word main

@ our beloved literal pool
@ note that the literal pool is read from BACKWARDS

@ dma stuffs
.word 0x03000004     @ so we can load the concatenated back after the DMAs end
.word 0x80000001     @ immediate DMA in halfword mode (1 transfer)
.word 0x040000DC     @ DMA3CNT
.word 0x03000006     @ value to be stored in DMA3DAD, the second time
.word 0x040000D8     @ DMA3's DAD
.word 0x80000001     @ immediate DMA in halfword mode (1 transfer)
.word 0x040000DC     @ DMA3CNT
.word 0x03000004     @ value to be stored in DMA3DAD, the first time 
.word 0x040000D8     @ DMA3's DAD
.word 0x03000000     @ value to be stored in DMA3SAD
.word 0x040000D4     @ DMA3 SAD

@ drawing initialization
.word 0x06000000 @ VRAM
.word 0x00007c00 @ color #1
.word 0x000003e0 @ color #2
.word 0x0000001f @ color #3
.word 0x06018000

@ lcd initialization
.word 0x00000403 @ value to be stored in DISPCNT
.word 0x04000000 @ DISPCNT

@ increments the register by 0x80
.macro _INC_80 reg
    stmia \reg!, {r4-r11}
    stmia \reg!, {r4-r11}
    stmia \reg!, {r4-r11}
    stmia \reg!, {r4-r11}
.endm

.macro _MOV reg_dst, reg_src
    stmia r13!, {\reg_src}
    ldmdb r13!, {\reg_dst}
.endm

.macro LOOP_BODY_1
    _CONCAT_CHEAT r1 r2
    stmia r9!, {r0}

    _INC_80 r1
    _INC_80 r2

    _CONCAT_CHEAT r3 r1
    stmia r9!, {r0}

    _INC_80 r3
    _INC_80 r1

    _CONCAT_CHEAT r2 r3
    stmia r9!, {r0}

    _INC_80 r2
    _INC_80 r3
.endm

.macro LOOP_BODY_2
    LOOP_BODY_1
    LOOP_BODY_1
.endm

.macro LOOP_BODY_4
    LOOP_BODY_2
    LOOP_BODY_2
.endm

.macro LOOP_BODY_8
    LOOP_BODY_4
    LOOP_BODY_4
.endm

.macro LOOP_BODY_16
    LOOP_BODY_8
    LOOP_BODY_8
.endm

.macro LOOP_BODY_32
    LOOP_BODY_16
    LOOP_BODY_16
.endm

.macro LOOP_BODY_64
    LOOP_BODY_32
    LOOP_BODY_32
.endm

.macro LOOP_BODY_128
    LOOP_BODY_64
    LOOP_BODY_64
.endm

.macro LOOP_BODY_256
    LOOP_BODY_128
    LOOP_BODY_128
.endm

.macro LOOP_BODY_512
    LOOP_BODY_256
    LOOP_BODY_256
.endm

.macro LOOP_BODY_1024
    LOOP_BODY_512
    LOOP_BODY_512
.endm

.macro LOOP_BODY_2048
    LOOP_BODY_1024
    LOOP_BODY_1024
.endm

.macro LOOP_BODY_4096
    LOOP_BODY_2048
    LOOP_BODY_2048
.endm

.macro LOOP_BODY_8192
    LOOP_BODY_4096
    LOOP_BODY_4096
.endm

.macro LOOP_BODY_16384
    LOOP_BODY_8192
    LOOP_BODY_8192
.endm

@ test macro for concat that does not use ldm/stm
@ relies on r12 pointing to the bottom of the dma stuffs section in the literal pool
@ this macro is kinda weird so here's an explanation:
@ itll concatenate two halfwords stored in low_reg and high_reg. first, it uses DMA
@ to move the halfword in high_reg to the upper halfword in label concat_dest. then it uses 
@ DMA again to move the halfword in low_reg to the lower halfword in label concat_dest.
.macro _CONCAT_CHEAT low_reg high_reg
    ldmdb r12!, {r0, r6} @ load DMA3SAD and concat_src
    stmia r6!, {r0} @ write to DMA3SAD

    _MOV r7, r0 @ save the address of concat_src
    stmia r7!, {\low_reg} @ store the low reg value into concat_src

    ldmdb r12!, {r0, r6} @ load DMA3DAD and concat_dst
    stmia r6!, {r0} @ write to DMA3DAD

    ldmdb r12!, {r0, r6} @ load DMA3CNT and the control value
    stmia r6!, {r0} @ enable dma
    
    ldmda r7!, {r6} @ bring r7 back down (it was incremented in its previous store)
    stmia r7!, {\high_reg} @ store the high reg value into concat_src

    ldmdb r12!, {r0, r6} @ load DMA3DAD and concat_dst + 2
    stmia r6!, {r0} @ write to DMA3DAD

    ldmdb r12!, {r0, r6} @ load DMA3CNT and the control value
    stmia r6!, {r0} @ enable dma

    ldmdb r12!, {r6} @ load concat_dst
    ldmda r6!, {r0} @ get the concatenated value from concat_dst

    @ bring r12 back to where it used to be
    ldmib r12!, {r6, r7}
    ldmib r12!, {r6, r7}
    ldmib r12!, {r6, r7}
    ldmib r12!, {r6, r7}
    ldmib r12!, {r6, r7}
    ldmib r12!, {r6}
.endm


main:
    @ we need to use PC to try to get a register to point to ROM, so we can use it to load literals. 
    @ well, PC is in rom. lets see what we can do.
    _MOV r12, r15

    @ r12 is still not ready for use. we need to use repeated ldmdb to move r12 back
    @ a bit to the end of the literal pool.
    ldmdb r12!, {r0-r2}

    @ with r12 at the end of the literal pool, we can use literals now. great! :D

    @ load DISPCNT into r0
    ldmdb r12!, {r0}

    @ we want to enable BG2 and mode 3, so let's grab that from the literal pool too
    ldmdb r12!, {r1}

    @ store into DISPCNT
    stmia r0, {r1}

copy_this:
    @ load the address of VRAM into r9
    @ load the three base colors into r1, r2, r3
    @ load the last address of VRAM into r4
    ldmdb r12!, {r4}
    ldmdb r12!, {r1-r3}
    ldmdb r12!, {r9}
        
    @ so, here's where things get really fun
    @ basically, gang.gba likes to store 3 halfwords per loop. one for r1,
    @ one for r2, and one for r3. but i can't really store halfwords can i?
    @ so instead we're going to store words only. how? we can use the concatenation
    @ macro to store r1 | r2, then r3 | r1, then r2 | r3.
    LOOP_BODY_8192

infin:
    .word 0xE9BF8000 @ ldm pc!, {pc} 
    .word 0x0
    .word 0x0
    .word infin

@ original gang
@ 0x0000000000000000:  04 00 A0 E3    mov  r0, #4
@ 0x0000000000000004:  00 0C A0 E1    lsl  r0, r0, #0x18
@ 0x0000000000000008:  01 1B A0 E3    mov  r1, #0x400
@ 0x000000000000000c:  03 10 81 E2    add  r1, r1, #3
@ 0x0000000000000010:  B0 10 C0 E1    strh r1, [r0]
@ 0x0000000000000014:  1F 1B A0 E3    mov  r1, #0x7c00
@ 0x0000000000000018:  3E 2E A0 E3    mov  r2, #0x3e0
@ 0x000000000000001c:  1F 30 A0 E3    mov  r3, #0x1f
@ 0x0000000000000020:  06 00 A0 E3    mov  r0, #6
@ 0x0000000000000024:  00 0C A0 E1    lsl  r0, r0, #0x18
@ 0x0000000000000028:  03 4C A0 E3    mov  r4, #0x300
@ 0x000000000000002c:  84 43 A0 E1    lsl  r4, r4, #7
@ 0x0000000000000030:  00 40 84 E0    add  r4, r4, r0
@ 0x0000000000000034:  B0 10 C0 E1    strh r1, [r0]
@ 0x0000000000000038:  02 00 80 E2    add  r0, r0, #2
@ 0x000000000000003c:  80 10 81 E2    add  r1, r1, #0x80
@ 0x0000000000000040:  B0 20 C0 E1    strh r2, [r0]
@ 0x0000000000000044:  02 00 80 E2    add  r0, r0, #2
@ 0x0000000000000048:  80 20 82 E2    add  r2, r2, #0x80
@ 0x000000000000004c:  B0 30 C0 E1    strh r3, [r0]
@ 0x0000000000000050:  02 00 80 E2    add  r0, r0, #2
@ 0x0000000000000054:  80 30 83 E2    add  r3, r3, #0x80
@ 0x0000000000000058:  04 00 50 E1    cmp  r0, r4
@ 0x000000000000005c:  F4 FF FF BA    blt  #0x34
@ 0x0000000000000060:  FE FF FF EA    b    #0x60
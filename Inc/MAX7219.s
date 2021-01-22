// MAX7219.s
.syntax unified
.cpu cortex-m4
.thumb

.text
	//use GPIOB
	//DIN(PB3), CS(PB4), CLK(PB5)
	.equ DIN, 0x08
	.equ CS, 0x10
	.equ CLK, 0x20

	.global max7219_init
	.global MAX7219Send
	.global delay

	.equ RCC_AHB2ENR	, 0x4002104C
	.equ GPIOB_MODER	, 0x48000400
	.equ RCC_AHB2ENR	, 0x4002104C
	.equ GPIOB_OTYPER	, 0x48000404
	.equ GPIOB_OSPEEDR	, 0x48000408
	.equ GPIOB_PUPDR	, 0x4800040C
	.equ GPIOB_ODR		, 0x48000414
	.equ GPIOB_BSRR	, 0x48000418
	.equ GPIOB_BRR		, 0x48000428

	.equ DIGIT_0,		0x01
	.equ DECODE_MODE,	0x09
	.equ INTENSITY,	0x0A
	.equ SCAN_LIMIT,	0x0B
	.equ SHUT_DOWN,	0x0C
	.equ DISPLAY_TEST,	0x0F
	.equ SEC, 1

delay:
   //TODO: Write a delay 1 sec function
	push {r7}
	ldr r7, =SEC
delay_1:
	subs r7, r7, #1 //1 cycle
	cmp r7, #0x00 //1 cycle
	bne delay_1 //2 cycle
	pop {r7}
BX LR

MAX7219Send:
	//input parameter: r0 is ADDRESS , r1 is DATA
	//TODO: Use this function to send a message to max7219
	push {r0, r1, r2, r3, r4, r5, r6, r7, r8}
	lsl r0, r0, #8
	add r0, r0, r1
	ldr r1, =DIN
	ldr r2, =CS
	ldr r3, =CLK
	ldr r4, =GPIOB_BSRR
	ldr r5, =GPIOB_BRR
	mov r6, #16 //r6 is counter
.MAX7219Send_Loop:
	mov r7, #1 //r7 for mask
	sub r8, r6, #1 //r8 = r6 - 1
	lsl r7, r7, r8 //r7 = r7 << r8
	str r3, [r5] //CLK

	//add delay here due to high freq clk
	push {LR}
	bl delay
	pop {LR}
	//add delay end

	tst r7, r0
	beq .bit_not_set
	str r1, [r4]

	//add delay here due to high freq clk
	push {LR}
	bl delay
	pop {LR}
	//add delay end

	b .if_done
.bit_not_set:
	str r1, [r5]
	//add delay here due to high freq clk
	push {LR}
	bl delay
	pop {LR}
	//add delay end
.if_done:
	str r3, [r4] //CLK
	//add delay here due to high freq clk
	push {LR}
	bl delay
	pop {LR}
	//add delay end
	subs r6, r6, #1
	bgt .MAX7219Send_Loop
	str r2, [r5]
	//add delay here due to high freq clk
	push {LR}
	bl delay
	pop {LR}
	//add delay end
	str r2, [r4]
	pop {r0, r1, r2, r3, r4, r5, r6, r7, r8}
	BX LR

max7219_init:
	//TODO: Initialize max7219 registers
	push {LR}
	ldr r0, =DECODE_MODE
	mov r1, #0xFF
	bl MAX7219Send
	ldr r0, =SCAN_LIMIT
	mov r1, #0x0
	bl MAX7219Send
	ldr r0, =INTENSITY
	mov r1, #0xA
	bl MAX7219Send
	ldr r0, =SHUT_DOWN
	mov r1, #0x1
	bl MAX7219Send
	pop {LR}
	BX LR

# Complex Assembly Functions

## Memory sections

1. Register Area
2. Stack
3. Open Memory

## Navigation between sections

- Compiler logs current position
- Registers can be navigated relative to zero index

## Registers

$r0 := 0 (constant to be replaced in code)
$r1 .. $r31 := all purpose registers
$io := Input/Output register (translates to read / write instruction)
$t1 .. $t8:= Registers to be used by the assembler only

## Register cell map

| cell | register | description                        |
| ---- | -------- | ---------------------------------- |
| 0    | $t1      | Start of hidden registers          |
| 8    | $r1      | All purpose programmable registers |
| 40   | $mem     | Random access memory               |

## Add function

1. Store current position
2. Move to reg 1
3. move reg 1 into t1, t2
4. move t2 into reg 1
5. move to t1
6. move t1 to reg 2
7. return to starting position

### add $10 $11:

Setup: >>>>>>>>>>>>>>>>>>++++++++++>+++++<<<<<<<<<<<<<<<<<<<

Move to reg1: >>>>>>>>>>>>>>>>>> (move to operation)
Move reg 1 into t1, t2: [-<<<<<<<<<<<<<<<<<<+>+>>>>>>>>>>>>>>>>>] (reg1 to t1)
Move t2 into reg 1: <<<<<<<<<<<<<<<<<[->>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<] (reg1 to t2)
Move to t1: <
Move t1 to reg 2: [->>>>>>>>>>>>>>>>>>>+<<<<<<<<<<<<<<<<<<<] (t2 to reg2)

Optimization possible:

1. Moving reg1 to t1
2. Moving t1 to reg1 and reg2
3. Return to starting position

(Further optimization by checking the distances of reg1, reg2, t1 to avoid unnecessary steps)

### sub $5, $12

1. Move reg1 into t1
2. Move t1 into reg1, remove from reg2

while reg1:
reg1 --
t1 ++

### loop

Must store loop register and origin
Origin should be always the loop register inside loop
Old origin should be set on loopend

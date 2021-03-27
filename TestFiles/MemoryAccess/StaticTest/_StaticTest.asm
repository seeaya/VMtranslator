// StaticTest.vm ------------------------------------------------------------
//  This file is part of www.nand2tetris.org
//  and the book "The Elements of Computing Systems"
//  by Nisan and Schocken, MIT Press.
//  File name: projects/07/MemoryAccess/StaticTest/StaticTest.vm
//  Executes pop and push commands using the static segment.
// push constant 111
@111
D=A
@SP
A=M
M=D
@SP
M=M+1
// push constant 333
@333
D=A
@SP
A=M
M=D
@SP
M=M+1
// push constant 888
@888
D=A
@SP
A=M
M=D
@SP
M=M+1
// pop static 8
@StaticTest.vm.8
D=A
@0
D=D+A
@13
M=D
@SP
M=M-1
A=M
D=M
@13
A=M
M=D
// pop static 3
@StaticTest.vm.3
D=A
@0
D=D+A
@13
M=D
@SP
M=M-1
A=M
D=M
@13
A=M
M=D
// pop static 1
@StaticTest.vm.1
D=A
@0
D=D+A
@13
M=D
@SP
M=M-1
A=M
D=M
@13
A=M
M=D
// push static 3
@StaticTest.vm.3
D=A
@0
A=D+A
D=M
@SP
A=M
M=D
@SP
M=M+1
// push static 1
@StaticTest.vm.1
D=A
@0
A=D+A
D=M
@SP
A=M
M=D
@SP
M=M+1
// sub
@SP
M=M-1
A=M
D=M
@SP
M=M-1
A=M
D=M-D
@SP
A=M
M=D
@SP
M=M+1
// push static 8
@StaticTest.vm.8
D=A
@0
A=D+A
D=M
@SP
A=M
M=D
@SP
M=M+1
// add
@SP
M=M-1
A=M
D=M
@SP
M=M-1
A=M
D=D+M
@SP
A=M
M=D
@SP
M=M+1
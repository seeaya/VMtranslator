// SimpleFunction.vm ------------------------------------------------------------
//  This file is part of www.nand2tetris.org
//  and the book "The Elements of Computing Systems"
//  by Nisan and Schocken, MIT Press.
//  File name: projects/08/FunctionCalls/SimpleFunction/SimpleFunction.vm
//  Performs a simple calculation and returns the result.
// function SimpleFunction.test 2
(SimpleFunction.test)
@2
D=A
@13
M=D
(SimpleFunction.test$$initStart)
@13
D=M
@SimpleFunction.test$$initEnd
D;JEQ
D=D-1
@13
M=D
D=0
@SP
A=M
M=D
@SP
M=M+1
@SimpleFunction.test$$initStart
0;JMP
(SimpleFunction.test$$initEnd)
// push local 0
@LCL
A=M
D=A
@0
A=D+A
D=M
@SP
A=M
M=D
@SP
M=M+1
// push local 1
@LCL
A=M
D=A
@1
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
// not
@SP
M=M-1
A=M
M=!M
@SP
M=M+1
// push argument 0
@ARG
A=M
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
// push argument 1
@ARG
A=M
D=A
@1
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
// return
@LCL
D=M
@13
M=D
@5
A=D-A
D=M
@14
M=D
@SP
M=M-1
A=M
D=M
@ARG
A=M
M=D
@ARG
D=M+1
@SP
M=D
@13
D=M
@1
D=D-A
A=D
D=M
@THAT
M=D
@13
D=M
@2
D=D-A
A=D
D=M
@THIS
M=D
@13
D=M
@3
D=D-A
A=D
D=M
@ARG
M=D
@13
D=M
@4
D=D-A
A=D
D=M
@LCL
M=D
@14
A=M
0;JMP
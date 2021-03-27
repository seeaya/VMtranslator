// FibonacciSeries.vm ------------------------------------------------------------
//  This file is part of www.nand2tetris.org
//  and the book "The Elements of Computing Systems"
//  by Nisan and Schocken, MIT Press.
//  File name: projects/08/ProgramFlow/FibonacciSeries/FibonacciSeries.vm
//  Puts the first argument[0] elements of the Fibonacci series
//  in the memory, starting in the address given in argument[1].
//  Argument[0] and argument[1] are initialized by the test script 
//  before this code starts running.
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
//  that = argument[1]
// pop pointer 1
@3
D=A
@1
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
// push constant 0
@0
D=A
@SP
A=M
M=D
@SP
M=M+1
//  first element in the series = 0
// pop that 0
@THAT
D=M
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
// push constant 1
@1
D=A
@SP
A=M
M=D
@SP
M=M+1
//  second element in the series = 1
// pop that 1
@THAT
D=M
@1
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
// push constant 2
@2
D=A
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
//  num_of_elements -= 2 (first 2 elements are set)
// pop argument 0
@ARG
D=M
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
// label MAIN_LOOP_START
($MAIN_LOOP_START)
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
//  if num_of_elements > 0, goto COMPUTE_ELEMENT
// if-goto COMPUTE_ELEMENT
@SP
M=M-1
A=M
D=M
@$COMPUTE_ELEMENT
D;JNE
//  otherwise, goto END_PROGRAM
// goto END_PROGRAM
@$END_PROGRAM
0;JMP
// label COMPUTE_ELEMENT
($COMPUTE_ELEMENT)
// push that 0
@THAT
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
// push that 1
@THAT
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
//  that[2] = that[0] + that[1]
// pop that 2
@THAT
D=M
@2
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
// push pointer 1
@3
D=A
@1
A=D+A
D=M
@SP
A=M
M=D
@SP
M=M+1
// push constant 1
@1
D=A
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
//  that += 1
// pop pointer 1
@3
D=A
@1
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
// push constant 1
@1
D=A
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
//  num_of_elements--
// pop argument 0
@ARG
D=M
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
// goto MAIN_LOOP_START
@$MAIN_LOOP_START
0;JMP
// label END_PROGRAM
($END_PROGRAM)
; RUN: opt < %s -instsimplify -S | FileCheck %s

define i32 @test1(i32 %A) {
; CHECK-LABEL: @test1(
; CHECK-NEXT:    ret i32 %A
;
  %B = or i32 %A, 0
  ret i32 %B
}

define i32 @test2(i32 %A) {
; CHECK-LABEL: @test2(
; CHECK-NEXT:    ret i32 -1
;
  %B = or i32 %A, -1
  ret i32 %B
}

define i8 @test2a(i8 %A) {
; CHECK-LABEL: @test2a(
; CHECK-NEXT:    ret i8 -1
;
  %B = or i8 %A, -1
  ret i8 %B
}

define i1 @test3(i1 %A) {
; CHECK-LABEL: @test3(
; CHECK-NEXT:    ret i1 %A
;
  %B = or i1 %A, false
  ret i1 %B
}

define i1 @test4(i1 %A) {
; CHECK-LABEL: @test4(
; CHECK-NEXT:    ret i1 true
;
  %B = or i1 %A, true
  ret i1 %B
}

define i1 @test5(i1 %A) {
; CHECK-LABEL: @test5(
; CHECK-NEXT:    ret i1 %A
;
  %B = or i1 %A, %A
  ret i1 %B
}

define i32 @test6(i32 %A) {
; CHECK-LABEL: @test6(
; CHECK-NEXT:    ret i32 %A
;
  %B = or i32 %A, %A
  ret i32 %B
}

; A | ~A == -1
define i32 @test7(i32 %A) {
; CHECK-LABEL: @test7(
; CHECK-NEXT:    ret i32 -1
;
  %NotA = xor i32 %A, -1
  %B = or i32 %A, %NotA
  ret i32 %B
}

define i8 @test8(i8 %A) {
; CHECK-LABEL: @test8(
; CHECK-NEXT:    ret i8 -1
;
  %B = or i8 %A, -2
  %C = or i8 %B, 1
  ret i8 %C
}

; Test that (A|c1)|(B|c2) == (A|B)|(c1|c2)
define i8 @test9(i8 %A, i8 %B) {
; CHECK-LABEL: @test9(
; CHECK-NEXT:    ret i8 -1
;
  %C = or i8 %A, 1
  %D = or i8 %B, -2
  %E = or i8 %C, %D
  ret i8 %E
}

define i8 @test10(i8 %A) {
; CHECK-LABEL: @test10(
; CHECK-NEXT:    ret i8 -2
;
  %B = or i8 %A, 1
  %C = and i8 %B, -2
  ; (X & C1) | C2 --> (X | C2) & (C1|C2)
  %D = or i8 %C, -2
  ret i8 %D
}

define i8 @test11(i8 %A) {
; CHECK-LABEL: @test11(
; CHECK-NEXT:    ret i8 -1
;
  %B = or i8 %A, -2
  %C = xor i8 %B, 13
  ; (X ^ C1) | C2 --> (X | C2) ^ (C1&~C2)
  %D = or i8 %C, 1
  %E = xor i8 %D, 12
  ret i8 %E
}

; Test the case where integer BitWidth <= 64 && BitWidth % 2 != 0.
define i39 @test1_apint(i39 %V, i39 %M) {
; CHECK-LABEL: @test1_apint(
; CHECK:         [[N:%.*]] = and i39 %M, -274877906944
; CHECK-NEXT:    [[A:%.*]] = add i39 %V, [[N]]
; CHECK-NEXT:    ret i39 [[A]]
;
    ;; If we have: ((V + N) & C1) | (V & C2)
    ;; .. and C2 = ~C1 and C2 is 0+1+ and (N & C2) == 0
    ;; replace with V+N.
    %C1 = xor i39 274877906943, -1 ;; C2 = 274877906943
    %N = and i39 %M, 274877906944
    %A = add i39 %V, %N
    %B = and i39 %A, %C1
    %D = and i39 %V, 274877906943
    %R = or i39 %B, %D
    ret i39 %R
}

define i7 @test2_apint(i7 %X) {
; CHECK-LABEL: @test2_apint(
; CHECK:         ret i7 %X
;
    %Y = or i7 %X, 0
    ret i7 %Y
}

define i17 @test3_apint(i17 %X) {
; CHECK-LABEL: @test3_apint(
; CHECK:         ret i17 -1
;
    %Y = or i17 %X, -1
    ret i17 %Y
}

; Test the case where Integer BitWidth > 64 && BitWidth <= 1024.
define i399 @test4_apint(i399 %V, i399 %M) {
; CHECK-LABEL: @test4_apint(
; CHECK:         [[N:%.*]] = and i399 %M, 18446742974197923840
; CHECK-NEXT:    [[A:%.*]] = add i399 %V, [[N]]
; CHECK-NEXT:    ret i399 [[A]]
;
    ;; If we have: ((V + N) & C1) | (V & C2)
    ;; .. and C2 = ~C1 and C2 is 0+1+ and (N & C2) == 0
    ;; replace with V+N.
    %C1 = xor i399 274877906943, -1 ;; C2 = 274877906943
    %N = and i399 %M, 18446742974197923840
    %A = add i399 %V, %N
    %B = and i399 %A, %C1
    %D = and i399 %V, 274877906943
    %R = or i399 %D, %B
    ret i399 %R
}

define i777 @test5_apint(i777 %X) {
; CHECK-LABEL: @test5_apint(
; CHECK:         ret i777 %X
;
    %Y = or i777 %X, 0
    ret i777 %Y
}

define i117 @test6_apint(i117 %X) {
; CHECK-LABEL: @test6_apint(
; CHECK:         ret i117 -1
;
    %Y = or i117 %X, -1
    ret i117 %Y
}

; Test the case where integer BitWidth <= 64 && BitWidth % 2 != 0.
; Vector version of test1_apint with the add commuted
define <2 x i39> @test7_apint(<2 x i39> %V, <2 x i39> %M) {
; CHECK-LABEL: @test7_apint(
; CHECK-NEXT:    [[N:%.*]] = and <2 x i39> [[M:%.*]], <i39 -274877906944, i39 -274877906944>
; CHECK-NEXT:    [[A:%.*]] = add <2 x i39> [[N]], [[V:%.*]]
; CHECK-NEXT:    ret <2 x i39> [[A]]
;
  ;; If we have: ((V + N) & C1) | (V & C2)
  ;; .. and C2 = ~C1 and C2 is 0+1+ and (N & C2) == 0
  ;; replace with V+N.
  %C1 = xor <2 x i39> <i39 274877906943, i39 274877906943>, <i39 -1, i39 -1> ;; C2 = 274877906943
  %N = and <2 x i39> %M, <i39 274877906944, i39 274877906944>
  %A = add <2 x i39> %N, %V
  %B = and <2 x i39> %A, %C1
  %D = and <2 x i39> %V, <i39 274877906943, i39 274877906943>
  %R = or <2 x i39> %B, %D
  ret <2 x i39> %R
}

; Test the case where Integer BitWidth > 64 && BitWidth <= 1024.
; Vector version of test4_apint with the add and the or commuted
define <2 x i399> @test8_apint(<2 x i399> %V, <2 x i399> %M) {
; CHECK-LABEL: @test8_apint(
; CHECK-NEXT:    [[N:%.*]] = and <2 x i399> [[M:%.*]], <i399 18446742974197923840, i399 18446742974197923840>
; CHECK-NEXT:    [[A:%.*]] = add <2 x i399> [[N]], [[V:%.*]]
; CHECK-NEXT:    ret <2 x i399> [[A]]
;
  ;; If we have: ((V + N) & C1) | (V & C2)
  ;; .. and C2 = ~C1 and C2 is 0+1+ and (N & C2) == 0
  ;; replace with V+N.
  %C1 = xor <2 x i399> <i399 274877906943, i399 274877906943>, <i399 -1, i399 -1> ;; C2 = 274877906943
  %N = and <2 x i399> %M, <i399 18446742974197923840, i399 18446742974197923840>
  %A = add <2 x i399> %N, %V
  %B = and <2 x i399> %A, %C1
  %D = and <2 x i399> %V, <i399 274877906943, i399 274877906943>
  %R = or <2 x i399> %D, %B
  ret <2 x i399> %R
}

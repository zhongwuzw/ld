; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-linux-gnu -o - | FileCheck %s

; This test checks that only a single jae gets generated in the final code
; for lowering the CMOV pseudos that get created for this IR.  The tricky part
; of this test is that it tests the special PHI operand rewriting code in
; X86TargetLowering::EmitLoweredSelect.
;
define double @foo1(float %p1, double %p2, double %p3) nounwind {
; CHECK-LABEL: foo1:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    xorps %xmm3, %xmm3
; CHECK-NEXT:    ucomiss %xmm3, %xmm0
; CHECK-NEXT:    movsd {{.*#+}} xmm0 = mem[0],zero
; CHECK-NEXT:    jae .LBB0_1
; CHECK-NEXT:  # %bb.2: # %entry
; CHECK-NEXT:    addsd %xmm2, %xmm0
; CHECK-NEXT:    jmp .LBB0_3
; CHECK-NEXT:  .LBB0_1:
; CHECK-NEXT:    addsd %xmm0, %xmm1
; CHECK-NEXT:    movapd %xmm1, %xmm0
; CHECK-NEXT:    movapd %xmm1, %xmm2
; CHECK-NEXT:  .LBB0_3: # %entry
; CHECK-NEXT:    subsd %xmm1, %xmm0
; CHECK-NEXT:    addsd %xmm2, %xmm0
; CHECK-NEXT:    retq
entry:
  %c1 = fcmp oge float %p1, 0.000000e+00
  %d0 = fadd double %p2, 1.25e0
  %d1 = fadd double %p3, 1.25e0
  %d2 = select i1 %c1, double %d0, double %d1
  %d3 = select i1 %c1, double %d2, double %p2
  %d4 = select i1 %c1, double %d3, double %p3
  %d5 = fsub double %d2, %d3
  %d6 = fadd double %d5, %d4
  ret double %d6
}

; This test checks that only a single jae gets generated in the final code
; for lowering the CMOV pseudos that get created for this IR.  The tricky part
; of this test is that it tests the special PHI operand rewriting code in
; X86TargetLowering::EmitLoweredSelect.
;
define double @foo2(float %p1, double %p2, double %p3) nounwind {
; CHECK-LABEL: foo2:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    xorps %xmm3, %xmm3
; CHECK-NEXT:    ucomiss %xmm3, %xmm0
; CHECK-NEXT:    movsd {{.*#+}} xmm0 = mem[0],zero
; CHECK-NEXT:    jae .LBB1_1
; CHECK-NEXT:  # %bb.2: # %entry
; CHECK-NEXT:    addsd %xmm0, %xmm2
; CHECK-NEXT:    movapd %xmm2, %xmm0
; CHECK-NEXT:    movapd %xmm2, %xmm1
; CHECK-NEXT:    jmp .LBB1_3
; CHECK-NEXT:  .LBB1_1:
; CHECK-NEXT:    addsd %xmm1, %xmm0
; CHECK-NEXT:  .LBB1_3: # %entry
; CHECK-NEXT:    subsd %xmm1, %xmm0
; CHECK-NEXT:    addsd %xmm2, %xmm0
; CHECK-NEXT:    retq
entry:
  %c1 = fcmp oge float %p1, 0.000000e+00
  %d0 = fadd double %p2, 1.25e0
  %d1 = fadd double %p3, 1.25e0
  %d2 = select i1 %c1, double %d0, double %d1
  %d3 = select i1 %c1, double %p2, double %d2
  %d4 = select i1 %c1, double %p3, double %d3
  %d5 = fsub double %d2, %d3
  %d6 = fadd double %d5, %d4
  ret double %d6
}

; This test checks that only a single js gets generated in the final code
; for lowering the CMOV pseudos that get created for this IR.  The tricky part
; of this test is that it tests the special PHI operand rewriting code in
; X86TargetLowering::EmitLoweredSelect.  It also tests to make sure all
; the operands of the resulting instructions are from the proper places.
;
define double @foo3(i32 %p1, double %p2, double %p3,
; CHECK-LABEL: foo3:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    testl %edi, %edi
; CHECK-NEXT:    js .LBB2_2
; CHECK-NEXT:  # %bb.1: # %entry
; CHECK-NEXT:    movapd %xmm2, %xmm1
; CHECK-NEXT:    movapd %xmm2, %xmm0
; CHECK-NEXT:  .LBB2_2: # %entry
; CHECK-NEXT:    divsd %xmm1, %xmm0
; CHECK-NEXT:    retq
                             double %p4, double %p5) nounwind {
entry:
  %c1 = icmp slt i32 %p1, 0
  %d2 = select i1 %c1, double %p2, double %p3
  %d3 = select i1 %c1, double %p3, double %p4
  %d4 = select i1 %c1, double %d2, double %d3
  %d5 = fdiv double %d4, %d3
  ret double %d5
}

; This test checks that only a single js gets generated in the final code
; for lowering the CMOV pseudos that get created for this IR.  The tricky part
; of this test is that it tests the special PHI operand rewriting code in
; X86TargetLowering::EmitLoweredSelect.  It also tests to make sure all
; the operands of the resulting instructions are from the proper places
; when the "opposite condition" handling code in the compiler is used.
; This should be the same code as foo3 above, because we use the opposite
; condition code in the second two selects, but we also swap the operands
; of the selects to give the same actual computation.
;
define double @foo4(i32 %p1, double %p2, double %p3,
; CHECK-LABEL: foo4:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    testl %edi, %edi
; CHECK-NEXT:    js .LBB3_2
; CHECK-NEXT:  # %bb.1: # %entry
; CHECK-NEXT:    movapd %xmm2, %xmm1
; CHECK-NEXT:    movapd %xmm2, %xmm0
; CHECK-NEXT:  .LBB3_2: # %entry
; CHECK-NEXT:    divsd %xmm1, %xmm0
; CHECK-NEXT:    retq
                             double %p4, double %p5) nounwind {
entry:
  %c1 = icmp slt i32 %p1, 0
  %d2 = select i1 %c1, double %p2, double %p3
  %c2 = icmp sge i32 %p1, 0
  %d3 = select i1 %c2, double %p4, double %p3
  %d4 = select i1 %c2, double %d3, double %d2
  %d5 = fdiv double %d4, %d3
  ret double %d5
}

; This test checks that only a single jae gets generated in the final code
; for lowering the CMOV pseudos that get created for this IR.  The tricky part
; of this test is that it tests the special code in CodeGenPrepare.
;
define double @foo5(float %p1, double %p2, double %p3) nounwind {
; CHECK-LABEL: foo5:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    xorps %xmm3, %xmm3
; CHECK-NEXT:    ucomiss %xmm3, %xmm0
; CHECK-NEXT:    movsd {{.*#+}} xmm0 = mem[0],zero
; CHECK-NEXT:    jae .LBB4_1
; CHECK-NEXT:  # %bb.2: # %select.false
; CHECK-NEXT:    addsd %xmm2, %xmm0
; CHECK-NEXT:  .LBB4_3: # %select.end
; CHECK-NEXT:    subsd %xmm1, %xmm0
; CHECK-NEXT:    addsd %xmm2, %xmm0
; CHECK-NEXT:    retq
; CHECK-NEXT:  .LBB4_1:
; CHECK-NEXT:    addsd %xmm0, %xmm1
; CHECK-NEXT:    movapd %xmm1, %xmm0
; CHECK-NEXT:    movapd %xmm1, %xmm2
; CHECK-NEXT:    jmp .LBB4_3
entry:
  %c1 = fcmp oge float %p1, 0.000000e+00
  %d0 = fadd double %p2, 1.25e0
  %d1 = fadd double %p3, 1.25e0
  %d2 = select i1 %c1, double %d0, double %d1, !prof !0
  %d3 = select i1 %c1, double %d2, double %p2, !prof !0
  %d4 = select i1 %c1, double %d3, double %p3, !prof !0
  %d5 = fsub double %d2, %d3
  %d6 = fadd double %d5, %d4
  ret double %d6
}

; We should expand select instructions into 3 conditional branches as their
; condtions are different.
;
define double @foo6(float %p1, double %p2, double %p3) nounwind {
; CHECK-LABEL: foo6:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    movaps %xmm0, %xmm3
; CHECK-NEXT:    xorps %xmm0, %xmm0
; CHECK-NEXT:    ucomiss %xmm0, %xmm3
; CHECK-NEXT:    movsd {{.*#+}} xmm0 = mem[0],zero
; CHECK-NEXT:    jae .LBB5_1
; CHECK-NEXT:  # %bb.2: # %select.false
; CHECK-NEXT:    addsd %xmm2, %xmm0
; CHECK-NEXT:  .LBB5_3: # %select.end
; CHECK-NEXT:    ucomiss {{.*}}(%rip), %xmm3
; CHECK-NEXT:    movapd %xmm0, %xmm4
; CHECK-NEXT:    jae .LBB5_5
; CHECK-NEXT:  # %bb.4: # %select.false2
; CHECK-NEXT:    movapd %xmm1, %xmm4
; CHECK-NEXT:  .LBB5_5: # %select.end1
; CHECK-NEXT:    ucomiss {{.*}}(%rip), %xmm3
; CHECK-NEXT:    movapd %xmm4, %xmm1
; CHECK-NEXT:    jae .LBB5_7
; CHECK-NEXT:  # %bb.6: # %select.false4
; CHECK-NEXT:    movapd %xmm2, %xmm1
; CHECK-NEXT:  .LBB5_7: # %select.end3
; CHECK-NEXT:    subsd %xmm4, %xmm0
; CHECK-NEXT:    addsd %xmm1, %xmm0
; CHECK-NEXT:    retq
; CHECK-NEXT:  .LBB5_1:
; CHECK-NEXT:    addsd %xmm1, %xmm0
; CHECK-NEXT:    jmp .LBB5_3
entry:
  %c1 = fcmp oge float %p1, 0.000000e+00
  %c2 = fcmp oge float %p1, 1.000000e+00
  %c3 = fcmp oge float %p1, 2.000000e+00
  %d0 = fadd double %p2, 1.25e0
  %d1 = fadd double %p3, 1.25e0
  %d2 = select i1 %c1, double %d0, double %d1, !prof !0
  %d3 = select i1 %c2, double %d2, double %p2, !prof !0
  %d4 = select i1 %c3, double %d3, double %p3, !prof !0
  %d5 = fsub double %d2, %d3
  %d6 = fadd double %d5, %d4
  ret double %d6
}

!0 = !{!"branch_weights", i32 1, i32 2000}

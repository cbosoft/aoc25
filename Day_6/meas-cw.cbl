       IDENTIFICATION DIVISION.
       PROGRAM-ID. "MEAS-CW".
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-I PIC 9(4) VALUE 1.
       01 WS-J PIC 9(4) VALUE 1.
       01 WS-K PIC 9(4) VALUE 1.
       01 WS-OP PIC X(1) VALUE " ".
       LINKAGE SECTION.
       01 LS-T-I.
           03 LS-I-R0 PIC X(4000) VALUE "\0".
           03 LS-I-R1 PIC X(4000) VALUE "\0".
           03 LS-I-R2 PIC X(4000) VALUE "\0".
           03 LS-I-R3 PIC X(4000) VALUE "\0".
           03 LS-I-R4 PIC X(4000) VALUE "\0".
       01 LS-T-O.
           03 LS-O PIC X(1) OCCURS 1000 TIMES.
       01 LS-T-CW.
           03 LS-CW PIC 9(1) OCCURS 1000 TIMES.
       PROCEDURE DIVISION USING LS-T-I, LS-T-O, LS-T-CW.
       SUB-MAIN.
      *    Initialise cell widths to zero
           PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I = 1000
             COMPUTE LS-CW(WS-I) = 0
           END-PERFORM.
           MOVE LS-I-R4(1:1) TO LS-O(1).
           COMPUTE WS-J = 2.
      *    DISPLAY LS-I-R4(1:100).
           PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I = 4000
             MOVE LS-I-R4(WS-I:1) TO WS-OP
             IF WS-OP EQUAL "*" OR WS-OP EQUAL "+"
               COMPUTE LS-CW(WS-K) = WS-I - WS-J
               COMPUTE WS-J = WS-I + 1
               ADD 1 TO WS-K
               MOVE WS-OP TO LS-O(WS-K)
             END-IF
           END-PERFORM.
           COMPUTE LS-CW(WS-K) = 4.
      *    DISPLAY LS-T-O(1:10).
           EXIT PROGRAM.

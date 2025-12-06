       IDENTIFICATION DIVISION.
       PROGRAM-ID. "PARSE-INPUT-ROW".
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-CELL PIC 9(5).
       01 WS-CELL-STR PIC X(1).
       01 WS-HAS-NONEMPTY PIC 9(1).
       01 WS-LB PIC 9(4) VALUE 1.
       01 WS-UB PIC 9(4) VALUE 0.
       01 WS-ICOL PIC 9(4) VALUE 1.
       01 WS-I PIC 9(4) VALUE 1.
       LINKAGE SECTION.
       01 LS-INP PIC X(4000) VALUE "\0".
       01 LS-COLS PIC 9(4) VALUE 1.
       01 LS-TBL.
           03 LS-R PIC 9(04) OCCURS 1000 TIMES.
       PROCEDURE DIVISION USING LS-INP, LS-COLS, LS-TBL.
       SUB-MAIN.
           COMPUTE WS-ICOL = 1.
           COMPUTE WS-UB = 0.
           COMPUTE WS-LB = 1.
           COMPUTE WS-HAS-NONEMPTY = 0.
           PERFORM UNTIL WS-UB GREATER THAN OR EQUAL TO 4000
             COMPUTE WS-UB = WS-UB + 1
             MOVE LS-INP(WS-UB:1) TO WS-CELL-STR
             IF WS-CELL-STR EQUAL " "
        MOVE LS-INP(WS-LB:WS-UB - WS-LB) TO WS-CELL
               IF WS-HAS-NONEMPTY GREATER THAN 0
                 MOVE WS-CELL TO LS-R(WS-ICOL)
                 ADD 1 TO WS-ICOL
                 COMPUTE WS-HAS-NONEMPTY = 0
               END-IF
               MOVE WS-UB TO WS-LB
             ELSE
               COMPUTE WS-HAS-NONEMPTY = 1
             END-IF
             MOVE WS-ICOL TO LS-COLS
           END-PERFORM.
           EXIT PROGRAM.

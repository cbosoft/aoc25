       IDENTIFICATION DIVISION.
       PROGRAM-ID. "TEST".
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-PART-NO PIC X(5).

       01 WS-T-I.
           03 WS-INPUT-R0 PIC X(4000) VALUE "\0".
           03 WS-INPUT-R1 PIC X(4000) VALUE "\0".
           03 WS-INPUT-R2 PIC X(4000) VALUE "\0".
           03 WS-INPUT-R3 PIC X(4000) VALUE "\0".
           03 WS-INPUT-R4 PIC X(4000) VALUE "\0".

       01 WS-CELL PIC 9(5) VALUE 0.
       01 WS-OP PIC X(1) VALUE " ".
       01 WS-LB PIC 9(4) VALUE 1.
       01 WS-UB PIC 9(4) VALUE 0.
       01 WS-FLAG PIC 9(1) VALUE 0.
       01 WS-ICOL PIC 9(4) VALUE 1.

       01 WS-I PIC 9(4) VALUE 1.
       01 WS-J PIC 9(5).
       01 WS-K PIC 9(5).
       01 WS-L PIC 9(5).
       01 WS-M PIC 9(5).
       01 WS-N PIC 9(5).

      * Building up a single number, a digit at a time.
       01 WS-DIGITS.
           03 WS-DIGIT-0 PIC 9(1).
           03 WS-DIGIT-1 PIC 9(1).
           03 WS-DIGIT-2 PIC 9(1).
           03 WS-DIGIT-3 PIC 9(1).

       01 WS-SCRATCH PIC S9(20) COMP-3 VALUE 0.
       01 WS-SCRATCH2 PIC S9(20) COMP-3 VALUE 0.
       01 WS-TOTAL PIC S9(31) COMP-3 VALUE 0.
       01 WS-TOTAL-STR PIC X(31).

       01 WS-T-CW.
           03 WS-CW PIC 9(1) OCCURS 1000 TIMES.

       01 WS-T-D.
           03 WS-D0 PIC 9(4) OCCURS 1000 TIMES.
           03 WS-D1 PIC 9(4) OCCURS 1000 TIMES.
           03 WS-D2 PIC 9(4) OCCURS 1000 TIMES.
           03 WS-D3 PIC 9(4) OCCURS 1000 TIMES.

       01 WS-T-O.
           03 WS-O PIC X(1) OCCURS 1000 TIMES.

       PROCEDURE DIVISION.
           ACCEPT WS-INPUT-R0 FROM STDIN.
           ACCEPT WS-INPUT-R1 FROM STDIN.
           ACCEPT WS-INPUT-R2 FROM STDIN.
           ACCEPT WS-INPUT-R3 FROM STDIN.
           ACCEPT WS-INPUT-R4 FROM STDIN.

           CALL "MEAS-CW" USING WS-T-I, WS-T-O, WS-T-CW.

           COMPUTE WS-M = 0.
           PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 1000
             PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J >= WS-CW(WS-I)
               COMPUTE WS-N = 0
               MOVE 0 TO WS-DIGITS
      *        Going up...
               PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K = 5
                 COMPUTE WS-L = 4000*(4 - WS-K) + WS-M + WS-J + 1
                 DISPLAY "L:" WS-L " >" WS-T-I(WS-L:1) "<"
      *          * -> char = LS-T-I(WS-L).. is it blank?
                 IF WS-T-I(WS-L:1) NOT EQUAL " "
                   EVALUATE WS-N
                     WHEN 0
                       MOVE WS-T-I(WS-L:1) TO WS-DIGIT-3
                     WHEN 1
                       MOVE WS-T-I(WS-L:1) TO WS-DIGIT-2
                     WHEN 2
                       MOVE WS-T-I(WS-L:1) TO WS-DIGIT-1
                     WHEN 3
                       MOVE WS-T-I(WS-L:1) TO WS-DIGIT-0
                   END-EVALUATE
                   ADD 1 TO WS-N
                 END-IF
               END-PERFORM
      *        At the bottom, one number done!

      *        IF WS-N GREATER THAN 0
               EVALUATE WS-J
                 WHEN 0
                   MOVE WS-DIGITS TO WS-D0(WS-I)
                 WHEN 1
                   MOVE WS-DIGITS TO WS-D1(WS-I)
                 WHEN 2
                   MOVE WS-DIGITS TO WS-D2(WS-I)
                 WHEN 3
                   MOVE WS-DIGITS TO WS-D3(WS-I)
               END-EVALUATE
               DISPLAY WS-DIGITS
      *        END-IF

             END-PERFORM
             COMPUTE WS-M = WS-M + WS-CW(WS-I) + 1
           END-PERFORM.

           COMPUTE WS-TOTAL = 0.
           PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 1000
             COMPUTE WS-SCRATCH = 0
             EVALUATE WS-O(WS-I)
               WHEN "*"
                 COMPUTE WS-SCRATCH = 1
               WHEN "+"
                 COMPUTE WS-SCRATCH = 0
             END-EVALUATE
             PERFORM VARYING WS-J
               FROM 0 BY 1 UNTIL WS-J = WS-CW(WS-I)
             MOVE WS-T-D(1000*(WS-J - 1) + WS-I:4) TO WS-SCRATCH2
               EVALUATE WS-J
                 WHEN 0
                   MOVE WS-D0(WS-I) TO WS-SCRATCH2
                 WHEN 1
                   MOVE WS-D1(WS-I) TO WS-SCRATCH2
                 WHEN 2
                   MOVE WS-D2(WS-I) TO WS-SCRATCH2
                 WHEN 3
                   MOVE WS-D3(WS-I) TO WS-SCRATCH2
               END-EVALUATE

               EVALUATE WS-O(WS-I)
                 WHEN "*"
                   MULTIPLY WS-SCRATCH2 BY WS-SCRATCH
                 WHEN "+"
                   ADD WS-SCRATCH2 TO WS-SCRATCH
               END-EVALUATE
              DISPLAY "S2: " WS-SCRATCH2 " " WS-J " " WS-CW(WS-I)
             END-PERFORM
             ADD WS-SCRATCH TO WS-TOTAL
             DISPLAY "S1:" WS-SCRATCH
           END-PERFORM.
           DISPLAY WS-TOTAL.
           STOP RUN.

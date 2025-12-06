       IDENTIFICATION DIVISION.
       PROGRAM-ID. "TEST".
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-PART-NO PIC X(5).
       01 WS-ROW PIC X(4000) VALUE "\0".
       01 WS-CELL PIC 9(5) VALUE 0.
       01 WS-OP PIC X(1) VALUE " ".
       01 WS-LB PIC 9(4) VALUE 1.
       01 WS-UB PIC 9(4) VALUE 0.
       01 WS-FLAG PIC 9(1) VALUE 0.
       01 WS-ICOL PIC 9(4) VALUE 1.
       01 WS-I PIC 9(4) VALUE 1.
       01 WS-SCRATCH PIC S9(20) COMP-3 VALUE 0.
       01 WS-TOTAL PIC S9(31) COMP-3 VALUE 0.
       01 WS-TOTAL-STR PIC X(31).
       01 WS-T-A.
           03 WS-A-VALUE PIC 9(04) OCCURS 1000 TIMES.
       01 WS-T-B.
           03 WS-B-VALUE PIC 9(04) OCCURS 1000 TIMES.
       01 WS-T-C.
           03 WS-C-VALUE PIC 9(04) OCCURS 1000 TIMES.
       01 WS-T-D.
           03 WS-D-VALUE PIC 9(04) OCCURS 1000 TIMES.
       01 WS-T-O.
           03 WS-O-VALUE PIC X(1) OCCURS 1000 TIMES.
       PROCEDURE DIVISION.
           ACCEPT WS-ROW FROM STDIN.
           CALL "PARSE-INPUT-ROW" USING WS-ROW, WS-ICOL, WS-T-A.
           ACCEPT WS-ROW FROM STDIN.
           CALL "PARSE-INPUT-ROW" USING WS-ROW, WS-ICOL, WS-T-B.
           ACCEPT WS-ROW FROM STDIN.
           CALL "PARSE-INPUT-ROW" USING WS-ROW, WS-ICOL, WS-T-C.
           ACCEPT WS-ROW FROM STDIN.
           CALL "PARSE-INPUT-ROW" USING WS-ROW, WS-ICOL, WS-T-D.

           ACCEPT WS-ROW FROM STDIN.
           COMPUTE WS-ICOL = 1.
           PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I = 4000
             MOVE WS-ROW(WS-I:1) TO WS-OP
             DISPLAY WS-I ":" WS-OP
             IF WS-OP EQUAL "*" OR WS-OP EQUAL "+"
               MOVE WS-OP TO WS-O-VALUE(WS-ICOL)
               ADD 1 TO WS-ICOL
             END-IF
           END-PERFORM.

           COMPUTE WS-TOTAL = 0.
           PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I = WS-ICOL
             DISPLAY "A:" WS-A-VALUE(WS-I)
             DISPLAY "B:" WS-B-VALUE(WS-I)
             DISPLAY "C:" WS-C-VALUE(WS-I)
             DISPLAY "D:" WS-D-VALUE(WS-I)
             DISPLAY "O:" WS-O-VALUE(WS-I)


             EVALUATE WS-O-VALUE(WS-I)
               WHEN "*"
                 COMPUTE WS-SCRATCH = 1
                 MULTIPLY WS-A-VALUE(WS-I) BY WS-SCRATCH
                 MULTIPLY WS-B-VALUE(WS-I) BY WS-SCRATCH
                 MULTIPLY WS-C-VALUE(WS-I) BY WS-SCRATCH
                 MULTIPLY WS-D-VALUE(WS-I) BY WS-SCRATCH
               WHEN "+"
                 COMPUTE WS-SCRATCH = 0
                 ADD WS-A-VALUE(WS-I) TO WS-SCRATCH
                 ADD WS-B-VALUE(WS-I) TO WS-SCRATCH
                 ADD WS-C-VALUE(WS-I) TO WS-SCRATCH
                 ADD WS-D-VALUE(WS-I) TO WS-SCRATCH
             END-EVALUATE
             DISPLAY "Scratch: " WS-SCRATCH
             ADD WS-SCRATCH TO WS-TOTAL

           END-PERFORM.
           MOVE WS-TOTAL TO WS-TOTAL-STR.
           DISPLAY "Total: " WS-TOTAL-STR.
           STOP RUN.

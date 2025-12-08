#!/usr/bin/env sqscript

CREATE TABLE FilteredInput(ID INTEGER PRIMARY KEY, Line TEXT);
INSERT INTO FilteredInput(Line) SELECT Line FROM StandardInput WHERE Line LIKE '%^%' OR Line LIKE '%S%';

CREATE TABLE SplitterPosition (
  ID INTEGER PRIMARY KEY,
  LineID INTEGER NOT NULL REFERENCES FilteredInput(ID),
  Position INTEGER NOT NULL
);
CREATE INDEX index_splitterpos ON SplitterPosition(LineID, Position);

INSERT INTO SplitterPosition(LineID, Position)
  WITH RECURSIVE C(LineID, Position, Line) AS (
    SELECT ID, INSTR(Line, '^'), Line FROM FilteredInput WHERE Line LIKE '%^%'
    UNION ALL
    SELECT
      LineID,
      INSTR(SUBSTR(Line, Position+1, LENGTH(Line) - Position), '^') + Position,
      Line
    FROM C
    WHERE INSTR(SUBSTR(Line, Position+1), '^') > 0
  ) SELECT LineID, Position FROM C;

CREATE TABLE BeamPosition (
  ID INTEGER PRIMARY KEY,
  LineID INTEGER NOT NULL REFERENCES FilteredInput(ID),
  Position INTEGER NOT NULL
);

CREATE TABLE MaxID(V INTEGER);
INSERT INTO MaxID(V) SELECT MAX(ID) FROM FilteredInput;

CREATE INDEX index_beampos ON BeamPosition(LineID, Position);

#define COMMA ,
#define GETPOS(S, E) \
INSERT INTO BeamPosition(LineID, Position) \
  WITH RECURSIVE C(LineID, Position) AS ( \
    S \
 \
    UNION ALL \
 \
    SELECT \
      C.LineID + 1, \
      CASE \
        WHEN NextLineSplitter.Position IS NULL THEN \
          C.Position \
        ELSE \
          C.Position+X.Offset \
      END \
    FROM C \
    JOIN (SELECT 1 AS Offset UNION ALL SELECT -1) AS X \
 \
    LEFT OUTER JOIN SplitterPosition AS NextLineSplitter \
      ON NextLineSplitter.LineID=C.LineID+1 \
      AND NextLineSplitter.Position=C.Position \
 \
    WHERE E \
    AND ((NextLineSplitter.Position IS NULL AND X.Offset=1) OR (NextLineSplitter.Position IS NOT NULL)) \
  ) SELECT DISTINCT LineID, Position FROM C WHERE C.Position IS NOT NULL ORDER BY LineID ASC;

GETPOS(SELECT ID AS LineID COMMA INSTR(Line, 'S') AS Position FROM FilteredInput WHERE ID=1, C.LineID < (SELECT V/2 FROM MaxID))
--GETPOS(SELECT LineID COMMA Position FROM BeamPosition WHERE ID=(SELECT V/2 FROM MaxID), C.LineID <= (SELECT V FROM MaxID))

CREATE TABLE TimelineCount (V INTEGER);
INSERT INTO TimelineCount(V) 
  SELECT COUNT(*) FROM SplitterPosition AS SP
    INNER JOIN (SELECT LineID, Position FROM BeamPosition) AS BP
      ON BP.Position=SP.Position
      AND BP.LineID=SP.LineID-1;

-- INSERT INTO StandardOutput(Line)
--   SELECT CONCAT(SI.ID, ' :: ', SP.Position, ' :: ', BP.Position)
--   FROM FilteredInput AS SI
--   LEFT JOIN SplitterPosition AS SP ON SP.LineID=SI.ID
--   LEFT JOIN BeamPosition AS BP ON BP.LineID=SI.ID
--   ORDER BY SI.ID ASC;
INSERT INTO StandardOutput(Line)
  SELECT CONCAT(BP.ID, ' :: ', BP.LineID, '::', BP.Position)
  FROM BeamPosition AS BP
  ORDER BY BP.ID ASC;

INSERT INTO StandardOutput(Line) SELECT CONCAT('# Timelines: ', V) FROM TimelineCount;

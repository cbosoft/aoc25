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
  WITH RECURSIVE C(LineID, Position, LastID, LastPos) AS ( \
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
      END, \
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
    AND C.LastID != C.LineID + 1 \
    AND ((NextLineSplitter.Position IS NULL AND C.Position != LastPos) OR (C.Position + X.Offset != LastPos)) \
  ) SELECT DISTINCT LineID, Position FROM C WHERE C.Position IS NOT NULL ORDER BY LineID ASC;

GETPOS(SELECT ID COMMA INSTR(Line, 'S') COMMA ID COMMA INSTR(Line, 'S') FROM FilteredInput WHERE ID=1, C.LineID <= (SELECT V/4 FROM MaxID))
GETPOS(SELECT LineID COMMA Position COMMA LineID COMMA Position FROM BeamPosition WHERE ID=(SELECT (1*V)/4 FROM MaxID), C.LineID <= (SELECT (2*V)/4 FROM MaxID))
GETPOS(SELECT LineID COMMA Position COMMA LineID COMMA Position FROM BeamPosition WHERE ID=(SELECT (2*V)/4 FROM MaxID), C.LineID <= (SELECT (3*V)/4 FROM MaxID))
GETPOS(SELECT LineID COMMA Position COMMA LineID COMMA Position FROM BeamPosition WHERE ID=(SELECT (3*V)/4 FROM MaxID), C.LineID < (SELECT V FROM MaxID))

CREATE TABLE DistinctBeamPosition (ID INTEGER PRIMARY KEY, LineID INTEGER REFERENCES FilteredInput(ID), Position INTEGER);
INSERT INTO DistinctBeamPosition(LineID, Position) SELECT DISTINCT LineID, Position FROM BeamPosition;

CREATE TABLE TimelineCount (ID INTEGER PRIMARY KEY, BeamID INTEGER REFERENCES BeamPosition(ID) NOT NULL, N INTEGER NOT NULL);
INSERT INTO TimelineCount(BeamID, N)
  WITH RECURSIVE C(BeamID, N) AS (
    SELECT 1, 1
    UNION ALL
    SELECT
      Beam.ID,
      C.N + (CASE
        WHEN (RSplitter.Position IS NOT NULL) AND (RAbove.Position IS NOT NULL) AND (LSplitter.)
      ELSE
        0
      END)
    FROM C
    INNER JOIN BeamPosition AS Beam ON Beam.ID = C.BeamID + 1
    LEFT OUTER JOIN BeamPosition AS Above ON Above.LineID = Beam.LineID + 1 AND Above.Position = Beam.Position
    LEFT OUTER JOIN BeamPosition AS RAbove ON RAbove.LineID = Beam.LineID + 1 AND RAbove.Position = Beam.Position + 1
    LEFT OUTER JOIN BeamPosition AS LAbove ON LAbove.LineID = Beam.LineID + 1 AND LAbove.Position = Beam.Position - 1
    LEFT OUTER JOIN SplitterPosition AS RSplitter ON RSplitter.LineID = Beam.LineID AND RSplitter.Position = Beam.Position + 1
    LEFT OUTER JOIN SplitterPosition AS LSplitter ON LSplitter.LineID = Beam.LineID AND LSplitter.Position = Beam.Position + 1
    WHERE C.BeamID < (SELECT Max(ID) FROM BeamPosition)
  )


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

INSERT INTO StandardOutput(Line) SELECT CONCAT('# Timelines: ', SUM(V)) FROM TimelineCount INNER JOIN BeamPosition;

-- Each value in this array corresponds to the total number of pegs up to and including that row.
totalPegsTable = [0,1,3,6,10,15,21,28,36,45,55,66,78,91,105,120,136,153]

--------------------------------------------------------
-- Used to get the row that corresponds to a peg number.
-- pegNumber - the index of the peg.
--------------------------------------------------------
getRow pegNumber = getRowHelper pegNumber 0

--------------------------------------------------------
-- Helper Function for getRow.
-- pegNumber - the index of the peg.
-- index - the current row we are looking at.
--------------------------------------------------------
getRowHelper pegNumber index =  if (totalPegsTable !! index) <= pegNumber
                                then getRowHelper pegNumber (index + 1)
                                else (index - 1)

------------------------------------------------------------
-- Used to get the displacement from the beginning of a row.
-- pegNumber - the index of the peg.
------------------------------------------------------------
getDisplacement pegNumber = pegNumber - (totalPegsTable !! (getRow pegNumber))

------------------------------------------------------------------------
-- Get the peg number corresponding to a given row and displacement.
-- row - the row of the peg.
-- displacement - the displacement of the peg from the front of the row.
------------------------------------------------------------------------
getPegNumber row displacement = if (row < 0 || row >= 13 || displacement < 0 || displacement > row)
                                then -1
                                else (totalPegsTable !! row) + displacement
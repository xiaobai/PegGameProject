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

-------------------------------------------------------------------------------------------------
-- Tests whether a move is valid or not. There are multiple conditions that need to be satisfied:
--
-- 0) 0 <= Land Row <= Max Number Of Rows - 1
-- 1) 0 <= Land Displacement <= Land Row
-- 2) Land Position must be vacant
-- 3) Jump Position must be occupied
-- 4) Peg Position must be occupied
-- oIndex - the original index the peg is jumping from.
-- nIndex - the new index the peg is jumping to.
-- rIndex - the index of the peg to be removed.
-- board - the list   the bool values of each peg.
-- rows - the number of rows on the board.
-------------------------------------------------------------------------------------------------
testMove oIndex nIndex rIndex board rows
    =   do
            let lR = getRow nIndex
            if (lR < 0 || lR >= rows)
                then False
                else do
                    let lD = getDisplacement nIndex
                    if (0 <= lR && lR <= (rows - 1) && 0 <= lD && lD <= lR)
                        then ((board !! oIndex) && (not (board !! nIndex)) && (board !! rIndex))
                        else False

--------------------------------------------------------------------------
-- Tests a specific move and calls the recursive solve method if it works.
-- oIndex - the original index the peg is jumping from.
-- nIndex - the new index the peg is jumping to.
-- rIndex - the index of the peg to be removed.
-- board - the list   the bool values of each peg.
-- rows - the number of rows on the board.
-- pegsLeft - the number of pegs left in the board.
-- totalPegs - the number of pegs in the board total.
--------------------------------------------------------------------------
testAndApply oIndex nIndex rIndex board rows pegsLeft totalPegs
    =   if (testMove oIndex nIndex rIndex board rows)
            then do
                    let newBoard = [if ((board !! i) && i /= oIndex && i /= rIndex) then True else False | i <- [0..totalPegs]]
                    recursiveSolve newBoard rows (pegsLeft - 1) totalPegs
            else -1

-------------------------------------------------------------------------------------------------
-- This tests all 6 possible moves to see if any are possible. If they are possible, then it will
-- call the recursive solve method.
-- currentPeg - the peg we are currently testing.
-- board - the list   the bool values of each peg.
-- rows - the number of rows on the board.
-- pegsLeft - the number of pegs left in the board.
-- totalPegs - the number of pegs in the board total.
-------------------------------------------------------------------------------------------------
testNeighborMoves currentPeg board rows pegsLeft totalPegs
    =   do
            let validMove = False
            let r = getRow currentPeg
            let d = getDisplacement currentPeg

            maximum [(testAndApply currentPeg (getPegNumber (r - 2) (d)) (getPegNumber (r - 1) (d)) board rows pegsLeft totalPegs),
                (testAndApply currentPeg (getPegNumber (r) (d + 2)) (getPegNumber (r) (d + 1)) board rows pegsLeft totalPegs),
                (testAndApply currentPeg (getPegNumber (r + 2) (d + 2)) (getPegNumber (r + 1) (d + 1)) board rows pegsLeft totalPegs),
                (testAndApply currentPeg (getPegNumber (r + 2) (d)) (getPegNumber (r + 1) (d)) board rows pegsLeft totalPegs),
                (testAndApply currentPeg (getPegNumber (r) (d - 2)) (getPegNumber (r) (d - 1)) board rows pegsLeft totalPegs),
                (testAndApply currentPeg (getPegNumber (r - 2) (d - 2)) (getPegNumber (r - 1) (d - 1)) board rows pegsLeft totalPegs)]

-----------------------------------------------------------------------
-- Recursive method to solve the board.
-- board - the current state of the board.
-- rows - the number of rows in the board.
-- pegsLeft - the number of pegs left in the board.
-- totalPegs - the total number of pegs in the board at any given time.
-----------------------------------------------------------------------
recursiveSolve board rows pegsLeft totalPegs
    =   do
            let maxVal = maximum [if (board !! i) then (testNeighborMoves i board rows pegsLeft totalPegs) else -1| i <- [0..(totalPegs - 1)]]
            if (maxVal == -1)
                then pegsLeft
                else maxVal

solve n
    =   do
            let totalPegs = totalPegsTable !! n
            let pegsLeft = totalPegs - 1
            maximum [recursiveSolve [if x == i then False else True | x <- [0..totalPegs - 1]] n pegsLeft totalPegs | i <- [0..totalPegs - 1]]
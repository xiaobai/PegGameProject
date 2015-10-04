import Debug.Trace
import System.Environment
import System.Exit

-- Each value in this array corresponds to the total number of pegs up to and including that row.
totalPegsTable = [0,1,3,6,10,15,21,28,36,45,55,66,78,91,105,120,136,153]
slice :: Int -> Int -> [a] -> [a]
slice from to xs = take (to - from + 1) (drop from xs)

-----------------------------------------------
-- Returns the shortest list in a list of lists.
-- l - the list of lists.
-- b - the shortest list currently
-----------------------------------------------
getShortestList:: [[(Int, Int)]] -> [(Int, Int)] ->[(Int, Int)]
getShortestList l b =
    if (l == [])
        then b
        else do
            if (((length b) < (length (head l))) && b /= [])
                then getShortestList (tail l) b
                else getShortestList (tail l) (head l)

--------------------------------------------------------
-- Used to get the row that corresponds to a peg number.
-- pegNumber - the index of the peg.
-- index - current index that we are looking at.
--------------------------------------------------------
getRow:: Int -> Int -> Int
getRow pegNumber index =
    if ((totalPegsTable !! index) <= pegNumber)
        then getRow pegNumber (index + 1)
        else index

------------------------------------------------------------
-- Used to get the displacement from the beginning of a row.
-- pegNumber - the index of the peg.
------------------------------------------------------------
getDisplacement:: Int -> Int
getDisplacement pegNumber = pegNumber - (totalPegsTable !! ((getRow pegNumber 0) - 1))

------------------------------------------------------------------------
-- Get the peg number corresponding to a given row and displacement.
-- row - the row of the peg.
-- displacement - the displacement of the peg from the front of the row.
------------------------------------------------------------------------
getPegNumber:: Int -> Int -> Int
getPegNumber row displacement =
    if (row < 1 || row > length totalPegsTable || displacement < 0 || displacement >= row)
        then -1
        else (totalPegsTable !! (row - 1)) + displacement

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
testMove:: Int -> Int -> Int -> [Bool] -> Int -> Bool
testMove oIndex nIndex rIndex board rows = 
    do
        let lR = getRow nIndex 0
        if (lR < 1 || lR > rows)
            then False
            else do
                let lD = getDisplacement nIndex
                if (1 <= lR && lR <= rows && 0 <= lD && lD < lR)
                    then ((board !! oIndex) && (not (board !! nIndex)) && (board !! rIndex))
                    else False

----------------------------------------------------------------------------
-- Applies a move to a board, returning the new list representing the board.
-- oIndex - the original index the peg is jumping from.
-- nIndex - the new index the peg is jumping to.
-- rIndex - the index of the peg to be removed.
-- board - the list   the bool values of each peg.
----------------------------------------------------------------------------
applyMove:: Int -> Int -> Int -> [Bool] -> [Bool]
applyMove oIndex nIndex rIndex board =
    [if (((board !! i) && i /= oIndex && i /= rIndex) || (i == nIndex)) then True else False | i <- [0..((length board) - 1)]]

--------------------------------------------------------------------------
-- Tests a specific move and calls the recursive solve method if it works.
-- oIndex - the original index the peg is jumping from.
-- nIndex - the new index the peg is jumping to.
-- rIndex - the index of the peg to be removed.
-- board - the list   the bool values of each peg.
-- rows - the number of rows on the board.
-- totalPegs - the number of pegs in the board total.
-- moveList - a list of tuples which are the moves.
-- Returns a tuple where the first indicates if there was a valid move, and the second is the best
-- resulting move list from the recursive call.
--------------------------------------------------------------------------
testAndApply:: Int -> Int -> Int -> [Bool] -> Int -> Int -> [(Int, Int)] -> (Bool, [(Int, Int)])
testAndApply oIndex nIndex rIndex board rows totalPegs moveList =
    if (testMove oIndex nIndex rIndex board rows)
        then do
            let newBoard = applyMove oIndex nIndex rIndex board
            let newMoveList = moveList ++ [(oIndex, nIndex)]
            (True, (recursiveSolve newBoard rows totalPegs newMoveList))
        else
            (False, [])

-------------------------------------------------------------------------------
-- This will add the snd of a tpl to the list iff the fst of the tuple is true.
-- l - the list we are working on.
-- r - the working list that we are building.
-- Returns a list of move lists that are considered valid.
-------------------------------------------------------------------------------
getCombinedValidList:: [(Bool, [(Int, Int)])] -> [[(Int, Int)]] -> [[(Int, Int)]]
getCombinedValidList l r =
    if (l == [])
        then r
        else
            if (fst (head l))
                then getCombinedValidList (tail l) (r ++ [(snd (head l))])
                else getCombinedValidList (tail l) r

-------------------------------------------------------------------------------------------------
-- This tests all 6 possible moves to see if any are possible. If they are possible, then it will
-- call the recursive solve method.
-- currentPeg - the peg we are currently testing.
-- board - the list   the bool values of each peg.
-- rows - the number of rows on the board.
-- totalPegs - the number of pegs in the board total.
-- moveList - a list of tuples which are the moves.
-- Returns a tuple where the first is if there was a valid move or not, and the second is the best
-- move list of those that are valid.
-------------------------------------------------------------------------------------------------
testNeighborMoves:: Int -> [Bool] -> Int -> Int -> [(Int, Int)] -> (Bool, [(Int, Int)])
testNeighborMoves currentPeg board rows totalPegs moveList =
    do
        let r = getRow currentPeg 0
        let d = getDisplacement currentPeg

        let t0 = testAndApply currentPeg (getPegNumber (r - 2) (d)) (getPegNumber (r - 1) (d)) board rows totalPegs moveList
        let t1 = testAndApply currentPeg (getPegNumber (r) (d + 2)) (getPegNumber (r) (d + 1)) board rows totalPegs moveList
        let t2 = testAndApply currentPeg (getPegNumber (r + 2) (d + 2)) (getPegNumber (r + 1) (d + 1)) board rows totalPegs moveList
        let t3 = testAndApply currentPeg (getPegNumber (r + 2) (d)) (getPegNumber (r + 1) (d)) board rows totalPegs moveList
        let t4 = testAndApply currentPeg (getPegNumber (r) (d - 2)) (getPegNumber (r) (d - 1)) board rows totalPegs moveList
        let t5 = testAndApply currentPeg (getPegNumber (r - 2) (d - 2)) (getPegNumber (r - 1) (d - 1)) board rows totalPegs moveList

        let bestMoveList = getShortestList ((getCombinedValidList [t0, t1, t2, t3, t4, t5] [])) []
        let validMove = (fst t0) || (fst t1) || (fst t2) || (fst t3) || (fst t4) || (fst t5)
        (validMove, bestMoveList)

-----------------------------------------------------------------------
-- Recursive method to solve the board.
-- board - the current state of the board.
-- rows - the number of rows in the board.
-- totalPegs - the total number of pegs in the board at any given time.
-- moveList - a list of tuples which are the moves.
-- Returns a tuple where the first if this move list is valid, and the second is the best move list
-- possible.
-----------------------------------------------------------------------
recursiveSolve:: [Bool] -> Int -> Int -> [(Int, Int)] -> [(Int, Int)]
recursiveSolve board rows totalPegs moveList =
    do
        let validMove = False
        let boardMoveList = [testNeighborMoves i board rows totalPegs moveList | i <- [0..totalPegs - 1], (board !! i)]
        let bestMoveList = getShortestList (getCombinedValidList boardMoveList []) []
        if (bestMoveList /= [])
            then bestMoveList
            else moveList

----------------------------------------------------------------------------------------------------
-- Solves a peg game board for the most pegs left with no available move left for a given number of
-- rows.
-- n - the number of rows in the game.
----------------------------------------------------------------------------------------------------
{-solve:: Int -> [(Int, Int)]-}
solve n =
    do
        let numOfPegs = totalPegsTable !! n
        let posToCheck = (quot numOfPegs 2) + 1
        let fullBoard = [ True | _ <- [1..numOfPegs] ]
        let listOfBoards = [[False] ++ [ True | _ <- [2..numOfPegs]]] ++ [ slice 0 (i-1) fullBoard ++ [False] ++ slice (i+1) numOfPegs fullBoard | i <- [1..posToCheck]]
        let arr = [ recursiveSolve (listOfBoards !! i) n numOfPegs [(i,i)] | i <- [0..posToCheck] ]
        getShortestList arr []


showMoves :: (Int, Int) -> String
showMoves (a, b) = "(" ++ show a ++ ", " ++ show b ++ ")"

main = do
    n <- getArgs
    let rows = read (n !! 1) :: Int
    let moves = solve rows
    putStrLn ("(" ++ show ((totalPegsTable !! rows) - (length moves)) ++ ", " ++ show (fst (moves !! 0)) ++ ")")
    putStrLn (unlines (map showMoves moves))

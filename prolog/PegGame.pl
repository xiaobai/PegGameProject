/*
 * To run this prolog program do:
 * swipl -s PegGame.pl
 */

/**
 * The operations below on basic boolean logic are taken from:
 * http://kti.ms.mff.cuni.cz/~bartak/prolog/booleans.html
 */

/** Logical And **/
and_d(true, false, false).
and_d(true, true, true).
and_d(false, true, false).
and_d(false, false, false).

/** Logical Or **/
or_d(true, false, true).
or_d(true, true, true).
or_d(false, true, true).
or_d(false, false, false).

/** Logical NOT **/
non_d(false, true).
non_d(true, false).

eval_b(X, X) :- logic_const(X).

/**
 * Logic constant definitions.
 */
logic_const(true).
logic_const(false).

append([],X,X).
append([X|Y],Z,[X|W]) :- append(Y,Z,W).

/**
 * Creates an initial list with the given index as false, and the rest as true, this is the return case.
 * NumberMade - the current index we are on.
 * Max - the number of pegs we need.
 * IndexOfFirstMove - the peg we are removing.
 * Board - the curret board being made.
 * Result - where we will bind the completed board.
 */
createInitialList(NumberMade, Max, IndexOfFirstMove, Board, Result) :-
    NumberMade >= Max,
    Result = Board.

/**
 * Creates an initial list with the given index as false, and the rest as true, this is recursive case when we still have more to do.
 * NumberMade - the current index we are on.
 * Max - the number of pegs we need.
 * IndexOfFirstMove - the peg we are removing.
 * Board - the curret board being made.
 * Result - where we will bind the completed board.
 */
createInitialList(NumberMade, Max, IndexOfFirstMove, Board, Result) :-
    NumberMade < Max,
    (NumberMade == IndexOfFirstMove -> append(Board, [false], NewBoard) ; append(Board, [true], NewBoard)),
    NumberMade0 is NumberMade + 1,
    createInitialList(NumberMade0, Max, IndexOfFirstMove, NewBoard, Result).

/**
 * Returns the corresponding row for the given peg.
 * PegNumber - the peg that we are getting the row for.
 * Result - the value we will bind the row to.
 */
getRow(PegNumber, Result) :- 
    getRowHelper(PegNumber, [0, 1, 3, 6, 10, 15, 21, 28, 36, 45, 55, 66, 78, 91, 105, 120, 136, 153], 0, Result).

/**
 * Helper function for the getRow function.
 * This is the case when the front element in the list is <= the PegNumber. This will recursively
 * call getRowHelper going through the list.
 * PegNumber - the peg that we are getting the row for.
 * List - the current list of total peg values we are looking at.
 * Index - the current index of the element we are looking at.
 * Result - the value we will bind the row to.
 */
getRowHelper(PegNumber, List, Index, Result) :-
    [ListHead | RestList] = List,
    ListHead =< PegNumber,
    Index0 is Index + 1,
    getRowHelper(PegNumber, RestList, Index0, Result).

/**
 * Helper function for the getRow function.
 * This is the case where the element we are looking at is greater than the PegNumber and thus we
 * are done, binding the Index to the Result.
 * PegNumber - the peg that we are getting the row for.
 * List - the current list of total peg values we are looking at.
 * Index - the current index of the element we are looking at.
 * Result - the value we will bind the row to.
 */
getRowHelper(PegNumber, List, Index, Result) :-
    [ListHead | RestList] = List,
    ListHead > PegNumber,
    Result is (Index - 1).

/**
 * This gets the displacement from the beginning of the row.
 * PegNumber - the peg we are getting the displacement for.
 * Result - the displacement that we are binding to.
 */
getDisplacement(PegNumber, Result) :-
    getRow(PegNumber, RowNumber),
    TotalPegsList = [0, 1, 3, 6, 10, 15, 21, 28, 36, 45, 55, 66, 78, 91, 105, 120, 136, 153],
    nth0(RowNumber, TotalPegsList, TotalPegs),
    Result is (PegNumber - TotalPegs).

getPegNumber(Row, Displacement, Result) :-
    (Row < 0 ; Row > 13 ; Displacement < 0 ; Displacement > Row),
    Result is -1.

/**
 * Gets the peg number for the given row and displacement.
 * Row - the row of the peg.
 * Displacement - the displacement of the peg.
 * Result - the peg number that we will bind to.
 */
getPegNumber(Row, Displacement, Result) :-
    Row >= 0,
    Row =< 13,
    Displacement >= 0,
    Displacement =< Row,
    TotalPegsList = [0, 1, 3, 6, 10, 15, 21, 28, 36, 45, 55, 66, 78, 91, 105, 120, 136, 153],
    nth0(Row, TotalPegsList, TotalPegs),
    Result is (TotalPegs + Displacement).

/**
 * Tests whether a move is valid or not based on the following conditions:
 * 
 * 1) 0 <= Land Row <= Max Number Of Rows - 1
 * 2) 0 <= Land Displacement <= Land Row
 * 3) Land Position must be vacant
 * 4) Jump Position must be occupied
 * 5) Peg Position must be occupied
 *
 * OIndex - the original peg index.
 * NIndex - the new peg index.
 * JIndex - the peg that we are jumping.
 * NumberOfRows - the number of rows in the board.
 * Board - the list of true/fail values.
 */
testMove(OIndex, NIndex, JIndex, NumberOfRows, Board) :-
    getRow(NIndex, LR),
    (LR >= 0 ; LR < NumberOfRows),
    getDisplacement(NIndex, LD),
    0 =< LR,
    LR =< (NumberOfRows - 1),
    0 =< LD,
    LD =< LR,
    nth0(OIndex, Board, OVal),
    nth0(NIndex, Board, NVal),
    nth0(JIndex, Board, JVal),
    OVal,
    not(NVal),
    JVal.

makeMove(Board, Index, OIndex, RIndex, JIndex, TotalPegs, CurrentBoard, ResultBoard) :-
    Index >= TotalPegs,
    ResultBoard = CurrentBoard.

makeMove(Board, Index, OIndex, RIndex, JIndex, TotalPegs, CurrentBoard, ResultBoard) :-
    Index < TotalPegs,
    [BoardHead | BoardTail] = Board,
    Index0 is (Index + 1),
    (((Index == JIndex) ; (BoardHead , Index \= OIndex , Index \= RIndex)) ->
        append(CurrentBoard, [true], NewBoard),
        makeMove(BoardTail, Index0, OIndex, RIndex, JIndex, TotalPegs, NewBoard, ResultBoard)
        ;
        append(CurrentBoard, [false], NewBoard),
        makeMove(BoardTail, Index0, OIndex, RIndex, JIndex, TotalPegs, NewBoard, ResultBoard)
    ).

/**
 * Tests to see if a move is valid, this is the case where it is valid.
 * Since the move is valid we append the move list and return the recursive call.
 * TODO DO THE RECURSIVE CALL!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 * OIndex - the peg number of the peg in question.
 * NIndex - the peg number of the index we are jumping to.
 * RIndex - the peg number of the peg we are jumping.
 * Board - the board that contains the pegs.
 * Rows - the number of rows in the board.
 * TotalPegs - the total number of pegs in the board.
 * MoveList - the list of moves already made.
 * ResultMoveList - the resultant move list.
 * ResultValidity - whether or not the move was valid.
 */
testAndApply(OIndex, NIndex, RIndex, Board, Rows, TotalPegs, MoveList, ResultMoveList, ResultValidity) :-
    testMove(OIndex, NIndex, RIndex, Rows, Board),
    append(MoveList,[(OIndex, RIndex)], NewMoveList),
    makeMove(Board, 0, OIndex, RIndex, JIndex, TotalPegs, [], NewBoard),
    recursiveSolve(NewBoard, Rows, TotalPegs, NewMoveList, ResultMoveList, ResultLength),
    ResultValidity = true.

/**
 * Tests to see if a move is valid, this is the case where it isn't valid and we return false.
 * OIndex - the peg number of the peg in question.
 * NIndex - the peg number of the index we are jumping to.
 * RIndex - the peg number of the peg we are jumping.
 * Board - the board that contains the pegs.
 * Rows - the number of rows in the board.
 * TotalPegs - the total number of pegs in the board.
 * MoveList - the list of moves already made.
 * ResultMoveList - the resultant move list.
 * ResultValidity - whether or not the move was valid.
 */
testAndApply(OIndex, NIndex, RIndex, Board, Rows, TotalPegs, MoveList, ResultMoveList, ResultValidity) :-
    \+ testMove(OIndex, NIndex, RIndex, Rows, Board),
    ResultMoveList = MoveList,
    ResultValidity = false.

/**
 * Gets the best valid list from a list of lists, this is the base case.
 * ListOfLists - the list of move lists.
 * ListOfValidities - the list of validities that tell if a move list is valid.
 * BestList - the best move list so far.
 * ResultList - the list that was the shortest.
 */
getBestList(ListOfLists, ListOfValidities, BestList, ResultList) :-
    ListOfLists = [],
    ResultList = BestList.

/**
 * Gets the best valid list from a list of lists.
 * ListOfLists - the list of move lists.
 * ListOfValidities - the list of validities that tell if a move list is valid.
 * BestList - the best move list so far.
 * ResultList - the list that was the shortest.
 */
getBestList(ListOfLists, ListOfValidities, BestList, ResultList) :-
    [ListHead | RestList] = ListOfLists,
    [ValidHead | RestValid] = ListOfValidities,
    length(ListHead, CurrentListLength),
    length(BestList, BestLength),
    (ValidHead , (CurrentListLength < BestLength ; BestList == []) -> 
        getBestList(RestList, RestValid, ListHead, ResultList)
        ;
        getBestList(RestList, RestValid, BestList, ResultList)
    ).

/**
 * Tests the moves around the current peg.
 * CurrentPeg - the peg in question.
 * Board - the board of pegs.
 * Rows - the number of rows in the board.
 * TotalPegs - the total number of pegs in the board.
 * MoveList - the moves made currently.
 * ResultList - the move list that we will bind to.
 * IsValid - true if there was actually a move made.
 */
testNeighborMoves(CurrentPeg, Board, Rows, TotalPegs, MoveList, ResultList, IsValid) :-
    getRow(CurrentPeg, R),
    getDisplacement(CurrentPeg, D),

    RM2 is (R - 2),
    RM1 is (R - 1),
    RP1 is (R + 1),
    RP2 is (R + 2),

    DM2 is (D - 2),
    DM1 is (D - 1),
    DP1 is (D + 1),
    DP2 is (D + 2),

    getPegNumber(RM2, DM2, T0RIndex),
    getPegNumber(RM1, DM1, T0NIndex),
    testAndApply(CurrentPeg, T0RIndex, T0NIndex, Board, Rows, TotalPegs, MoveList, T0List, T0Validity),

    getPegNumber(RM2, D, T1RIndex),
    getPegNumber(RM1, D, T1NIndex),
    testAndApply(CurrentPeg, T1RIndex, T1NIndex, Board, Rows, TotalPegs, MoveList, T1List, T1Validity),

    getPegNumber(R, DP2, T2RIndex),
    getPegNumber(R, DP1, T2NIndex),
    testAndApply(CurrentPeg, T2RIndex, T2NIndex, Board, Rows, TotalPegs, MoveList, T2List, T2Validity),

    getPegNumber(RP2, DP2, T3RIndex),
    getPegNumber(RP1, DP1, T3NIndex),
    testAndApply(CurrentPeg, T3RIndex, T3NIndex, Board, Rows, TotalPegs, MoveList, T3List, T3Validity),

    getPegNumber(RP2, D, T4RIndex),
    getPegNumber(RP1, D, T4NIndex),
    testAndApply(CurrentPeg, T4RIndex, T4NIndex, Board, Rows, TotalPegs, MoveList, T4List, T4Validity),

    getPegNumber(R, DM2, T5RIndex),
    getPegNumber(R, DM1, T5NIndex),
    testAndApply(CurrentPeg, T5RIndex, T5NIndex, Board, Rows, TotalPegs, MoveList, T5List, T5Validity),

    getBestList([T0List, T1List, T2List, T3List, T4List, T5List], [T0Validity, T1Validity, T2Validity, T3Validity, T4Validity, T5Validity], [], ResultList),
    (ResultList == [] -> IsValid = false ; IsValid = true).


getBestNeighborList(Board, Rows, TotalPegs, MoveList, Index, BestList, BestLength, ResultList, ResultLength) :-
    Index >= TotalPegs,
    ResultList = BestList,
    ResultLength = BestLength.

getBestNeighborList(Board, Rows, TotalPegs, MoveList, Index, BestList, BestLength, ResultList, ResultLength) :-
    Index < TotalPegs,
    testNeighborMoves(Index, Board, Rows, TotalPegs, MoveList, CurrentList, IsValid),
    length(CurrentList, CurrentLength),
    Index0 is (Index + 1),
    (IsValid , (CurrentLength < BestLength ; BestList == []) ->
        getBestNeighborList(Board, Rows, TotalPegs, MoveList, Index0, CurrentList, CurrentLength, ResultList, ResultLength)
        ;
        getBestNeighborList(Board, Rows, TotalPegs, MoveList, Index0, BestList, BestLength, ResultList, ResultLength)
    ).

/**
 * Recursively solves a board.
 * Board - the current board of pegs.
 * Rows - the number of rows in the board.
 * TotalPegs - the total number of pegs in the board.
 * MoveList - the list of moves that have been done.
 * ResultList - the resulting list of moves that we will bind to.
 * ResultLength - the resulting length of the list of moves.
 */
recursiveSolve(Board, Rows, TotalPegs, MoveList, ResultList, ResultLength) :-
    getBestNeighborList(Board, Rows, TotalPegs, MoveList, 0, [], 0, NeighborList, NeighborLength),
    (NeighborList == [] ->
        ResultList = MoveList,
        length(MoveList, ResultLength)
        ;
        ResultList = NeighborList,
        length(NeighborList, ResultLength)
    ).

/**
 * This solves a board for a specific initial peg, in this case we are done looking through all pegs.
 * Rows - the number of rows in the board.
 * NumberOfPegs - the number of pegs in the board.
 * Index - the current peg we start by removing.
 * CurrentBestList - the current best move list in the chain.
 * CurrentBestNumber - the current best size of the move list.
 * ResultMoveList - where we will bind the best move list.
 * ResultNumber - where we will bind the size of the move list.
 */
solveInitial(Rows, NumberOfPegs, Index, CurrentBestList, CurrentBestNumber, ResultMoveList, ResultNumber) :-
    Index >= NumberOfPegs,
    ResultMoveList = CurrentBestList,
    ResultNumber = CurrentBestNumber.

/**
 * This solves a board for a specific initial peg, in this case we haven't looked through all pegs and so we can keep going.
 * Rows - the number of rows in the board.
 * NumberOfPegs - the number of pegs in the board.
 * Index - the current peg we start by removing.
 * CurrentBestList - the current best move list in the chain.
 * CurrentBestNumber - the current best size of the move list.
 * ResultMoveList - where we will bind the best move list.
 * ResultNumber - where we will bind the size of the move list.
 */
solveInitial(Rows, NumberOfPegs, Index, CurrentBestList, CurrentBestNumber, ResultMoveList, ResultNumber) :-
    Index < NumberOfPegs,
    createInitialList(0, NumberOfPegs, Index, [], IBoard),
    recursiveSolve(IBoard, Rows, NumberOfPegs, [(Index, Index)], RecursiveList, RecursiveLength),
    Index0 is (Index + 1),
    (RecursiveLength < CurrentBestNumber ->
        solveInitial(Rows, NumberOfPegs, Index0, RecursiveList, RecursiveLength, ResultMoveList, ResultNumber)
        ;
        solveInitial(Rows, NumberOfPegs, Index0, CurrentBestList, CurrentBestNumber, ResultMoveList, ResultNumber)
    ).

/**
 * Solves a peg game board for the most pegs left with no available moves.
 * Rows - the number of rows in the board.
 * NumberOfMoves - the number of moves it takes, we will bind to this.
 * MoveList - the moves in list form, we will bind to this.
 */
solve(Rows, NumberOfMoves, MoveList) :-
    TotalPegsList = [0, 1, 3, 6, 10, 15, 21, 28, 36, 45, 55, 66, 78, 91, 105, 120, 136, 153],
    nth0(Rows, TotalPegsList, NumberOfPegs),
    solveInitial(Rows, NumberOfPegs, 0, [], NumberOfPegs, NumberOfMoves, MoveList).
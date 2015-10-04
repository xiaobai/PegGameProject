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
    append(MoveList,[(OIndex, RIndex)], ResultMoveList),
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
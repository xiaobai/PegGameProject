/*
 * To run this prolog program do:
 * swipl -s PegGame.pl
 */

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
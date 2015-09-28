#!/usr/bin/python

import sys

#####################
# Utility functions #
#####################
TOTAL_PEG_TABLE = [0, 1, 3, 6, 10, 15, 21, 28, 36, 45, 55, 66, 78, 91, 105, 120, 136, 153];
pegBoard = [];
currentBest = 0;
numberOfRows = 0;

# Returns the corresponding row for a given peg number.
def getRow(pegNumber):
    i = 0;
    for val in TOTAL_PEG_TABLE:
        if (val > pegNumber):
            return i - 1;
        i = i + 1;
    return -1;

# Returns the displacement of the peg in its row.
def getDisplacement(pegNumber):
    return pegNumber - TOTAL_PEG_TABLE[getRow(pegNumber)];

# Returns the peg number for a given row and displacement.
def getPegNumber(row, displacement):
    if (row < 0 or row >= len(TOTAL_PEG_TABLE) or displacement < 0 or displacement > row):
        return -1;
    return TOTAL_PEG_TABLE[row] + displacement;

# Applies a move to the board.
def applyMove(originalPosition, newPosition, removedPiece):
    pegBoard[originalPosition] = False;
    pegBoard[newPosition] = True;
    pegBoard[removedPiece] = False;
    return;

# Reverses a move on the board.
def reverseMove(originalPosition, newPosition, removedPiece):
    pegBoard[originalPosition] = True;
    pegBoard[newPosition] = False;
    pegBoard[removedPiece] = True;
    return;

# Tests a move to see if it is valid.
def testMove(originalPosition, newPosition, removedPiece):
    # TODO Implement
    global numberOfRows;
    lR = getRow(newPosition);
    if (lR < 0 or lR >= numberOfRows):
        return False;
    lD = getDisplacement(newPosition);
    if (0 <= lR and lR <= numberOfRows - 1 and 0 <= lD and lD <= lR):
        return (pegBoard[originalPosition] and not pegBoard[newPosition] and pegBoard[removedPiece]);
    return False;

# Tests the move to see if it is valid and then applies it calling the solve function.
def testAndApply(current, next, jump, numberOfPegsLeft, totalNumberOfPegs):
    if (testMove(current, next, jump)):
        applyMove(current, next, jump);
        numberOfPegsLeft = numberOfPegsLeft - 1;
        recursiveSolve(current, next, jump, numberOfPegsLeft, totalNumberOfPegs);
        return True;
    return False;

# Tests all 6 possible moves and makes them if possible.
def testNeightborMoves(pegNumber, numberOfPegsLeft, totalNumberOfPegs):
    validMove = False;
    r = getRow(pegNumber);
    d = getDisplacement(pegNumber);
    

    # (R, D), (R - 2, D), (R - 1, D)
    land = getPegNumber(r - 2, d);
    jump = getPegNumber(r - 1, d);
    validMove = validMove or testAndApply(pegNumber, land, jump, numberOfPegsLeft, totalNumberOfPegs);
    
    # (R, D), (R, D + 2), (R, D + 1)
    land = getPegNumber(r, d + 2);
    jump = getPegNumber(r, d + 1);
    validMove = validMove or testAndApply(pegNumber, land, jump, numberOfPegsLeft, totalNumberOfPegs);

    # (R, D), (R + 2, D + 2), (R + 1, D + 1)
    land = getPegNumber(r + 2, d + 2);
    jump = getPegNumber(r + 1, d + 1);
    validMove = validMove or testAndApply(pegNumber, land, jump, numberOfPegsLeft, totalNumberOfPegs);

    # (R, D), (R + 2, D), (R + 1, D)
    land = getPegNumber(r + 2, d);
    jump = getPegNumber(r + 1, d);
    validMove = validMove or testAndApply(pegNumber, land, jump, numberOfPegsLeft, totalNumberOfPegs);

    # (R, D), (R, D - 2), (R, D - 1)
    land = getPegNumber(r, d - 2);
    jump = getPegNumber(r, d - 1);
    validMove = validMove or testAndApply(pegNumber, land, jump, numberOfPegsLeft, totalNumberOfPegs);

    # (R, D), (R - 2, D - 2), (R - 1, D - 1)
    land = getPegNumber(r - 2, d - 2);
    jump = getPegNumber(r - 1, d - 1);
    validMove = validMove or testAndApply(pegNumber, land, jump, numberOfPegsLeft, totalNumberOfPegs);
    
    return validMove;

# Recursively solves the board
def recursiveSolve(originalPosition, newPosition, removedPiece, numberOfPegsLeft, totalNumberOfPegs):
    global currentBest;
    print numberOfPegsLeft;
    if (numberOfPegsLeft > currentBest):
        validMove = False;
        for i in range(0, totalNumberOfPegs):
            if (pegBoard[i]):
                validMove = validMove or testNeightborMoves(i, numberOfPegsLeft, totalNumberOfPegs);
        if (not validMove):
            currentBest = numberOfPegsLeft;
            # TODO I should probably print the moves here :P
    reverseMove(originalPosition, newPosition, removedPiece);
    numberOfPegsLeft = numberOfPegsLeft + 1;
    return;

# Main driver function for the solver.
def solve(numberOfPegs):
    numberOfPegsLeft = numberOfPegs;
    for i in range(0, numberOfPegs):
        applyMove(i, i, i);
        numberOfPegsLeft = numberOfPegsLeft - 1;
        recursiveSolve(i, i, i, numberOfPegsLeft, totalNumberOfPegs);
    return

########
# MAIN #
########
rows = sys.argv[1];
totalNumberOfPegs = TOTAL_PEG_TABLE[int(rows)];
numberOfRows = int(rows);
for x in range(0, totalNumberOfPegs):
    pegBoard.append(True);
solve(totalNumberOfPegs);
print currentBest;
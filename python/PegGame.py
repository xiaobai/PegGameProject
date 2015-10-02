#!/usr/bin/python

import sys

bestSolution = 0
numberOfCalls = 0

# Used to get the row that corresponds to a peg number given.
def getRow(pegNumber):
    TOTAL_PEGS_TABLE = [0, 1, 3, 6, 10, 15, 21, 28, 36, 45, 55, 66, 78, 91, 105, 120, 136, 153]
    i = 0
    while (TOTAL_PEGS_TABLE[i] <= pegNumber):
        i = i + 1
    return i - 1

# Used to get the displacement that corresponds to a peg number given.
def getDisplacement(pegNumber):
    TOTAL_PEGS_TABLE = [0, 1, 3, 6, 10, 15, 21, 28, 36, 45, 55, 66, 78, 91, 105, 120, 136, 153]
    return pegNumber - TOTAL_PEGS_TABLE[getRow(pegNumber)]

# Used to get a peg number that corresponds to a row and displacement.
def getPegNumber(row, displacement):
    TOTAL_PEGS_TABLE = [0, 1, 3, 6, 10, 15, 21, 28, 36, 45, 55, 66, 78, 91, 105, 120, 136, 153]
    if (row < 0 or row >= len(TOTAL_PEGS_TABLE) or displacement < 0 or displacement > row):
        return -1
    return TOTAL_PEGS_TABLE[row] + displacement

# Tests whether a move is valid or not based on the following criteria:
#
# 0) 0 <= Land Row <= Max Number of Rows - 1
# 1) 0 <= Land Displacement <= Land Row
# 2) Land Postiion must be vacant
# 3) Jump Position must be occupied
# 4) Peg Position must be occupied
def testMove(previousPosition, newPosition, removePosition, board, rows):
    lR = getRow(newPosition)
    if (lR < 0 or lR >= rows):
        return False
    lD = getDisplacement(newPosition)
    if (0 <= lR and lR <= rows - 1 and 0 <= lD and lD <= lR):
        return (board[previousPosition] and (not board[newPosition]) and board[removePosition])
    return False

def testAndApply(previousPosition, newPosition, removePosition, board, pegsLeft, pegsTotal, rows, best):
    global bestSolution
    if testMove(previousPosition, newPosition, removePosition, board, rows):
        board[previousPosition] = False
        board[newPosition] = True
        board[removePosition] = False
        recursiveSolve(previousPosition, newPosition, removePosition, board, pegsLeft - 1, pegsTotal, rows, best)
        board[previousPosition] = True
        board[newPosition] = False
        board[removePosition] = True
        return True
    return False

# This tests all 6 possible moves to see if any are possible and if so then it
# will call recursiveSolve using the move after applying the move.
def testNeighborMoves(currentPeg, board, pegsLeft, pegsTotal, rows, best):
    validMove = False
    # TODO Implement
    r = getRow(currentPeg)
    d = getDisplacement(currentPeg)

    land = getPegNumber(r - 2, d)
    jump = getPegNumber(r - 1, d)
    validMove = validMove or testAndApply(currentPeg, land, jump, board, pegsLeft, pegsTotal, rows, best)
    
    land = getPegNumber(r, d + 2)
    jump = getPegNumber(r, d + 1)
    validMove = validMove or testAndApply(currentPeg, land, jump, board, pegsLeft, pegsTotal, rows, best)

    land = getPegNumber(r + 2, d + 2)
    jump = getPegNumber(r + 1, d + 1)
    validMove = validMove or testAndApply(currentPeg, land, jump, board, pegsLeft, pegsTotal, rows, best)

    land = getPegNumber(r + 2, d)
    jump = getPegNumber(r + 1, d)
    validMove = validMove or testAndApply(currentPeg, land, jump, board, pegsLeft, pegsTotal, rows, best)

    land = getPegNumber(r, d - 2)
    jump = getPegNumber(r, d - 1)
    validMove = validMove or testAndApply(currentPeg, land, jump, board, pegsLeft, pegsTotal, rows, best)

    land = getPegNumber(r - 2, d - 2)
    jump = getPegNumber(r - 1, d - 1)
    validMove = validMove or testAndApply(currentPeg, land, jump, board, pegsLeft, pegsTotal, rows, best)
    return validMove

def printBoard(board, rows, maxNumberOfPegs):
    TOTAL_PEGS_TABLE = [0, 1, 3, 6, 10, 15, 21, 28, 36, 45, 55, 66, 78, 91, 105, 120, 136, 153]
    totalPrinted = 0
    currentRow = 0
    currentString = ""
    totalString = ""
    maxStringLength = (2 * (rows)) - 1
    while (totalPrinted < maxNumberOfPegs):
        if (totalPrinted == TOTAL_PEGS_TABLE[currentRow]):
            currentRow = currentRow + 1
            while (len(currentString) < maxStringLength):
                currentString = " " + currentString + " "
            totalString = totalString + currentString + "\n"
            currentString= ""
        currentString = currentString + " " + ("1" if board[totalPrinted] else "0")
        totalPrinted = totalPrinted + 1
    totalString = totalString + currentString
    print totalString
    return

def recursiveSolve(previousPosition, newPosition, removePosition, board, pegsLeft, pegsTotal, rows, best):
    global bestSolution
    print pegsLeft
    if (pegsLeft > bestSolution):
        validMove = False
        i = 0
        while (i < pegsTotal):
            if (board[i]):
                validMove = validMove or testNeighborMoves(i, board, pegsLeft, pegsTotal, rows, best)
            i = i + 1
        if (not validMove):
            bestSolution = pegsLeft
            best = pegsLeft
    return

def solve(board, rows, pegsTotal):
    TOTAL_PEGS_TABLE = [0, 1, 3, 6, 10, 15, 21, 28, 36, 45, 55, 66, 78, 91, 105, 120, 136, 153]
    i = 0
    while (i < pegsTotal):
        print "I : " + str(i)
        board[i] = False
        recursiveSolve(i, i, i, board, pegsTotal - 1, pegsTotal, rows, 0)
        board[i] = True
        i = i + 1
    return

rows = 5

i = 0
board = []
while (i < 15):
    board.append(True)
    i = i + 1
solve(board, rows, 15)
print bestSolution
#!/usr/bin/python

import sys

bestSolution = 0
bestMoves = []
numberOfCalls = 0
initialPeg = 0
TOTAL_PEGS_TABLE = [0, 1, 3, 6, 10, 15, 21, 28, 36, 45, 55, 66, 78, 91, 105, 120, 136, 153]

# Used to get the row that corresponds to a peg number given.
# Start counting rows at 1, ends at rows
def getRow(pegNumber):
    i = 0
    while (TOTAL_PEGS_TABLE[i] <= pegNumber):
        i += 1
    return i


# Used to get the displacement that corresponds to a peg number given.
# Start counting pegs at 0, ends at row - 1
def getDisplacement(pegNumber):
    return pegNumber - TOTAL_PEGS_TABLE[getRow(pegNumber) - 1]

# Used to get a peg number that corresponds to a row and displacement.
# Start counting at 0, ends at TOTAL_PEGS_TABLE[rows]
def getPegNumber(row, displacement):
    if (row < 1 or row > len(TOTAL_PEGS_TABLE) or displacement < 0 or displacement >= row):
        return -1
    return TOTAL_PEGS_TABLE[row - 1] + displacement

# Tests whether a move is valid or not based on the following criteria:
#
# 0) 0 <= Land Row <= Max Number of Rows
# 1) 0 <= Land Displacement <= Land Row
# 2) Land Postiion must be vacant
# 3) Jump Position must be occupied
# 4) Peg Position must be occupied
#
# Returns True if the move is valid. False otherwise.
def testMove(previousPosition, newPosition, removePosition, board, rows):
    lR = getRow(newPosition)
    if (lR < 1 or lR > rows):
        return False
    lD = getDisplacement(newPosition)
    if ((1 <= lR <= rows) and (0 <= lD < lR)):
        return (board[previousPosition] and (not board[newPosition]) and board[removePosition])
    return False

# Applies a move to the board
def applyMove(previousPosition, newPosition, removePosition, board, moves):
    board[previousPosition] = False
    board[newPosition] = True
    board[removePosition] = False
    moves.append((previousPosition,newPosition))

# Reverses a move on the board
def reverseMove(previousPosition, newPosition, removePosition, board, moves):
    board[previousPosition] = True
    board[newPosition] = False
    board[removePosition] = True
    moves.pop()

# Applies a move, tests the move among, and then reverses the move
def testAndApply(previousPosition, newPosition, removePosition, board, pegsLeft, pegsTotal, rows, moves):
    if testMove(previousPosition, newPosition, removePosition, board, rows):
        applyMove(previousPosition, newPosition, removePosition, board, moves)
        recursiveSolve(board, pegsLeft - 1, pegsTotal, rows, moves)
        reverseMove(previousPosition, newPosition, removePosition, board, moves)
        return True
    return False

# This tests all 6 possible moves to see if any are possible. If so, it will
# test the move and see what happens.
def testNeighborMoves(currentPeg, board, pegsLeft, pegsTotal, rows, moves):
    validMove = False
    r = getRow(currentPeg)
    d = getDisplacement(currentPeg)

    land = getPegNumber(r - 2, d)
    jump = getPegNumber(r - 1, d)
    validMove |= testAndApply(currentPeg, land, jump, board, pegsLeft, pegsTotal, rows, moves)
    
    land = getPegNumber(r, d + 2)
    jump = getPegNumber(r, d + 1)
    validMove |= testAndApply(currentPeg, land, jump, board, pegsLeft, pegsTotal, rows, moves)

    land = getPegNumber(r + 2, d + 2)
    jump = getPegNumber(r + 1, d + 1)
    validMove |= testAndApply(currentPeg, land, jump, board, pegsLeft, pegsTotal, rows, moves)

    land = getPegNumber(r + 2, d)
    jump = getPegNumber(r + 1, d)
    validMove |= testAndApply(currentPeg, land, jump, board, pegsLeft, pegsTotal, rows, moves)

    land = getPegNumber(r, d - 2)
    jump = getPegNumber(r, d - 1)
    validMove |= testAndApply(currentPeg, land, jump, board, pegsLeft, pegsTotal, rows, moves)

    land = getPegNumber(r - 2, d - 2)
    jump = getPegNumber(r - 1, d - 1)
    validMove |= testAndApply(currentPeg, land, jump, board, pegsLeft, pegsTotal, rows, moves)
    return validMove

def recursiveSolve(board, pegsLeft, pegsTotal, rows, moves):
    global bestSolution
    global bestMoves
    if (pegsLeft > bestSolution):
        validMove = False
        for i in range(0, pegsTotal):
            if (board[i]):
                validMove |= testNeighborMoves(i, board, pegsLeft, pegsTotal, rows, moves)
        if (not validMove):
            bestSolution = pegsLeft
            bestMoves = []
            for m in moves:
                bestMoves.append(m)
    return

def solve(board, rows, pegsTotal, moves):
    i = 0
    for i in range(0, pegsTotal):
        board[i] = False
        recursiveSolve(board, pegsTotal - 1, pegsTotal, rows, moves)
        board[i] = True
    return

def usage():
    print "Usage: python PegGame.py -s <rows>"
    print "rows must be an integer between 5 and 10, inclusive"


# This is used specifically to check if
# the flags argument is an integer
def isInteger(a):
    try:
        int(a)
        return True
    except ValueError:
        return False

if __name__ == '__main__':
    if len(sys.argv) is not 3:
        print "Error: Incorrect amount of arguments."
        usage()
        sys.exit()

    flag = sys.argv[1]
    rows = sys.argv[2]
    if (flag != "-s") or (not isInteger(rows)) or not (5 <= int(rows) <= 10):
        print "Error: Incorrect arguments"
        usage()
        sys.exit()

    rows = int(rows)
    i = 0
    board = []
    moves = []
    for i in range(0,TOTAL_PEGS_TABLE[rows]):
        board.append(True)
        i += 1

    solve(board, rows, TOTAL_PEGS_TABLE[rows], moves)
    print bestSolution
    for m in bestMoves:
        print m

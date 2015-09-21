import java.io.IOException;
import java.util.Iterator;
import java.util.Stack;
import java.util.logging.*;

/**
 * Main driver class for the peg game project.
 */
public class PegGame {
    // This table contains the total number of pegs up to a certain row.
    private static final int[] TOTAL_PEGS_TABLE = {
            0, 1, 3, 6, 10, 15, 21, 28, 36, 45, 55, 66, 78, 91, 105, 120, 136, 153
    };

    private Logger logger;

    private int numberOfRows;
    private int maxNumberOfPegs;
    private int numberOfPegs;
    private int currentBest;
    private boolean[] pegBoard;

    private String bestMoveString;
    private Stack<Move> moveStack;

    /**
     * Creates a PegGame object with the number of rows specified.
     */
    public PegGame(int rows) {
        numberOfRows = rows;
        maxNumberOfPegs = TOTAL_PEGS_TABLE[rows];
        numberOfPegs = maxNumberOfPegs;
        currentBest = 0;
        pegBoard = new boolean[maxNumberOfPegs];
        for (int i = 0 ; i < maxNumberOfPegs ; i++) {
            pegBoard[i] = true;
        }
        moveStack = new Stack<>();
        bestMoveString = "";
        createLogger();
    }

    /**
     * A method that goes through various methods to test.
     */
    public void test() {
        logger.info("Test method");

        // For each peg number we want to print out the row and column for it.
        String msg = "Peg Number (Row, Displacement) Recreated Peg Number";
        for (int i = 0 ; i < pegBoard.length ; i++) {
            int r = getRow(i);
            int d = getDisplacement(i);
            msg += i + " (" + r +  "," + d + ") " + getPegNumber(r, d) + "\n";
        }
        logger.info(msg);

        logger.info("Initial state of the board\n");
        printBoard();

        logger.info("Removing pin at position 0\n");
        Move move = new Move(0, 0, 0);
        applyMove(move);
        printBoard();

        logger.info("Making move from 3 to 0 removing 1.");
        move = new Move(3, 0, 1);
        applyMove(move);
        printBoard();

        logger.info("Reversing both moves.");
        reverseMove(move);
        printBoard();
        move = new Move(0, 0, 0);
        reverseMove(move);
        printBoard();

        /*
         * Testing Jumping Methods
         */
        logger.info("************************\n" +
                    "Testing jumping methods.\n" +
                    "************************\n");
        Move valid;
        Move blocked;
        Move invalid;

        /*
         * Testing Upper Right Move
         *
         * ((R, D), (R - 2, D), (R - 1, D)
         */
        logger.info("**************************\n" +
                "Testing Upper Right Moves\n" +
                "**************************\n");
        move = new Move(2, 2, 2);
        applyMove(move);
        logger.info("Initial board");
        printBoard();

        valid = new Move(7, 2, 4);
        blocked = new Move(3, 0, 1);
        invalid = new Move(1, -1, 0);
        testMoveCombinations(valid, blocked, invalid);

        move = new Move(2, 2, 2);
        reverseMove(move);

        /*
         * Testing Right Moves
         */
        logger.info("*********************\n" +
                    "Testing Right Moves.\n" +
                    "*********************\n");
        move = new Move(9, 9, 9);
        applyMove(move);
        logger.info("Initial board");
        printBoard();

        valid = new Move(7, 9, 8);
        blocked = new Move(3, 5, 4);
        invalid = new Move(1, -1, 2);
        testMoveCombinations(valid, blocked, invalid);

        move = new Move(9, 9, 9);
        reverseMove(move);

        /*
         * Testing Lower Right Moves
         */
        logger.info("**************************\n" +
                    "Testing Lower Right Moves.\n" +
                    "**************************\n");
        move = new Move(8, 8, 8);
        applyMove(move);
        logger.info("Initial board");
        printBoard();

        valid = new Move(4, 8, 13);
        blocked = new Move(2, 9, 5);
        invalid = new Move(8, 19, 13);
        testMoveCombinations(valid, blocked, invalid);

        move = new Move(8, 8, 8);
        reverseMove(move);

        /*
         * Testing Lower Left Moves
         */
        logger.info("*************************\n" +
                    "Testing Lower Left Moves.\n" +
                    "*************************\n");
        move = new Move(12, 12, 12);
        applyMove(move);
        logger.info("Initial board");
        printBoard();

        valid = new Move(5, 12, 8);
        blocked = new Move(2, 7, 4);
        invalid = new Move(8, 17, 12);
        testMoveCombinations(valid, blocked, invalid);

        move = new Move(12, 12, 12);
        reverseMove(move);

        /*
         * Testing Lower Left Moves
         */
        logger.info("*******************\n" +
                    "Testing Left Moves.\n" +
                    "*******************\n");
        move = new Move(7, 7, 7);
        applyMove(move);
        logger.info("Initial board");
        printBoard();

        valid = new Move(9, 7, 8);
        blocked = new Move(5, 3, 4);
        invalid = new Move(2, 1, 0);
        testMoveCombinations(valid, blocked, invalid);

        move = new Move(12, 12, 12);
        reverseMove(move);
    }

    private void testMoveCombinations(Move valid, Move blocked, Move invalid) {
        logger.info("Testing move " + valid + " the valid move");
        logger.info("Valid : " + testMove(valid));
        logger.info("Testing move " + blocked + " the blocked move");
        logger.info("Valid : " + testMove(blocked));
        logger.info("Testing move " + invalid + " the invalid move");
        logger.info("Valid : " + testMove(invalid));
    }

    /**
     * Creates the logger for logging the solution.
     */
    private void createLogger() {
        logger = Logger.getLogger("solution.log");
        try {

            // This block configure the logger with handler and formatter
            FileHandler fh = new FileHandler("solution.log");
            logger.addHandler(fh);
            MyFormatter formatter = new MyFormatter();
            fh.setFormatter(formatter);
        } catch (SecurityException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
        logger.info("Created the logger");
    }

    /**
     * Returns the corresponding row for the given peg.
     */
    private int getRow(int pegNumber) {
        int i;
        // Loop until the number of pegs becomes greater.
        for (i = 0 ; TOTAL_PEGS_TABLE[i] <= pegNumber ; i++);
        return i - 1;
    }

    /**
     * Returns the displacement from the beginning of the row.
     */
    private int getDisplacement(int pegNumber) {
        return pegNumber - TOTAL_PEGS_TABLE[getRow(pegNumber)];
    }

    /**
     * Returns the peg number for the given row and displacement.
     */
    private int getPegNumber(int row, int displacement) {
        if (row < 0 || row >= TOTAL_PEGS_TABLE.length || displacement < 0 ||
                displacement > row) {
            return -1;
        }
        return TOTAL_PEGS_TABLE[row] + displacement;
    }

    private void printBoard() {
        int totalPrinted = 0;
        int currentRow = 0;
        String currentString = "";
        String totalString = "";
        int maxStringLength = (2 * (numberOfRows)) - 1;
        for (; totalPrinted < maxNumberOfPegs ; totalPrinted++) {
            if (totalPrinted == TOTAL_PEGS_TABLE[currentRow]) {
                currentRow++;
                currentString.trim();
                while (currentString.length() < maxStringLength) {
                    currentString = " " + currentString + " ";
                }
                totalString += currentString + "\n";
                currentString = "";
            }
            currentString =
                    currentString + " " + (pegBoard[totalPrinted] ? "1" : "0");
        }
        totalString += currentString;
        logger.info(totalString);
    }

    /**
     * Applies the move to the board.
     */
    private void applyMove(Move move) {
        pegBoard[move.originalPosition] = false;
        pegBoard[move.newPosition] = true;
        pegBoard[move.removedPiece] = false;
        numberOfPegs--;
        // logger.info("Applied move : " + move + "\n");
        moveStack.push(move);
    }

    private void reverseMove(Move move) {
        pegBoard[move.originalPosition] = true;
        pegBoard[move.newPosition] = false;
        pegBoard[move.removedPiece] = true;
        numberOfPegs++;
        // logger.info("Reversed move : " + move + "\n");
        moveStack.pop();
    }

    /**
     * Main driver method for the solver.
     */
    public void solve() {
        // TODO Check if the logic here is sound.
        int max = TOTAL_PEGS_TABLE[(numberOfRows / 2) + 1];
        logger.info("PEGS TO CHECK : " + max);
        for (int i = 0 ; i < max ; i++) {
            Move move = new Move(i, i, i);
            applyMove(move);
            recursiveSolve(move);
        }
        logger.info("Best Worst Case Scenario\n");
        logger.info("Most Pegs Left : " + currentBest + "\n");
        logger.info(bestMoveString);
    }

    public void recursiveSolve(Move previousMove) {
        /*
        This works to actually solve the puzzle LOL
        if (numberOfPegs == 1) {
            String moveString = "";
            while (!moveStack.isEmpty()) {
                moveString = moveStack.pop() + "\n" + moveString;
            }
            logger.info("Way to complete the game!!!");
            logger.info(moveString);
            System.exit(0);
        }
        */
        System.out.println("Number of pegs : " + numberOfPegs +
                " current best : " + currentBest);
        if (numberOfPegs > currentBest) {
            printBoard();

            // We have to loop through all pegs to see if we can make a move on any
            // of them. For each possible move we will make it and then we will
            // call this again with the new board.
            boolean validMove = false;
            for (int i = 0 ; i < maxNumberOfPegs ; i++) {
                if (pegBoard[i]) {
                    validMove |= testNeighborMoves(i);
                }
            }

            // We should save the value if it is the best we have achieved.
            if (!validMove) {
                currentBest = numberOfPegs;
                Iterator<Move> iterator = moveStack.iterator();
                bestMoveString = "";
                while (iterator.hasNext()) {
                    bestMoveString = iterator.next() + "\n" + bestMoveString;
                }
            }
        }

        // Once we are done testing that move then we have to reverse it.
        reverseMove(previousMove);
    }

    /**
     * This tests all 6 possible moves to see if any are possible, and if they
     * are possible, then it will call recursiveSolve using the move after
     * this method applies the move.
     * @param currentPeg
     * @return true if there was a valid move taken.
     */
    private boolean testNeighborMoves(int currentPeg) {
        boolean validMove = false;
        // These are the 6 possible move directions with O being the peg in
        // question.
        //  6 1
        // 5 O 2
        //  4 3
        // We will test these in order.

        int r = getRow(currentPeg);
        int d = getDisplacement(currentPeg);
        int land;
        int jump;

        // logger.info("Original : " + currentPeg);

        // 1
        // ((R, D), (R - 2, D), (R - 1, D))
        land = getPegNumber(r - 2, d);
        jump = getPegNumber(r - 1, d);
        // logger.info("Test before land = " + land + " and jump = " + jump);
        validMove |= testAndApply(currentPeg, land, jump);

        // 2
        // ((R, D), (R, D + 2), (R, D + 1))
        land = getPegNumber(r, d + 2);
        jump = getPegNumber(r, d + 1);
        // logger.info("Test before land = " + land + " and jump = " + jump);
        validMove |= testAndApply(currentPeg, land, jump);

        // 3
        // ((R, D), (R + 2, D + 2), (R + 1, D + 1))
        land = getPegNumber(r + 2, d + 2);
        jump = getPegNumber(r + 1, d + 1);
        // logger.info("Test before land = " + land + " and jump = " + jump);
        validMove |= testAndApply(currentPeg, land, jump);

        // 4
        // ((R, D), (R - 2, D - 2), (R - 1, D - 1))
        land = getPegNumber(r + 2, d);
        jump = getPegNumber(r + 1, d);
        // logger.info("Test before land = " + land + " and jump = " + jump);
        validMove |= testAndApply(currentPeg, land, jump);

        // 5
        // ((R, D), (R, D - 2), (R, D - 1))
        land = getPegNumber(r, d - 2);
        jump = getPegNumber(r, d - 1);
        // logger.info("Test before land = " + land + " and jump = " + jump);
        validMove |= testAndApply(currentPeg, land, jump);

        // 6
        // ((R, D), (R - 2, D - 2), (R - 1, D - 1))
        land = getPegNumber(r - 2, d - 2);
        jump = getPegNumber(r - 1, d - 1);
        // logger.info("Test before land = " + land + " and jump = " + jump);
        validMove |= testAndApply(currentPeg, land, jump);

        return validMove;
    }

    /**
     * Tests a combination of moves and then applies it if it works.
     */
    private boolean testAndApply(int current, int next, int jump) {
        Move move = new Move(current, next, jump);
        if (testMove(move)) {
            applyMove(move);
            recursiveSolve(move);
            return true;
        }
        return false;
    }

    /**
     * Tests whether a move is valid or not. There are multiple conditions that
     * need to be satisfied:
     *
     * 1) 0 <= Land Row <= Max Number Of Rows - 1
     * 2) 0 <= Land Displacement <= Land Row
     * 3) Land Position must be vacant
     * 4) Jump Position must be occupied
     * 5) Peg Position must be occupied
     *
     * @param move
     * @return
     */
    private boolean testMove(Move move) {
        int lR = getRow(move.newPosition);
        if (lR < 0 || lR >= numberOfRows) {
            return false;
        }
        int lD = getDisplacement(move.newPosition);
        if (0 <= lR && lR <= numberOfRows - 1 && 0 <= lD && lD <= lR) {
            return (pegBoard[move.originalPosition] &&
                    !pegBoard[move.newPosition] &&
                    pegBoard[move.removedPiece]);
        }
        return false;
    }

    // This program will take in one argument, "-s <int>", which will range from
    // 5 to 10 and this corresponds to the number of rows in the game.
    public static void main(String[] args) {
        if (args.length == 0) {
            // TODO Take this out, this will be how we test internal methods.
            PegGame pegGame = new PegGame(5);
            pegGame.test();
            return;
        }
        int rows = Integer.parseInt(args[0]);
        PegGame pegGame = new PegGame(rows);
        pegGame.solve();
    }

    private class Move {
        int originalPosition;
        int newPosition;
        int removedPiece;

        public Move(int originalPosition, int newPosition, int removedPiece) {
            this.originalPosition = originalPosition;
            this.newPosition = newPosition;
            this.removedPiece = removedPiece;
        }

        public String toString() {
            return "(" + originalPosition + "," + newPosition + ")";
        }

        public boolean isEqual(Move move) {
            if (    move.originalPosition == this.originalPosition &&
                    move.newPosition == this.newPosition &&
                    move.removedPiece == this.removedPiece) {
                return true;
            }
            return false;
        }
    }

    private class MyFormatter extends SimpleFormatter {
        public String format(LogRecord record){
            return record.getMessage() + "\n";
        }
    }
}

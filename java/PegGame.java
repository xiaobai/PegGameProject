import java.io.IOException;
import java.util.logging.FileHandler;
import java.util.logging.Logger;
import java.util.logging.SimpleFormatter;

/**
 * Main driver class for the peg game project.
 */
public class PegGame {
    // This table contains the total number of pegs up to a certain row.
    private static final int[] TOTAL_PEGS_TABLE = {
        1, 3, 6, 10, 15, 21, 28, 36, 45, 55
    };

    private Logger logger;

    private int numberOfRows;
    private int maxNumberOfPegs;
    private int numberOfPegs;
    private int currentBest;
    private boolean[] pegBoard;

    /**
     * Creates a PegGame object with the number of rows specified.
     */
    public PegGame(int rows) {
        numberOfRows = rows;
        maxNumberOfPegs = TOTAL_PEGS_TABLE[rows];
        numberOfPegs = maxNumberOfPegs;
        currentBest = 100;
        pegBoard = new boolean[maxNumberOfPegs];
        for (int i = 0 ; i < maxNumberOfPegs ; i++) {
            pegBoard[i] = true;
        }
        createLogger();
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
            SimpleFormatter formatter = new SimpleFormatter();
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
        for (int i = 1 ; i < TOTAL_PEGS_TABLE.length ; i++) {
            if (TOTAL_PEGS_TABLE[i] > pegNumber) {
                return i;
            }
        }
        return -1;
    }

    /**
     * Returns the corresponding column for the given peg number.
     */
    private int getColumn(int pegNumber) {
        return pegNumber - TOTAL_PEGS_TABLE[getRow(pegNumber)];
    }

    /**
     * Returns the corresponding column for the given peg number.
     */
    private int getColumn(int pegNumber, int rowNumber) {
        return pegNumber - TOTAL_PEGS_TABLE[rowNumber];
    }

    /**
     * Returns the peg number for the given row and column.
     */
    private int getPegNumber(int row, int column) {
        return TOTAL_PEGS_TABLE[row] + column;
    }

    private void printBoard() {
        int totalPrinted = 0;
        int currentRow = 0;
        String currentString = "";
        String totalString = "";
        int maxStringLength = (2 * (numberOfRows + 1)) - 1;
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
        logger.info("Print of current board state : \n" + totalString);
    }

    /**
     * Applies the move to the board.
     */
    private void applyMove(Move move) {
        pegBoard[move.originalPosition] = false;
        pegBoard[move.newPosition] = true;
        pegBoard[move.removedPiece] = false;
        numberOfPegs--;
        logger.info("Applied move : " + move + "\n");
    }

    private void reverseMove(Move move) {
        pegBoard[move.originalPosition] = true;
        pegBoard[move.newPosition] = false;
        pegBoard[move.removedPiece] = true;
        numberOfPegs++;
        logger.info("Reversed move : " + move + "\n");
    }

    /**
     * Main driver method for the solver.
     */
    public void solve() {
        for (int i = 0 ; i < 1 ; i++) {
            Move move = new Move(i, i, i);
            applyMove(move);
            recursiveSolve(move);
        }
    }

    public void recursiveSolve(Move previousMove) {
        if (currentBest > numberOfPegs) {
            logger.info("WE DID BETTER!!!\n");
            currentBest = numberOfPegs;
        }
        printBoard();

        // We have to loop through all pegs to see if we can make a move on any
        // of them. For each possible move we will make it and then we will
        // call this again with the new board.
        for (int i = 0 ; i < maxNumberOfPegs ; i++) {
            if (pegBoard[i]) {
                testNeighborMoves(i);
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
     */
    private void testNeighborMoves(int currentPeg) {
        // These are the 6 possible move directions with O being the peg in
        // question.
        //  6 1
        // 5 O 2
        //  4 3
        // We will test these in order.
    }

    // This program will take in one argument, "-s <int>", which will range from
    // 5 to 10 and this corresponds to the number of rows in the game.
    public static void main(String[] args) {
        if (args.length == 0) {
            return;
        }
        int rows = Integer.parseInt(args[0]);
        PegGame pegGame = new PegGame(rows - 1);
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
            return originalPosition + "," + newPosition;
        }
    }
}

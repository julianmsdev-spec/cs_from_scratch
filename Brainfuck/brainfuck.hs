import Data.Char (chr, ord)

-- A list of items to the left of the pointer (in reverse order for easy access)
-- The current item
-- A list of items to the right of the pointer
data Tape = Tape [Int] Int [Int]

emptyTape :: Tape
emptyTape = Tape [] 0 []

main :: IO ()
main = do
  putStrLn "Enter your Brainfuck code:"
  code <- getLine
  let (instructions, _) = parseBF code
  _ <- runSource instructions emptyTape
  putStrLn "\nDone!"

moveRight :: Tape -> Tape
moveRight (Tape left current (r : rs)) = Tape (current : left) r rs
moveRight (Tape left current []) = Tape (current : left) 0 [] -- Handle the end of tape

data Instruction
  = Increment -- +
  | Decrement -- -
  | MoveRight -- >
  | MoveLeft -- <
  | Output -- .
  | Input -- ,
  | Loop [Instruction] -- [ ... ]
  deriving (Show, Eq)

runInstruction :: Instruction -> Tape -> IO Tape
runInstruction Increment (Tape left current right) =
  return (Tape left (current + 1) right)
runInstruction Decrement (Tape l c r) = return $ Tape l (c - 1) r
runInstruction MoveRight (Tape l c (r : rs)) = return $ Tape (c : l) r rs
runInstruction MoveRight (Tape l c []) = return $ Tape (c : l) 0 []
runInstruction MoveLeft (Tape (l : ls) c r) = return $ Tape ls l (c : r)
runInstruction MoveLeft (Tape [] c r) = return $ Tape [] 0 (c : r)
-- The I/O pieces:
runInstruction Output tape@(Tape _ c _) = do
  putChar (chr c)
  return tape
runInstruction Input (Tape l _ r) = do
  c <- getChar
  return $ Tape l (ord c) r
-- The Loop Logic
runInstruction (Loop instrs) tape@(Tape _ current _)
  | current == 0 = return tape
  | otherwise = do
      -- Run the inner instructions once
      nextTape <- runSource instrs tape
      -- Recurse: Run the Loop again with the updated tape
      runInstruction (Loop instrs) nextTape

runSource :: [Instruction] -> Tape -> IO Tape
runSource [] tape = return tape -- Base case: no more code!
runSource (i : is) tape = do
  nextTape <- runInstruction i tape
  runSource is nextTape

parseBF :: String -> ([Instruction], String)
parseBF [] = ([], [])
parseBF (c : cs) = case c of
  '+' -> let (rest, s) = parseBF cs in (Increment : rest, s)
  '-' -> let (rest, s) = parseBF cs in (Decrement : rest, s)
  '>' -> let (rest, s) = parseBF cs in (MoveRight : rest, s)
  '<' -> let (rest, s) = parseBF cs in (MoveLeft : rest, s)
  '.' -> let (rest, s) = parseBF cs in (Output : rest, s)
  ',' -> let (rest, s) = parseBF cs in (Input : rest, s)
  '[' ->
    let (inner, afterLoop) = parseBF cs
        (outer, finalRest) = parseBF afterLoop
     in (Loop inner : outer, finalRest)
  ']' -> ([], cs) -- Stop parsing this level and return the rest
  _ -> parseBF cs -- Skip non-BF characters (comments)

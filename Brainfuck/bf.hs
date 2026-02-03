import Data.Array.IO (IOArray, MArray (newArray))
import System.Environment (getArgs)
import System.Exit (ExitCode (ExitFailure), exitWith)
import System.IO (readFile')

main :: IO ()
main = do
  args <- getArgs
  case args of
    [filePath] -> do
      contents <- readFile' filePath
      putStrLn $ "The file contains: " ++ contents
    [] -> do
      putStrLn "Usage: brainfuck <file_path>"
      exitWith (ExitFailure 1)
    _ -> do
      putStrLn "Error: Only one file argument is expected."
      exitWith (ExitFailure 1)

type Cells = [Int]

type Index = Int

type Instruction = Int

newtype Language = Language (Cells, Index, Instruction)
  deriving (Show)

-- TODO: What is the best why to have a array for the language
zeroArray :: IO (IOArray Int Int)
zeroArray = newArray (0, 30000 - 1) 0

execute :: Cells -> Index -> Instruction -> Language
execute xs y z = Language (xs, y, z)

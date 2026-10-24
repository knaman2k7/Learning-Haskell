module Main where
import Distribution.Simple.Utils (xargs)
import Data.Binary.Get (Decoder(Fail))
import GHC.Exts.Heap (GenClosure(saved_errno))

nextNum :: Integer -> Integer
nextNum x = x + 1

apply :: (Char -> Int) -> Char -> Int
apply f x = f x

f1 :: Char -> Int
f1 'a' = 5
f1 'b' = 6
f1 _ = 7

lamb :: Integer -> Integer
lamb = \x -> x + 5

a :: Integer
a = 5

addThenDouble :: Integer -> Integer
addThenDouble x = (x+3) + 2

atd :: Integer -> Integer
atd x = x + 3 * 2



merge :: [Integer] -> [Integer] -> [Integer]
merge x [] = x
merge [] y = y
merge (x:xs) (y:ys) 
    | x <= y    = x : merge xs (y:ys)
    | otherwise = y : merge (x:xs) ys


countItems :: [Integer] -> Integer
countItems [] = 0
countItems (_:xs) = 1 + countItems xs

countAtLeast :: Integer -> [Integer] -> Integer
countAtLeast _ [] = 0
countAtLeast min (x:xs) 
    | x >= min      = 1 + countAtLeast min xs
    | otherwise     = countAtLeast min xs


checkAdult :: Int -> Bool
checkAdult x = x > 17 && x < 26

triple :: Integer -> Integer
triple x = 3 * x

area :: Integer -> Integer -> Integer
area width height = width * height

(%) :: Int -> Int -> Int
x % y = x `div` y

dos :: Integer -> Integer -> Integer
dos x y = (x+y)*(x-y)

sinc :: Double -> Double
sinc 0 = 1
sinc x = sin x / x

orShort :: Bool -> Bool -> Bool
orShort False False = False
orShort _ _ = True

clampBelowZero :: Integer -> Integer
clampBelowZero x = if x>0 then x else 0

myK :: Int -> Int
myK x
    | x<(-5)  = -3
    | x<5   = 0

safeDivides :: Int -> Int -> Bool
safeDivides 0 _ = False
safeDivides x y = y `mod` x == 0

ticketPrice :: Integer -> Integer
ticketPrice x
    | x < 5     = 0
    | x < 18    = 8
    | x < 65    = 14
    | otherwise = 10

bookingCost :: Integer -> Integer -> Integer
bookingCost age quantity 
    | quantity < 0 = 0
    | otherwise = ticketPrice age * quantity

main :: IO ()
main = print ( 15 `div` 4 )
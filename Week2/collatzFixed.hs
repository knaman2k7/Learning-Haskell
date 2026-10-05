module CollatzFixed where

collatz :: Integer -> Integer
collatz n
    | n == 1 = 1
    | n <= 0 = -1
    | even n = collatz (div n 2)
    | otherwise = collatz ((3 * n) + 1)

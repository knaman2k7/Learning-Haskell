collatz :: Integer -> Integer
collatz n
    | n == 1 = 1
    | n <= 0 = -1
    | even n = collatz (div n 2)
    | otherwise = collatz ((3 * n) + 1)

collatzPrint :: Integer -> IO ()
collatzPrint n
    | n <= 0 = putStrLn "Please enter a positive number"
    | n == 1 = print n
    | otherwise = do
        print n
        if even n
            then collatzPrint (div n 2)
            else collatzPrint (3 * n + 1)

roots :: Double -> Double -> Double -> (Double,Double)
roots a b c = ( (-b + d ) / e, (-b - d ) / e)
    where
        d = sqrt(b*b - 4 * a * c)
        e = 2 * a

main :: IO ()
main = roots 1.0 (-3.0) 2.0

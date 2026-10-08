fib :: Int -> Int
fib 0 = 0
fib 1 = 1
fib n = fib (n-1) + fib(n-2)


collatz :: Integer -> IO ()
collatz 1 = print 1
collatz n 
    | n <= 0 = error "Collatz is undefined for -ve values"
    | even n = do
        print n
        collatz ( n `div` 2 )
    | otherwise = do
        print n
        collatz ( 3*n + 1 )


roots :: Double -> Double -> Double -> (Maybe Double, Maybe Double)
roots a b c
    | dis<0     =(Nothing, Nothing)
    | dis==0    =(Just (-b / (2*a)), Nothing)
    | otherwise =(Just ((-b + sqrt dis) / (2*a)), Just ((-b - sqrt dis) / (2*a)))
    where
        dis = b^2 - 4*a*c

add :: Int -> Int -> Int
add x y = x + y

main :: IO ()
main =  print (add 5 (3))


fibonacci :: [Integer]
fibonacci = 0 : 1 : zipWith (+) fibonacci (tail fibonacci)

main :: IO ()
main = print (take 20 fibonacci)

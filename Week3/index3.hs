import Distribution.Simple.Utils (xargs)
import Data.Binary.Get (Decoder(Fail))
import Control.Monad.Accum (MonadAccum(add))
import Data.ByteString (partition)

reverseList :: [Int] -> [Int]
reverseList [] = []
reverseList (x:xs) = reverseList xs ++ [x]


getTail :: [a] -> a
getTail [x] = x
getTail (x:xs) = getTail xs

hasAtleastTwo :: [a] -> [a]
hasAtleastTwo (_:_:xs) = xs

sumList :: Num a => [a] -> a
sumList [] = 0
sumList (x : xs) = x + sumList xs


prodList :: Num a => [a] -> a
prodList [] = 1
prodList (x:xs) = x * prodList xs


addLists :: [a] -> [a] -> [a]
addLists [] y = y
addLists (x:xs) y = x : addLists xs y


myTake :: Int -> [a] -> [a]
myTake _ [] = []
myTake 0 _ = []
myTake n (x:xs) = x : myTake (n-1) xs

(^*) :: Int -> Int -> Int
(^*) x y = x + y




mapper :: (a->b) -> [a] -> [b]
mapper _ [] = []
mapper f (x:xs) = f x : mapper f xs


f :: Int -> [a] -> Int
f _ [] = 0
f n _ | n <= 0 = 0
f n (x:xs) = 1 + f (n-1) xs



pairProducts :: [Int] -> [Int] -> [Int]
pairProducts = zipWith (*)


ce :: [a] -> Int
ce [] = 0
ce (x:xs) = 1 + ce xs



countElems :: Num a => [a] -> a
countElems = foldr (\_ count -> 1 + count ) 0


countEvens :: [Int] -> Int
countEvens = foldr (\x count -> count + (if even x then 1 else 0) ) 0


mapR :: (a->b) -> [a] -> [b]
mapR f = foldr step []
    where
        step x ys = f x : ys


keepShiftedEven :: [Int] -> [Int]
keepShiftedEven xs = map (+1) ( filter even xs )

kse :: [Int] -> [Int]
kse = foldr step []
    where
        step x rest
            | even x        = (x+1) : rest
            | otherwise     = rest


mysum :: [Int] -> Int
mysum [] = 0
mysum (x:xs) = x + mysum xs

-- myFold (function) (base case) [list]

--myFold :: (a->b->b) -> a -> [b] 


-- 1
sumSquares :: [Int] -> Int
sumSquares = foldr (\x rest -> x^2 + rest) 0


-- 2
longWords :: Int -> [String] -> [String]
longWords n = foldr step []
    where
        step cur rest
            | length cur >= n      = (cur:rest)
            | otherwise            = rest 


-- 3
mapFold :: (a->b) -> [a] -> [b]
mapFold f = foldr (\cur rest -> (f cur : rest) )[]


-- 4
partitionFold :: (a->Bool) -> [a] -> ([a],[a])
partitionFold f = foldr step ([],[])
    where
        step cur (ts,fs)
            | f cur         = ((cur:ts),fs)
            | otherwise     = (ts,(cur:fs))


-- 5
groupRuns :: Eq a => [a] -> [[a]]
groupRuns = foldr step []
    where
        step cur [] = [[cur]]
        step cur ( (x:xs) : rest )
            | cur == x      = ( (cur:x:xs) : rest )
            | otherwise     = ( (cur:[]) : (x:xs) : rest )


main :: IO ()
main = print ( ( sum . map (^2) ) [3,8,14] )
import Data.Char (ord)
import Data.Binary.Get (Decoder(Fail))
import System.Console.Terminfo (Color(Red))


factCheck :: Integer -> Integer
factCheck 0 = 1
factCheck n
    | n < 0 = error "fact: undefined on negative input"
    | otherwise = n * factCheck (n-1)


sumTo :: Int -> Int
sumTo 1 = 1
sumTo n = 
    if n>1 then n + sumTo (n-1)
    else error "No Negative Values"


findRoots :: Float -> Float -> Float -> (Float, Float)
findRoots a b c = ( (-b+dis)/den, (-b-dis)/den )
    where
        dis = sqrt (b^2 - 4*a*c)
        den = 2 * a


rectangleStats :: Double -> Double -> (Double, Double)
rectangleStats width height = (area, perimeter)
    where 
        area = width * height
        perimeter = 2 * (width+height)

myId :: a -> a
myId x = x


myFst :: (a,b) -> b
myFst pair = snd pair


duplicate :: a -> (a,a)
duplicate x = (x,x)


applyTwice :: (a->a) -> a -> a
applyTwice f x = f (f x)


iteratePair :: Int -> (a->a) -> a -> (a,a)
iteratePair n f x
    | n < 0 = error "Negative Values not Allowed!"
    | otherwise = (x, helper n x)
    where
        helper 0 x = x
        helper n x = helper (n-1) (f x)


lowCod :: String -> [Int]
lowCod [] = []
lowCod (x:xs)
    | lb <= uc && uc <= up                      = (uc : lowCod xs)
    | otherwise                                 = lowCod xs
    where
        lb = ord 'a'
        up = ord 'z'
        uc = ord x


apply :: (a->a->a) -> a -> a -> a
apply f x y = f x y


myCurry :: ((a,b) -> c) -> a -> b -> c
myCurry f x y = f (x,y)


plus :: (Int, Int) -> Int
plus (x,y) = x + y


data Day
  = Monday
  | Tuesday
  | Wednesday
  | Thursday
  | Friday
  | Saturday
  | Sunday
  deriving (Eq, Show, Ord)

isWeekend :: Day -> Bool
isWeekend Saturday = True
isWeekend Sunday = True
isWeekend _ = False


data Signal
    = Red
    | Amber
    | Green
    deriving(Eq,Show)

canGo :: Signal -> String
canGo Green = "You can now go"
canGo _ = "Stop right there"



data Natural = Zero | Succ Natural
  deriving (Eq, Show)

toIntegerNatural :: Natural -> Integer
toIntegerNatural Zero = 0
toIntegerNatural (Succ n) = 1 + toIntegerNatural n


addNatural :: Natural -> Natural -> Natural
addNatural x Zero = x
addNatural x (Succ n) = Succ (addNatural x n)


safeDivide :: Int -> Int -> Maybe Int
safeDivide _ 0 = Nothing
safeDivide x y = Just (x `div` y)

myAdd :: Maybe Int -> Int -> Int
myAdd Nothing _ = 0
myAdd (Just x) y = x + y


orZero :: Maybe Int -> Int
orZero Nothing = 0
orZero (Just x) = x


squaresAbove :: Int -> [Int] -> [Int]
squaresAbove n xs = [ x*x | x <- xs, x > n ]


myGcd :: Int -> Int -> Int
myGcd a 0 = a
myGcd a b = myGcd b (a `mod` b)


coprime :: Int -> Int -> Bool
coprime x y = myGcd x y == 1

tripleCoprime :: Int -> Int -> Int -> Bool
tripleCoprime a b h = coprime a b && coprime a h && coprime b h

multipleFilter :: [(Int,Int,Int)] -> [(Int,Int,Int)]
multipleFilter [] = []
multipleFilter ( (a,b,h):xs )
    | tripleCoprime a b h     = (a,b,h): multipleFilter xs
    | otherwise         = multipleFilter xs

pyTriplets :: Int -> [(Int,Int,Int)]
pyTriplets n = multipleFilter [ (b,a,h) | h <- [1..n], a <- [1..h], b <- [1..a], a^2+b^2 == h^2 ]

f :: Int -> [Int]
f x = [ 2*n^2 + 2*n | n <- [1..x] ]

isLowerCase :: Char -> Bool
isLowerCase c = 'a' <= c && c <= 'z'


lowercaseCodes :: String -> [Int]
lowercaseCodes xs = [ ord a | a <- xs, isLowerCase a ]


lcc :: String -> [Int]
lcc [] = []
lcc (x:xs)
    | lb <= x && x <= up        = ord x : lcc xs
    | otherwise                 = lcc xs
    where
        lb = 'a'
        up = 'z'

main :: IO ()
main = print ( lcc "aBz!m" ) 
import Data.Char (ord)


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


main :: IO ()
main = print ( lowCod "ABC123" )
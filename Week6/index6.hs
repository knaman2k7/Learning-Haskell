import Data.Map (Map)
import qualified Data.Map as Map
import Control.Monad (ap, guard)
import GHC.IO.Device (IODevice(dup))
import Data.Time.Format.ISO8601 (yearFormat)
import Control.Monad (forM_, forM)

safediv :: Int -> Int -> Maybe Int
safediv _ 0 = Nothing
safediv x y = Just ( x `div` y)

myfmap :: (a->b) -> Maybe a -> Maybe b
myfmap _ Nothing = Nothing
myfmap f (Just x) = Just (f x)

myJoinMaybe :: Maybe (Maybe a) -> Maybe a
myJoinMaybe (Just x) = x
myJoinMaybe Nothing = Nothing

data Trie k v =
  Trie (Maybe v) (Map k (Trie k v))

lookupT :: Ord a => [a] -> (Trie a v) -> Maybe v
lookupT [] (Trie v _) = v
lookupT (k:ks) (Trie _ kvs) = Map.lookup k kvs >>= lookupT ks

-- mx >>= f = join (fmap f mx)
-- f :: m a -> (a -> m b) -> m b

lookupTwo :: Ord k => k -> k -> Map k (Map k v) -> Maybe v
lookupTwo k1 k2 (map1) = do
    v1 <- Map.lookup k1 map1
    Map.lookup k2 v1

validPairs :: [(Int,Int)]
validPairs = do
    x <- [1..5]
    y <- [1..5]
    guard (6 == x+y)
    pure (x,y)



data Bush a
  = Leaf a
  | Fork (Bush a) (Bush a)
  deriving Show

instance Functor Bush where
  fmap f (Leaf x) = Leaf (f x)
  fmap f (Fork l r) =
    Fork (fmap f l) (fmap f r)

instance Applicative Bush where
  pure = Leaf
  (<*>) = ap

instance Monad Bush where
  Leaf x >>= f = f x
  Fork l r >>= f =
    Fork (l >>= f) (r >>= f)

-- Monad a => m a -> (a -> m b) -> m b

duplicate :: Num a  => Bush a -> Bush a
duplicate (Leaf n) = Leaf n >>= (\n -> Fork (Leaf n) (Leaf (n*2) ))


safeSubtract :: Int -> Int -> Maybe Int
safeSubtract x y
  | x >= y    = Just (x - y)
  | otherwise = Nothing

-- problem: return Just Just n

subTwice :: Int -> Int -> Int -> Maybe Int
subTwice x y z = do
    temp <- safeSubtract x y
    safeSubtract z temp


specialPairs :: Int -> [(Int,Int)]
specialPairs n = do
    y <- [1..n]
    x <- [1..(y-1)]
    guard ( (x+y) `mod` 3 == 0)
    pure (x,y)


expandBush :: Bush Int -> Bush Int
{-
expandBush b =  b >>= (\n -> Fork (Leaf n) (Leaf (n+2)))
    >>= (\x -> Fork (Leaf x) (Leaf (x*3) ))
-}

expandBush b = do
    n <- b
    x <- Fork (Leaf n) (Leaf (n+2))
    Fork (Leaf x) (Leaf (x*2))
    

printLine :: [String] -> IO ()
printLine xs = forM_ xs putStr

announce :: [Int] -> IO ()
announce xs = forM_ xs (\x -> putStrLn ( "Number: " ++ show x))

main :: IO ()
main = announce []
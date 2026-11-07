import qualified Data.Map as M
import Control.Applicative (Alternative(empty))
import qualified Data.Monoid as M
import Data.List (foldl')
import qualified Data.Tree as T


-- 1
sumSquares :: Num a => [a] -> a
sumSquares = foldl (\rest x -> x^2 + rest) 0

-- 2
reverseList :: [a] -> [a]
reverseList = foldl (\rest x -> (x:rest) ) []

-- 3
stats :: [Int] -> (Int, Int, Maybe Int)
stats = foldl' step (0,0,Nothing)
    where 
        step (len,curSum, Nothing ) x = (len+1,curSum+x, Just x) 
        step (len,curSum, Just oldMax ) x = (len+1,curSum+x, Just( max oldMax x ) )

-- 4
runningTotal :: Num a => [a] -> [a]
runningTotal xs = reverse ( foldl' step [] xs )
    where
        step [] x = (x:[])
        step (prev:rest) x = (x+prev:prev:rest)

-- 5

-- a)
sumAndCount :: [Int] -> (Int, Int)
sumAndCount = foldl' step (0, 0)
  where
    step (s, n) x = (
        seq (s+x) (s+x),
        seq (n+1) (n+1)
        )

-- b) because seq only evaluates the top layer, so it will just accumulate as ( sn + .. (s1 + (s + k)), ... )
-- the pair is evaluated, but not the values inside the pair

scores :: M.Map String Int
scores = M.insert "Mira" 14
       (M.insert "Noah" 8 M.empty)



data SalesReport = SalesReport
  { saleCount    :: Int
  , revenuePence :: Integer
  } deriving (Show)


combineReport :: SalesReport -> SalesReport -> SalesReport
combineReport s1 s2 = SalesReport ( saleCount s1 + saleCount s2 ) ( revenuePence s1 + revenuePence s2 )

instance Semigroup SalesReport where
  SalesReport count1 money1 <> SalesReport count2 money2 =
    SalesReport (count1 + count2) (money1 + money2)

-- myFoldl :: (b -> a -> b) -> b -> [a] -> b
-- myFoldr :: (a -> b -> b) -> b -> [a] -> b

reduce :: Monoid a => [a] -> a
reduce = foldr mappend mempty

data Trie k v = Trie (Maybe v) (M.Map k (Trie k v))
  deriving (Show, Eq)

-- Show each key as a branch and stored values beside their nodes.
prettyTrie :: (Show k, Show v) => Trie k v -> String
prettyTrie = T.drawTree . toTree "root"
  where
    toTree label (Trie value children) =
      T.Node (label ++ maybe "" (\v -> " => " ++ show v) value)
        [toTree (show key) child | (key, child) <- M.toAscList children]

exactLookup :: Ord k => [k] -> Trie k v -> Maybe v
exactLookup [] (Trie val _) = val
exactLookup (k:ks) (Trie val curMap) =
  case M.lookup k curMap of
    Nothing -> Nothing
    Just newTrie -> exactLookup ks newTrie

emptyTrie :: Ord k => Trie k v
emptyTrie = Trie Nothing M.empty

insertTrie :: Ord k => [k] -> v -> Trie k v -> Trie k v
insertTrie [] v (Trie _ children) =
  Trie (Just v) children

insertTrie (k:ks) v (Trie mv children) =
  Trie mv children'
  where
    children' =
      case M.lookup k children of
        Nothing ->
          M.insert k (insertTrie ks v emptyTrie) children
        Just child ->
          M.insert k (insertTrie ks v child) children



dict :: Trie Char String
dict =
  insertTrie "he" "a pronoun"
    (insertTrie "hello" "a greeting" emptyTrie)

dictWithHelp :: Trie Char String
dictWithHelp = insertTrie "help" "to assist" dict


fromEntries :: Ord k => [([k],v)] -> Trie k v
fromEntries = foldl (\workingTrie (key,val) -> insertTrie key val workingTrie) emptyTrie

-- reverse "!map"
-- "pam!"


subTrie :: Ord k => [k] -> Trie k v -> Maybe (Trie k v)
subTrie [] lMap = Just lMap
subTrie (k:ks) (Trie _ curMap) = 
  case M.lookup k curMap of
    Nothing -> Nothing
    Just newMap -> subTrie ks newMap


countKeys :: (Ord k, Num v) => [[k]] -> Trie k v
countKeys = foldl step emptyTrie
  where
    step rest cur =
      case exactLookup cur rest of
        Nothing -> insertTrie cur 1 rest
        Just v -> insertTrie cur (v+1) rest


-- list -> map
-- red


data List a
  = Empty
  | Cons a (List a)
  deriving (Eq, Show)

exampleList :: List Int
exampleList =
  Cons 3 (Cons 8 (Cons 14 Empty))


toBuiltIn :: List a -> [a]
toBuiltIn Empty = []
toBuiltIn (Cons val rest) = val : toBuiltIn rest

data Tree a = Tip | Node (Tree a) a (Tree a) deriving (Eq, Show)

foldTree :: b -> (b -> a -> b -> b) -> Tree a -> b
foldTree tip node Tip = tip
foldTree tip node (Node l x r) =
  node
    (foldTree tip node l)
    x
    (foldTree tip node r)


treeHeight :: Tree a -> Int
treeHeight = foldTree 0 (\l _ r -> 1 + max l r)

preorderTrav :: Tree a -> [a]
preorderTrav = foldTree [] (\l x r -> [x] ++ l ++ r)

exampleTree :: Tree Int
exampleTree =
  Node
    (Node Tip 3 Tip)
    8
    (Node (Node Tip 10 Tip) 14 Tip)

sumTree :: Tree Int -> Int
sumTree = foldTree 0 (\l x r -> l + x + r)

mirrorTree :: Tree a -> Tree a
mirrorTree = foldTree Tip (\l x r -> Node r x l)

analyseMapped :: (a->b) -> Tree a -> (Tree b, Int)
analyseMapped f = foldTree (Tip, 0) (\(l, lSize) x (r, rSize) -> (Node l (f x) r, lSize + 1 + rSize))


main :: IO ()
main = print (analyseMapped length (Node (Node Tip "cat" Tip) "hello" Tip))

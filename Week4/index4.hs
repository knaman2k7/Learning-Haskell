

sumShifted :: [Int] -> Int
sumShifted = foldr (\x rest -> (x+2) + rest) 0


data Inch = Inch Int
data Cm = Cm Int

inchVal :: Inch -> Int
inchVal (Inch val) = val

cmVal :: Cm -> Int
cmVal (Cm val) = val

newtype Score = Score Int
    deriving Show

addBonus :: Score -> Score
addBonus (Score val) = Score (val+5)



newtype Total = Total Int
    deriving Show

totalSquares :: [Int] -> Total
totalSquares xs = Total (foldl' step 0 xs)
    where
        step acc cur = cur^2 + acc 






type Degree = Double
type Radians = Double

data DDegree = DDegree Double
data RRadians = RRadians Double
    deriving Show


newtype NDegree = NDegree Double
    deriving Show


toRad :: DDegree -> RRadians
toRad (DDegree val) = RRadians ( (val*pi) / 180 )


data Tree a 
    = Tip 
    | Node (Tree a) a (Tree a)


exampleTree :: Tree Int
exampleTree =
  Node
    (Node Tip 3 Tip)
    8
    (Node Tip 14 Tip)

--        8
--    3         14
--  5  

treeSize :: Tree a -> Int
treeSize Tip = 0
treeSize (Node t1 _ t2) = (treeSize t1) + 1 + (treeSize t2)

maxTreeHeigh :: Tree a -> Int
maxTreeHeigh Tip = 0
maxTreeHeigh (Node t1 _ t2) = 1 + max (maxTreeHeigh t1) (maxTreeHeigh t2)


sumTree :: Num a => Tree a -> a
sumTree Tip = 0
sumTree (Node tl val tr) = sumTree tl + val + sumTree tr



countWhere :: (a->Bool) -> Tree a -> Int
countWhere _ Tip = 0
countWhere f (Node tl val tr)
    | f val     = 1 + rest
    | otherwise = rest
    where
        rest = countWhere f tl + countWhere f tr

myTree = 
    Node
        (
            Node
            (
                Node
                    (
                        Node
                        Tip
                        9
                        Tip
                    )
                2
                Tip
            )
            7
            Tip
        )
    3
    Tip

giveWhere :: (a->Bool) -> Tree a -> [a]
giveWhere _ Tip = []
giveWhere f (Node tl val tr) = 
    giveWhere f tl ++ (if f val then [val] else []) ++ giveWhere f tr


data Ticket = Standard | Reserved Int

-- Standard :: Ticket
-- Reserved :: Int -> Ticket
-- Reserved 12 :: Ticket

-- Either (Maybe Direction) (Bool, Bool)
-- 16 = 4 + 4 + 4 + 4


data Bush a =
    Leaf a | Fork (Bush a) (Bush a)


leaves :: Bush a -> [a]
leaves (Leaf a) = [a]
leaves (Fork b1 b2) = leaves b1 ++ leaves b2


-- in-order
flatten :: Tree a -> [a]
flatten Tip = []
flatten (Node tl val tr) = flatten tl ++ [val] ++ flatten tr


insert :: Ord a => a -> Tree a -> Tree a
insert val Tip = Node Tip val Tip
insert val t@(Node tl x tr)
    | val < x       = Node (insert val tl) x tr
    | val > x       = Node tl x (insert val tr)
    | otherwise     = t

grow :: Ord a => [a] -> Tree a
grow = foldr insert Tip


mergeTrees :: Ord a => Tree a -> Tree a -> Tree a
mergeTrees t1 t2 = grow (flatten t1 ++ flatten t2)

main :: IO ()
main = print ( flatten (mergeTrees (grow [6,2,9]) (grow [5,9,12])) )
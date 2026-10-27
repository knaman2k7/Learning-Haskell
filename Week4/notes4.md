# Week: Fold Fusion, Strictness, Datatypes and Trees

Fold fusion combines list computations; strictness controls when accumulated results are evaluated. The distinction between `data` and `newtype` connects evaluation behaviour to datatype design. Recursive trees extend list processing, while polynomial datatypes explain types through sums, products and powers.

## Fold fusion

Fusion replaces a fold followed by another function with a single fold, potentially avoiding intermediate structures.

```haskell
h . foldr f k = foldr f' k'
```

The required conditions are:

```haskell
h k       = k'
h (f x y) = f' x (h y)
```

Here `(.)` means function composition; primes are simply part of identifiers. Prove fusion by list induction: the first condition handles `[]`, and the second handles `x : xs`.

Example of fold–map fusion:

```haskell
sumSquares :: [Int] -> Int
sumSquares = foldr (\x rest -> x ^ 2 + rest) 0
-- Equivalent to sum . map (^ 2)
```

**Clarification:** these induction arguments concern finite, defined lists. Extending fusion laws to partial or infinite values requires attention to strictness and termination.

## Left folds and strictness

```haskell
foldl :: (b -> a -> b) -> b -> [a] -> b
foldl f k []     = k
foldl f k (x:xs) = foldl f (f k x) xs
```

The accumulator has type `b`; each element has type `a`.

- `foldr f k [x,y,z]` groups as `f x (f y (f z k))`.
- `foldl f k [x,y,z]` groups as `f (f (f k x) y) z`.

`foldl` is tail recursive, but laziness can build an unevaluated accumulator:

```haskell
foldl (+) 0 [1,2,3]
-- Accumulator grows into (((0 + 1) + 2) + 3)
```

Tail recursion alone does **not** guarantee efficient memory use.

### `seq` and weak head normal form

```haskell
seq :: a -> b -> b
```

`seq x y` evaluates `x` to **weak head normal form (WHNF)**, then returns `y`. WHNF exposes the outer constructor or basic value; it does not recursively evaluate fields.

`⊥` (“bottom”) denotes an undefined or nonterminating computation; write `undefined` in runnable examples.

```haskell
seq undefined 42             -- bottom
seq (Just undefined) 42      -- 42
seq (undefined : undefined) 42 -- 42
```

Unlike `seq`, a function that ignores its first argument does not force it:

```haskell
ignore :: a -> b -> b
ignore _ y = y

-- ignore undefined 42 == 42
```

### Strict left fold

`foldl'` forces each new accumulator to WHNF:

```haskell
import Data.List (foldl')

total :: [Int] -> Int
total = foldl' (+) 0
```

Its recursive step is equivalent to:

```haskell
foldlStrict :: (b -> a -> b) -> b -> [a] -> b
foldlStrict _ k [] = k
foldlStrict f k (x:xs) =
  let k' = f k x
  in seq k' (foldlStrict f k' xs)
```

A strict binding `!k' = f k x` requires `{-# LANGUAGE BangPatterns #-}`. WHNF does not deeply force a tuple or other structured accumulator.

## Type synonyms, `data` and `newtype`

```haskell
type Degree = Double
type Radian = Double
```

`type` introduces aliases: these remain interchangeable with `Double`.

Distinct types enforce distinctions:

```haskell
data DDegree = DDegree Double
newtype NRadian = NRadian Double

sinRadians :: NRadian -> Double
sinRadians (NRadian x) = sin x
```

The same spelling can name a **type** and its **constructor**: they occupy different namespaces.

- `data` adds a constructor layer: `DDegree undefined` differs from `undefined`.
- `newtype` creates a distinct type without that runtime layer: `NRadian undefined` is bottom.
- `newtype` requires exactly one constructor with exactly one field.

```haskell
-- seq (DDegree undefined) 42 == 42
-- seq (NRadian undefined) 42 is bottom
```

The lectures also use constructor-signature notation:

```haskell
{-# LANGUAGE GADTs #-}

data Tree a where
  Tip  :: Tree a
  Node :: Tree a -> a -> Tree a -> Tree a
```

## Recursive trees

Using ordinary declaration syntax:

```haskell
data Tree a = Tip | Node (Tree a) a (Tree a)
```

`Tip` is empty; `Node` contains left subtree, value and right subtree.

```haskell
size :: Tree a -> Int
size Tip = 0
size (Node l _ r) = size l + 1 + size r

height :: Tree a -> Int
height Tip = 0
height (Node l _ r) = max (height l) (height r) + 1

sumTree :: Num a => Tree a -> a
sumTree Tip = 0
sumTree (Node l x r) = sumTree l + x + sumTree r

flatten :: Tree a -> [a]
flatten Tip = []
flatten (Node l x r) = flatten l ++ [x] ++ flatten r
```

`=>` introduces a typeclass constraint. Here `height` counts node levels; `flatten` traverses **in order**.

### Ordered trees

Searching one branch requires the binary-search-tree invariant: smaller values on the left, larger values on the right.

```haskell
member :: Ord a => a -> Tree a -> Bool
member _ Tip = False
member x (Node l y r)
  | x < y     = member x l
  | x == y    = True
  | otherwise = member x r

insert :: Ord a => a -> Tree a -> Tree a
insert x Tip = Node Tip x Tip
insert x t@(Node l y r)
  | x < y     = Node (insert x l) y r
  | x > y     = Node l y (insert x r)
  | otherwise = t

grow :: Ord a => [a] -> Tree a
grow = foldr insert Tip

tsort :: Ord a => [a] -> [a]
tsort = flatten . grow
-- tsort [3,1,3,2] == [1,2,3]
```

`t@pattern` binds both the whole value and its parts. The lectures call membership `elem`; `member` avoids clashing with Prelude. Equality uses `==`, not `=`.

This `insert` discards duplicates, so `tsort` does too. Trees are not automatically balanced.

Another shape stores values only at leaves:

```haskell
data Bush a = Leaf a | Fork (Bush a) (Bush a)
```

## Polynomial datatypes

`|a|` means the number of values of type `a`.

| Type | Count |
|---|---:|
| `Bool` | 2 |
| `()` (unit) | 1 |
| `Void` | 0 |
| `Maybe a` | `1 + |a|` |
| `(a,b)` | `|a| × |b|` |
| `Either a b` | `|a| + |b|` |
| `a -> b` | `|b| ^ |a|` |

`Maybe` offers `Nothing` or `Just x`; `Either` offers `Left x` or `Right y`. Import `Void` from `Data.Void` if needed.

For three colours, there are `3^2 = 9` functions `Bool -> Colour`: independently choose an output for each input.

Lists satisfy `|[a]| = 1 + |a| × |[a]|`, expanding into `1 + |a| + |a|^2 + ...`, one term per length.

**Clarification:** these counts ignore bottom and partial values; the list expansion counts finite, fully defined lists.

## Things to remember

- [ ] Fusion needs both base and step conditions.
- [ ] Lazy `foldl` can accumulate deferred work; `foldl'` forces WHNF.
- [ ] WHNF exposes the outside, not every field.
- [ ] `type` aliases; `data` and `newtype` create distinct types.
- [ ] Ordered-tree search requires the ordering invariant.
- [ ] This tree sort removes duplicates.
- [ ] Alternatives add, fields multiply, functions exponentiate.
# Structural Recursion, List Functions and Folds

Lists have a recursive structure, so functions processing them often follow that same structure. Higher-order functions such as `map`, `filter` and `foldr` capture common recursion patterns; fusion laws let us combine successive operations.

## List structure and pattern matching

A list is either empty (`[]`) or an element attached to another list using **cons** (`:`):

```haskell
[3, 8, 14] == 3 : (8 : (14 : []))  -- True
```

`:` associates to the right. In `x : xs`, `x :: a` and `xs :: [a]`. Constructing a cons cell takes constant time.

The lecture’s custom list stores only integers, making it **monomorphic**:

```haskell
{-# LANGUAGE GADTs #-}

data ListInt where
  Empty :: ListInt
  Cons  :: Int -> ListInt -> ListInt
```

Ordinary lists are **polymorphic**: `[a]` works for any element type `a`, but every element of a particular list has the same type.

Patterns distinguish exact lengths from arbitrary tails:

| Pattern | Matches |
|---|---|
| `[]` | Empty list |
| `[x]` | Exactly one element |
| `[x, y]` | Exactly two elements |
| `x : xs` | At least one element |
| `x : y : zs` | At least two elements |

```haskell
isSingle :: [a] -> Bool
isSingle [_] = True
isSingle _   = False
```

`_` is a wildcard: it matches without binding a name. Clauses are tried from top to bottom.

`head`, `tail` and a function matching only `x : y : zs` are **partial**: some inputs cause errors. Prefer exhaustive pattern matching.

## Structural recursion and list operations

For finite lists, recurse on the smaller tail until reaching `[]`:

```haskell
sumList :: Num a => [a] -> a
sumList []       = 0
sumList (x : xs) = x + sumList xs

lengthList :: [a] -> Int
lengthList []       = 0
lengthList (_ : xs) = 1 + lengthList xs
```

`Num a =>` requires a numeric element type. `lengthList` needs no constraint because it never inspects element values.

**Cons versus append:**

```haskell
(:)  :: a -> [a] -> [a]
(++) :: [a] -> [a] -> [a]

-- Defining equations for append:
-- []       ++ ys = ys
-- (x : xs) ++ ys = x : (xs ++ ys)
```

Use `x : xs` for one element; use `xs ++ ys` for two lists. Append traverses its left list.

Other operations:

```haskell
take 2 [3, 8, 14]  -- [3,8]
drop 2 [3, 8, 14]  -- [14]
[3, 8, 14] !! 1    -- 8
```

`take, drop :: Int -> [a] -> [a]`; `(!!) :: [a] -> Int -> a`.

Indexing starts at zero and fails for negative or out-of-range indices. Oversized `take` returns the whole finite list; oversized `drop` returns `[]`.

**Clarification beyond the lecture definitions:** Prelude handles nonpositive counts with `take n xs = []` and `drop n xs = xs`. The notes’ simplified definitions only stop the counter at zero.

## Accumulating parameters

Reversing with `reverse xs ++ [x]` repeatedly traverses intermediate lists, taking quadratic time overall. An **accumulating parameter** builds the result using constant-time cons:

```haskell
reverseFast :: [a] -> [a]
reverseFast xs = go xs []
  where
    go [] acc       = acc
    go (x : xs) acc = go xs (x : acc)
```

This takes linear time. `go` is tail recursive: its recursive call is the whole result. The main improvement here is avoiding repeated append.

## Mapping, filtering and combining lists

```haskell
map     :: (a -> b) -> [a] -> [b]
filter  :: (a -> Bool) -> [a] -> [a]
any     :: (a -> Bool) -> [a] -> Bool
zip     :: [a] -> [b] -> [(a, b)]
zipWith :: (a -> b -> c) -> [a] -> [b] -> [c]
unzip   :: [(a, b)] -> ([a], [b])
concat  :: [[a]] -> [a]
```

- `map` transforms every element; its output type may differ.
- `filter` keeps elements satisfying a **predicate** (`a -> Bool`).
- `any` tests whether at least one element satisfies the predicate; `any p []` is `False`. It can stop at the first success.
- `zip` pairs corresponding elements; `zipWith` combines them using a function. Both stop when either list ends.
- `unzip` separates pairs into two lists.
- `concat` removes one level of list nesting.

```haskell
map (+ 1) [3, 8, 14]           -- [4,9,15]
filter even [3, 8, 14]         -- [8,14]
zipWith (+) [3, 8, 14] [10,20] -- [13,28]
concat [[3,8], [], [14]]       -- [3,8,14]
```

Comprehension equivalents:

```haskell
[f x | x <- xs]      == map f xs
[x | x <- xs, p x]   == filter p xs
```

Tuple construction is a function: `zip = zipWith (,)`. Equivalently, use the anonymous function `\x y -> (x, y)`.

## Right folds

A **right fold** replaces each `:` with a combining function and `[]` with a base value:

```haskell
foldr :: (a -> b -> b) -> b -> [a] -> b
-- foldr f k []       = k
-- foldr f k (x : xs) = f x (foldr f k xs)

-- foldr f k [3,8,14] = f 3 (f 8 (f 14 k))
```

The combining function receives the current element (`a`) and the folded tail (`b`). The result need not be a list.

```haskell
sumList :: Num a => [a] -> a
sumList = foldr (+) 0

flatten :: [[a]] -> [a]
flatten = foldr (++) []

mapList :: (a -> b) -> [a] -> [b]
mapList f = foldr (\x ys -> f x : ys) []
```

Other identities: `product = foldr (*) 1`; `or = foldr (||) False`. Right association does not require evaluating the whole tail first: a lazy combining function can short-circuit.

## Fusion laws

Composition applies the right-hand function first: `(g . f) x = g (f x)`.

```haskell
-- Map fusion:
-- map g . map f = map (g . f)

-- Fold–map fusion:
-- foldr f k . map g = foldr (f . g) k
```

Fusion combines transformations and can avoid intermediate lists and repeated traversals:

```haskell
import Data.Char (chr, ord)

encrypt :: String -> String
encrypt = map (chr . succ . ord)
```

`String = [Char]`; this increments character codes. It fails for the maximum character because the next code is invalid.

The laws can be proved by structural induction: prove the `[]` case, then the `x : xs` case assuming the law for `xs`.

## Things to remember

- [ ] Distinguish `[x]`, `x : xs`, and `xs ++ ys`.
- [ ] Cover empty lists and other invalid inputs explicitly.
- [ ] Recurse on the tail; use accumulators to avoid repeated append.
- [ ] `map` transforms; `filter` selects; `zipWith` combines.
- [ ] `foldr` replaces cons and the empty-list base.
- [ ] Composition runs right to left; fusion combines successive operations.
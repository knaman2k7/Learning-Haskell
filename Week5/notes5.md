# Week 5 — Folds, Monoids, Maps, Tries, Functors and Tree Folds

## Overview

This week introduces several ways to structure and process data:

- **Folds:** Reduce recursive structures to a single result.
- **Monoids:** Describe associative operations with an identity element, allowing folds to be combined predictably.
- **Maps and Tries:** Store key-value pairs, including keys made from lists.
- **Functors:** Apply functions to values inside structures while preserving their structure.
- **Generalised Folds:** Replace explicit recursion over trees with reusable folding functions.

---

## 1. Left and Right Folds

Both folds reduce a list using a combining function and an initial value, but construct differently associated expressions.

```haskell
foldl :: (b -> a -> b) -> b -> [a] -> b
foldr :: (a -> b -> b) -> b -> [a] -> b
```

### Definitions

```haskell
foldl f z []     = z
foldl f z (x:xs) = foldl f (f z x) xs

foldr f z []     = z
foldr f z (x:xs) = f x (foldr f z xs)
```

For `[3,8,14]`:

```haskell
foldl f z [3,8,14] = f (f (f z 3) 8) 14
foldr f z [3,8,14] = f 3 (f 8 (f 14 z))
```

- `foldl`: Left-associated; accumulator is the **first** argument of `f`.
- `foldr`: Right-associated; accumulator is the **second** argument of `f`.
- `foldr` replaces each `(:)` with `f` and `[]` with `z`.
- These expressions describe grouping, **not necessarily evaluation order**, due to laziness.

### Expressing `foldl` using `foldr`

The key idea is to make `foldr` return a function that accepts an accumulator.

```haskell
foldlViaFoldr :: (b -> a -> b) -> b -> [a] -> b
foldlViaFoldr f z xs = foldr g id xs z
  where
    g x k acc = k (f acc x)
```

- `g :: a -> (b -> b) -> b -> b`
- `id :: b -> b` is the identity function.
- The resulting function is finally applied to `z`.

This demonstrates that folds can accumulate **functions**, not just ordinary values.

---

## 2. Monoids

A **monoid** consists of a carrier type, a binary operation and an identity element.

The operation must satisfy:

1. **Associativity:** `(x <> y) <> z = x <> (y <> z)`
2. **Identity:** `mempty <> x = x = x <> mempty`

The standard Haskell interface is:

```haskell
class Semigroup a => Monoid a where
  mempty :: a
```

The associative operation `(<>)` comes from `Semigroup`. `mappend` is another name for it.

### Important examples

| Carrier | Operation | Identity |
|---|---|---|
| Natural numbers | Addition | `0` |
| Natural numbers | Multiplication | `1` |
| Bool | OR | `False` |
| Bool | AND | `True` |
| Bool | XOR | `False` |
| Bool | XNOR (equality) | `True` |
| Sets | Union | Empty set |
| Sets | Intersection | Universal set |
| Sets | Symmetric difference | Empty set |
| Extended numbers | Maximum | `-Infinity` |
| Extended numbers | Minimum | `Infinity` |
| Natural numbers | `lcm` | `1` |
| Natural numbers | `gcd` | `0` |
| Lists | `(++)` | `[]` |
| Endofunctions `a -> a` | `(.)` | `id` |
| Square matrices | Multiplication | Identity matrix |

**Important restrictions:**

- Subtraction, division, `div`, `mod` and exponentiation are not associative.
- An identity must work on **both sides**.
- Commutativity is **not required**: list concatenation and function composition are noncommutative.
- A type can have multiple monoid structures (e.g. addition and multiplication).

### Reducing monoidal values

```haskell
reduce :: Monoid a => [a] -> a
reduce = foldr mappend mempty
```

For finite lists:

```haskell
foldl mappend mempty xs == foldr mappend mempty xs
```

This follows from associativity and identity, without requiring commutativity.

### The Boom hierarchy

Different structures satisfy different algebraic laws:

| Structure | Identity | Associative | Commutative | Idempotent |
|---|---|---|---|---|
| Trees (`fork`) | Yes | No | No | No |
| Lists (`++`) | Yes | Yes | No | No |
| Bags | Yes | Yes | Yes | No |
| Sets (`union`) | Yes | Yes | Yes | Yes |

**Idempotence:** `x <> x = x`.

- Trees preserve shape, ordering and duplicates.
- Lists forget grouping/shape.
- Bags additionally forget ordering.
- Sets additionally forget duplicates.

For the lecture's leaf-valued trees, `fork` treats `Tip` as an identity, unlike the ordinary `Fork` constructor.

---

## 3. Maps and Tries

### Maps

A map associates keys with values, conceptually behaving like:

```haskell
Map k v ~ k -> Maybe v
```

`Nothing` means the key is absent; `Just v` means it is present.

```haskell
import qualified Data.Map as M
```

Main operations:

```haskell
M.empty  :: M.Map k v
M.lookup :: Ord k => k -> M.Map k v -> Maybe v
M.insert :: Ord k => k -> v -> M.Map k v -> M.Map k v
```

Key laws:

- Looking up a key in `empty` gives `Nothing`.
- Inserting a key makes lookup return `Just v`.
- Inserting an existing key **replaces** its previous value.
- Inserting distinct keys commutes; repeated insertion at the same key follows **last insertion wins**.

`Ord k` is required because `Data.Map` orders its keys.

### Tries

Tries efficiently store values associated with **list-shaped keys**, such as strings.

Common prefixes share paths, making prefix searches efficient.

```haskell
data Trie k v =
  Trie (Maybe v) (M.Map k (Trie k v))
```

- `Maybe v`: Value associated with the current prefix.
- `M.Map k (Trie k v)`: Children indexed by the next key element.
- Conceptually: `Trie k v` behaves like `Map [k] v`.

```haskell
emptyTrie :: Trie k v
emptyTrie = Trie Nothing M.empty

single :: v -> Trie k v
single x = Trie (Just x) M.empty
```

`single` stores a value at the **empty key** `[]`.

Lookup:

```haskell
lookupTrie :: Ord k => [k] -> Trie k v -> Maybe v
lookupTrie [] (Trie mv _) = mv
lookupTrie (k:ks) (Trie _ children) =
  case M.lookup k children of
    Nothing -> Nothing
    Just t  -> lookupTrie ks t
```

Insertion follows the same path, creating missing subtries from `emptyTrie` and replacing the terminal `Maybe v` with `Just v`.

**Important:** A prefix may exist as a path without being a stored key. For example, storing `"hello"` does not automatically store `"hel"`.

Uses of `Trie Char v`:

- `v = ()`: Word membership.
- `v = Int`: Frequency counts.
- `v = String`: Dictionary definitions.
- `v = [Verse]`: Concordance (word locations).

`Just ()` represents membership without storing additional information.

---

## 4. Functors

A **Functor** is a type constructor that supports mapping a function over values inside a structure.

```haskell
class Functor f where
  fmap :: (a -> b) -> f a -> f b
```

Here `f` is a type constructor, not an ordinary type.

Examples:

- `[]` takes `a` to `[a]`.
- `Maybe` takes `a` to `Maybe a`.
- `Tree` takes `a` to `Tree a`.

### Examples

```haskell
fmap (+2) [3,8,14]  -- [5,10,16]

fmap (*3) (Just 8)  -- Just 24
fmap (*3) Nothing   -- Nothing
```

For lists, `fmap = map`.

The structure remains intact; only contained values are transformed.

### Functor laws

Every lawful functor satisfies:

```haskell
fmap id = id

fmap g . fmap f = fmap (g . f)
```

- **Identity:** Mapping `id` changes nothing.
- **Composition:** Mapping twice is equivalent to mapping the composed function once.

These laws allow transformations to be simplified and combined.

### Other functors

**Tree:** Recursively maps values while preserving branching.

**Rose tree:** Each node stores a value and a list of children.

```haskell
data Rose a = Rose a [Rose a]
```

Mapping over a rose tree transforms the root and recursively maps over its children.

**Function functor:** For a fixed input type `r`, functions `r -> a` form a functor in their output type:

```haskell
fmap = (.)
```

**Important distinction:** Not every type constructor is a functor.

- `Arrow a = Arrow (a -> a)` is not generally a functor in `a`.
- `Boolset a = Boolset (a -> Bool)` is contravariant in `a`, not covariant.

---

## 5. Generalised Folds over Trees

Folds replace recursive constructors with combining functions.

### Custom lists

```haskell
data List a = Empty | Cons a (List a)

foldCustom :: (a -> b -> b) -> b -> List a -> b
foldCustom _ z Empty       = z
foldCustom f z (Cons x xs) = f x (foldCustom f z xs)
```

This mirrors `foldr` for ordinary lists.

### Binary trees

Lecture 9 uses node-valued binary trees:

```haskell
data Tree a = Tip | Node (Tree a) a (Tree a)
```

A tree fold needs:

- A value for `Tip`.
- A function combining the folded left subtree, the node's value and the folded right subtree.

```haskell
foldTree :: b -> (b -> a -> b -> b) -> Tree a -> b
foldTree tip _ Tip = tip
foldTree tip node (Node l x r) =
  node (foldTree tip node l)
       x
       (foldTree tip node r)
```

### Tree size

```haskell
size :: Tree a -> Int
size = foldTree 0 (\l _ r -> l + 1 + r)
```

Counts the number of `Node` constructors.

### Flattening a tree

```haskell
flatten :: Tree a -> [a]
flatten = foldTree [] (\ls x rs -> ls ++ [x] ++ rs)
```

Produces an **in-order traversal**: left subtree, current value, right subtree.

### Mapping over a tree using a fold

```haskell
mapTree :: (a -> b) -> Tree a -> Tree b
mapTree f = foldTree Tip (\l x r -> Node l (f x) r)
```

Rebuilds the same tree shape, transforming every node value.

**Important:** In `foldTree`, the combining function receives already-folded subtree results of type `b`, not the original subtrees of type `Tree a`.

---

## Things to remember

- [ ] `foldl` associates left; `foldr` associates right. Neither directly specifies evaluation order.
- [ ] Folds can return functions, allowing `foldl` to be expressed using `foldr`.
- [ ] Monoids require associativity and a two-sided identity, not commutativity.
- [ ] Trees, lists, bags and sets differ in their algebraic laws.
- [ ] Maps associate keys with values; tries specialise this idea to list-shaped keys.
- [ ] In a trie, an existing prefix does not necessarily have a stored value.
- [ ] `Functor` operates on type constructors and must satisfy identity and composition laws.
- [ ] `fmap` preserves structure while transforming stored values.
- [ ] `foldTree` generalises recursion by replacing `Tip` and `Node` with supplied operations.
- [ ] Lecture 8's leaf-valued `Tree` and Lecture 9's node-valued `Tree` are different datatypes, so their folds and constructors differ.
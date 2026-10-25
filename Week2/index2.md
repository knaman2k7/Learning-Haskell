# Recursion, Evaluation, Polymorphism, Lambdas and Datatypes

Recursion defines computations in terms of themselves; evaluation determines how those computations run. Polymorphism makes functions reusable across types. Lambdas and currying treat functions as values, while datatypes, lists and strings provide ways to structure information.

## 1. Recursion and evaluation

A **recursive function** uses itself in its definition. A terminating computation needs a base case and recursive steps that eventually reach it.

```haskell
fact :: Integer -> Integer
fact 0 = 1
fact n
  | n < 0     = error "fact: negative input"
  | otherwise = n * fact (n - 1)
```

Without the negative-input guard, negative arguments recurse forever. `error` reports failure; it does **not** make the function total.

Evaluation strategies:

- **Applicative evaluation:** evaluate arguments before applying the function; innermost first.
- **Normal evaluation:** apply the function first; evaluate arguments only when needed; outermost first.

```haskell
two :: a -> Integer
two _ = 2

infinity :: Integer
infinity = infinity + 1

-- two infinity returns 2 under normal evaluation.
-- Applicative evaluation never finishes evaluating its argument.
```

If both strategies terminate, they agree on the value (**Church–Rosser**). There is no general algorithm deciding whether every arbitrary program terminates (**Halting problem**).

**Clarification:** Haskell uses lazy evaluation: demanded computations are evaluated, and shared results can be reused. Normal-order substitution alone can duplicate work.

A recursive call is in **tail position** when its result is returned directly:

```haskell
collatz :: Integer -> Integer
collatz 1 = 1
collatz n
  | n <= 0    = error "collatz: non-positive input"
  | even n    = collatz (n `div` 2)
  | otherwise = collatz (3 * n + 1)
```

Here no operation remains after the recursive call. In `fact`, multiplication remains. Tail calls allow optimisation; **clarification:** laziness means tail recursion alone does not guarantee constant memory.

## 2. Tuples and local bindings

Tuples group a fixed number of values, potentially with different types. Extract components using patterns:

```haskell
dist :: (Double, Double) -> (Double, Double) -> Double
dist (x0, y0) (x1, y1) = sqrt (dx * dx + dy * dy)
  where
    dx = x0 - x1
    dy = y0 - y1
```

`where` introduces local bindings, useful for naming and sharing computations.

- `(a, b)` can describe a tuple value or tuple type, depending on context.
- `((a, b), c)`, `(a, (b, c))` and `(a, b, c)` have different structures.
- `()` is the unit value and its type.
- `(42)` is simply `42`, not a one-component tuple.

## 3. Polymorphism and higher-order functions

**Parametric polymorphism** uses type variables to work uniformly across types:

```haskell
id    :: a -> a
const :: a -> b -> a
fst   :: (a, b) -> a
snd   :: (a, b) -> b
```

Repeated variables require the same type; different variables may represent different types, but need not. Haskell normally infers their instantiations.

The notes’ `forall a. a -> a` explicitly means “for every type `a`”. Ordinary signatures omit `forall`. Explicit `forall` needs `ExplicitForAll`; visible applications such as `id @Int 5` need `TypeApplications`.

**Higher-order functions** accept or return functions:

```haskell
($) :: (a -> b) -> a -> b
(.) :: (b -> c) -> (a -> b) -> a -> c

-- f $ x       means f x
-- (g . f) x   means g (f x)
-- round $ sqrt $ 9 + 7  == 4
```

`$` has the lowest precedence and associates right. Composition produces a function; `$` applies one.

Type inference matches input/output requirements: in `g (f x)`, the output type of `f` must equal the input type of `g`.

`undefined :: a` can inhabit any expected type, but fails when demanded; it is useful only as a temporary placeholder.

## 4. Lambdas, currying and partial application

A **lambda abstraction** writes a function without naming it:

```haskell
add :: Int -> Int -> Int
add = \x y -> x + y

plus :: (Int, Int) -> Int
plus (x, y) = x + y
```

`\` starts the lambda; `->` separates parameters from the body. `\x y -> ...` abbreviates nested lambdas.

- Function application associates left: `add 3 8 = (add 3) 8`.
- Type arrows associate right: `Int -> Int -> Int` means `Int -> (Int -> Int)`.
- **Partial application:** `add 3 :: Int -> Int` awaits another argument.
- `plus` instead accepts one pair.

```haskell
curry   :: ((a, b) -> c) -> a -> b -> c
uncurry :: (a -> b -> c) -> (a, b) -> c

-- curry plus 3 8 == 11
-- uncurry add (3, 8) == 11
```

They convert between the two forms and are inverses.

## 5. Datatypes, type classes and synonyms

`data` introduces a new type and constructors, which also serve as patterns:

```haskell
data Day = Monday | Tuesday | Wednesday | Thursday | Friday
         | Saturday | Sunday
  deriving (Eq, Show)

weekend :: Day -> Bool
weekend Saturday = True
weekend Sunday   = True
weekend _        = False

data Natural = Zero | Succ Natural
```

`Succ (Succ Zero)` represents two. `deriving (Eq, Show)` generates equality and printable representations.

The notes also use constructor signatures:

```haskell
{-# LANGUAGE GADTs #-}
data Switch where
  On  :: Switch
  Off :: Switch
```

`Maybe a` represents absence or a value: `Nothing :: Maybe a`, `Just :: a -> Maybe a`. Handle both cases when extracting a value.

**Constrained/ad-hoc polymorphism** requires type-class operations:

```haskell
double :: Num a => a -> a
double x = x + x
```

`=>` separates constraints from the type; it is different from the function arrow `->`.

- `Num`: arithmetic, `negate`, `abs`, `signum`, `fromInteger`.
- `Eq`: `==`, `/=`.
- `Ord`: ordering, `min`, `max`; requires `Eq`.
- `Show` / `Read`: textual representation / parsing.

`class` declares an interface; `instance` supplies its implementation for a type. Numeric literals use `fromInteger`; `42 :: Num a => a`. Inspect classes with GHCi’s `:i Num`.

**Clarification:** the notes’ `Num Natural` code is a partial illustration, not a complete implementation.

```haskell
type Point a = (a, a)
```

A type synonym provides another name, not a distinct type. Likewise, `type Nat = Word` retains bounded machine arithmetic.

## 6. Lists, characters and strings

Lists contain elements of one type; length may vary.

```haskell
-- [3, 8, 14] == 3 : 8 : 14 : []
-- (:) :: a -> [a] -> [a]
```

`[]` is empty; `x : xs` attaches an element to a list. `:` associates right. Unlike tuples, lists cannot mix unrelated element types.

Comprehensions combine generators (`<-`) and Boolean filters:

```haskell
pythagoreans :: [(Integer, Integer, Integer)]
pythagoreans =
  [(a,b,h) | h <- [1..], b <- [1..h], a <- [1..b],
             a^2 + b^2 == h^2]
```

Generators are nested left to right. `[1..h]` includes `h`; `[1..]` is infinite and can be consumed lazily.

`Char` uses single quotes; `String` is `[Char]` and uses double quotes. `'a'` and `"a"` have different types. `""` is valid; an empty character literal is not.

```haskell
import Data.Char (ord, chr)

-- ord :: Char -> Int
-- chr :: Int -> Char
-- chr (ord 'A') == 'A'
-- '\n' is one newline character
```

Characters compare by code point; direct character arithmetic is unsupported. `chr` requires a code between `0` and `0x10FFFF`. Strings compare lexicographically: prefixes come first, and `"Zebra" < "apple"` is `True`.

## Things to remember

- [ ] Check base cases, input domains and pattern coverage.
- [ ] Distinguish tail calls from calls with work remaining.
- [ ] Read application leftward grouping and arrows rightward grouping.
- [ ] Distinguish `$`, `.`, `->` and `=>`.
- [ ] Distinguish `data`, `class`, `instance` and `type`.
- [ ] Keep tuple structure, list element types and `Char`/`String` separate.
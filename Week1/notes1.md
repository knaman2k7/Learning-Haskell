# Haskell revision — Lectures 0–1

These lectures introduce functional programming: expressing computations through functions and reasoning using equations. The foundations explain functions, evaluation and types; the practical material shows how to define, load and combine functions, then choose behaviour using patterns, conditionals and guards.

## 1. Functions and computation

- A mathematical function maps each input in its **domain** to exactly one output in its **codomain**. Its **graph** is the set of input/output pairs.
- **Extensional** properties concern the outputs produced; **intensional** properties concern the procedure used. Different algorithms can compute the same function.
- **Syntax** is the written arrangement of symbols; **semantics** is its meaning.
- **Equational reasoning** replaces expressions with equal expressions, including substituting arguments into function bodies.

### Lambda calculus and recursion

Lambda calculus consists of variables, function abstractions and applications. Haskell writes mathematical `λx. x + 1` as:

```haskell
successor :: Integer -> Integer
successor = \x -> x + 1

-- (\x -> x + 1) 41 evaluates to 42
```

`\` introduces parameters; `->` separates them from the body. A lambda creates a function without naming it.

**Church numerals** encode a natural number by applying a function that many times:

```haskell
churchTwo :: (a -> a) -> a -> a
churchTwo s z = s (s z)

-- churchTwo (+1) 0 == 2
```

Here `a` is a type variable; both occurrences of the same variable denote the same type.

- Untyped lambda calculus and Turing machines express all effectively computable functions: they are **Turing complete**.
- Some mathematical functions are not computable, such as a general halting decider.
- Simply-typed lambda calculus rules out self-application such as `\x -> x x` and guarantees termination (**strong normalisation**), but is not Turing complete.
- A **fixpoint operator** enables general recursion and restores computational expressiveness, while allowing nontermination. Haskell supports recursive definitions; type correctness does not guarantee termination.

## 2. GHCi, modules and declarations

**GHC** compiles programs; **GHCi** evaluates expressions interactively. The notes use the GHC2024 edition.

| Command | Purpose |
|---|---|
| `:l Main.hs` | Load a source file |
| `:r` | Reload after editing |
| `:type expression` | Inspect its type |
| `:info (+)` | Inspect a name, including operator fixity |
| `:{` … `:}` | Enter multiple lines |
| `:?` / `:q` | Help / quit |

GHCi binds the latest expression result to `it`. Session declarations are temporary.

```haskell
module Main where

import Prelude hiding (succ)

succ :: Integer -> Integer
succ x = x + 1

main :: IO ()
main = print (succ 41)
```

Save as `Main.hs`; `ghc Main.hs` compiles it, then `./Main` prints `42`. `IO ()` describes an action returning no meaningful result.

**Prelude** is imported automatically. Avoid conflicting names by renaming, qualifying (`Main.succ`, `Prelude.succ`), or using `hiding`. Imports follow the module header and precede declarations.

```haskell
hiker :: Integer  -- signature: “hiker has type Integer”
hiker = 42       -- defining equation
```

`=` defines; `==` compares. Bindings are immutable; evaluation happens when demanded, and a named expression’s result can be shared. Signatures document intent and expose mistakes; Haskell can often infer them.

## 3. Expressions and numerical types

Application binds tighter than arithmetic: `double 3 + 1` means `(double 3) + 1`. Use `double (3 + 1)` to pass the sum. Multiplication binds tighter than addition.

Operators include `+`, `-`, `*`, `/`, `^`; `/` is fractional division, while `div` performs integral division.

| Type | Representation |
|---|---|
| `Int` | Bounded signed integer |
| `Word` | Bounded unsigned integer |
| `Integer` | Arbitrary-precision integer |
| `Float` / `Double` | Approximate numbers; about 7 / 16 significant digits |
| `Rational` | Exact fraction of integers |

**Clarification:** the notes assume 64-bit `Int`/`Word`; their width is platform-dependent. Bounded arithmetic can overflow. `Integer` avoids a fixed numerical bound.

```haskell
0.3 + 0.6 :: Double    -- 0.8999999999999999
0.3 + 0.6 :: Rational  -- 9 % 10
```

`::` annotates a type; it does not convert an existing value. `(1 :: Int) + (1 :: Integer)` fails type checking: numerical types are not converted automatically.

**Clarification:** unconstrained numerical expressions in ordinary GHCi use commonly defaulted types `Integer` and `Double`; surrounding context can determine another type.

## 4. Defining and combining functions

```haskell
double :: Int -> Int
double x = x + x

squareOfDouble :: Int -> Int
squareOfDouble x = square (double x)
  where
    square y = y * y

area :: Int -> Int -> Int
area width height = width * height
```

`where` introduces local definitions. `area 3 8` returns `24`; arguments are separated by spaces, not commas. Arrows group rightward: `Int -> (Int -> Int)`.

Ordinary names begin lowercase and may contain digits, underscores and apostrophes.

```haskell
divides :: Int -> Int -> Bool
divides d n = n `mod` d == 0
```

Backticks make a two-argument named function infix; parentheses make an operator prefix: `(+) 3 8`. Here `d` must be nonzero.

Lecture 0 also previews recursive list processing:

- `[Integer]`: list type; `[]`: empty list.
- `x : xs`: head and remaining list in a pattern; constructs a list in an expression.
- Recursion needs terminating cases and progress towards them.

**Correction to the notes:** their introductory `sort` omits base cases. Their constant function `two` should be `two _ = 2`, not `two = 2` with type `Int -> Int`.

## 5. Patterns, Booleans and branching

```haskell
dirac :: Integer -> Integer
dirac 0 = 1
dirac _ = 0
```

Clauses are tried top to bottom; first match wins. Variable patterns match anything and bind a name. `_` is an actual **wildcard pattern**, not merely a naming convention: it matches without binding.

Booleans have type `Bool`: `True`, `False`. Comparisons use `==`, `/=`, `<`, `<=`, `>`, `>=`; combine with `&&`, `||`, `not`. Booleans are not numbers. `&&` and `||` short-circuit.

```haskell
magnitude :: Integer -> Integer
magnitude x = if x < 0 then negate x else x

sign :: Int -> Int
sign 0 = 0
sign x
  | x < 0     = -1
  | otherwise = 1
```

`if` requires both branches, with matching types. Guards test Boolean conditions in order; `otherwise` means `True`. Patterns and guards can be combined. Uncovered inputs can cause runtime failure.

## Things to remember

- [ ] `::` gives a type; `=` defines; `==` compares.
- [ ] Application binds tightly; parenthesise compound arguments.
- [ ] `_` matches without creating a usable variable.
- [ ] Clause and guard order matters.
- [ ] Numerical representation affects overflow and precision.
- [ ] Type checking does not guarantee termination or complete patterns.
- [ ] Save definitions in `.hs` files and reload with `:r`.
# Week 6 — Monads

## Overview

Monads extend `Functor` and `Applicative` by allowing us to **sequence computations whose results may involve effects**.

- `Functor`: apply a function to values inside a context (`fmap`).
- `Applicative`: combine independent effectful computations.
- `Monad`: sequence computations where later computations can depend on earlier results.

Examples of effects:
- `Maybe`: failure propagation.
- `[]`: multiple possible results.
- `IO`: interaction with the outside world.
- `State s`: maintaining and updating state.
- `Except err`: structured error handling.

---

## 1. From Functors to Monads

### Functor

```haskell
fmap :: Functor f => (a -> b) -> f a -> f b
```

Applies a function inside a structure without changing its shape.

```haskell
fmap (*3) (Just 8)  -- Just 24
fmap (+2) [3,8,14]  -- [5,10,16]
```

**Functor laws:**

```haskell
fmap id = id
fmap (f . g) = fmap f . fmap g
```

### Why do we need Monads?

Consider:

```haskell
safeDiv :: Int -> Int -> Maybe Int
safeDiv _ 0 = Nothing
safeDiv x y = Just (div x y)
```

Using `fmap` with a function that already returns `Maybe` creates nesting:

```haskell
fmap (safeDiv 12) (safeDiv 6 2)
-- Just (Just 4)
```

We want `Just 4`, not `Just (Just 4)`.

### `join` — Flattening contexts

```haskell
join :: Monad m => m (m a) -> m a

join (Just (Just 8))  -- Just 8
join (Just Nothing)   -- Nothing
join [[3,8],[14]]     -- [3,8,14]
```

`join` generalises `concat` from lists to monads.

### Bind `(>>=)`

```haskell
(>>=) :: Monad m => m a -> (a -> m b) -> m b
```

Combines `fmap` and `join`:

```haskell
mx >>= f = join (fmap f mx)
```

Example:

```haskell
safeDiv 6 2 >>= (\n -> safeDiv 12 n)
-- Just 4
```

- Extracts the successful result `3`.
- Passes it into `safeDiv 12`.
- Automatically propagates `Nothing` if a computation fails.

For lists:

```haskell
[3,8] >>= (\x -> [x, x+1])
-- [3,4,8,9]
```

List bind is `concatMap`.

### `pure`, `return` and `liftM`

```haskell
pure   :: Applicative m => a -> m a
return :: Monad m => a -> m a

liftM :: Monad m => (a -> b) -> m a -> m b
```

`pure` and `return` wrap a value in a monadic context:

```haskell
pure 8 :: Maybe Int  -- Just 8
return 8 :: [Int]    -- [8]
```

`liftM` implements `fmap` using monadic operations:

```haskell
liftM f mx = mx >>= (pure . f)
```

**Clarification:** Modern Haskell has `Functor => Applicative => Monad`. `pure` belongs to `Applicative`; `return` is its monadic equivalent.

### Monad Laws

```haskell
return x >>= f = f x
mx >>= return = mx
(mx >>= f) >>= g = mx >>= (\x -> f x >>= g)
```

These express left identity, right identity and associativity.

Monadic function composition:

```haskell
(>=>) :: Monad m => (a -> m b) -> (b -> m c) -> a -> m c
```

```haskell
return >=> f = f
f >=> return = f
(f >=> g) >=> h = f >=> (g >=> h)
```

---

## 2. `do` Notation

`do` notation is readable syntax for sequencing monadic operations using `(>>=)`.

```haskell
safeDiv 6 2 >>= (\n -> safeDiv 12 n)
```

Equivalent:

```haskell
do n <- safeDiv 6 2
   safeDiv 12 n
```

**Important distinctions:**

- `x <- mx`: runs a monadic computation and binds its result to `x`.
- `let x = expression`: defines a pure value without running a monadic operation.
- `return x`: wraps a value; does **not** terminate a function like Java's `return`.
- `mx >> my`: sequences operations, discarding the result of `mx`.
- The final expression determines the result of the entire `do` block.

### Lists and comprehensions

```haskell
cart :: [a] -> [b] -> [(a,b)]
cart xs ys = do
  x <- xs
  y <- ys
  return (x,y)
```

Equivalent:

```haskell
cart xs ys = [(x,y) | x <- xs, y <- ys]
```

Each `x` is combined with every `y`.

### `guard`

```haskell
guard :: Alternative f => Bool -> f ()
```

Used for filtering computations that support failure:

```haskell
import Control.Monad

pairs = do
  x <- [1..4]
  y <- [1..4]
  guard (x < y)
  return (x,y)
```

For lists, `guard False` produces `[]`; for `Maybe`, it produces `Nothing`.

Not all monads support `guard`.

### Custom Monad Example: Bush

```haskell
data Bush a = Leaf a | Fork (Bush a) (Bush a)
```

The lecture defines:

```haskell
return x = Leaf x

Leaf x >>= f = f x
Fork l r >>= f = Fork (l >>= f) (r >>= f)
```

Bind replaces every `Leaf` value with a new `Bush`, preserving the existing `Fork` structure.

---

## 3. IO — Interaction with the Outside World

`IO a` represents an action that interacts with the outside world and produces a result of type `a`.

### Common operations

```haskell
putStrLn  :: String -> IO ()
print     :: Show a => a -> IO ()
writeFile :: FilePath -> String -> IO ()

getChar   :: IO Char
getLine   :: IO String
readFile  :: FilePath -> IO String
```

`()` is the **unit type**, containing only the value `()`. It is used when there is no meaningful return value.

### Example

```haskell
greet :: IO ()
greet = do
  putStrLn "What's your name?"
  name <- getLine
  putStrLn ("Hello " ++ name)
```

`main :: IO ()` is the entry point for executing an IO program.

### Reading values

```haskell
read :: Read a => String -> a

readLine :: Read a => IO a
readLine = fmap read getLine
```

Example:

```haskell
age <- (readLine :: IO Int)
```

`read` can crash on malformed input; `readMaybe` provides a safer alternative.

### Repeated actions

```haskell
forM_ :: Monad m => [a] -> (a -> m ()) -> m ()
```

```haskell
forM_ ["Hi", "Hello", "Bye"] putStrLn
```

Executes `putStrLn` three times, in order.

The `_` indicates that results are discarded.

---

## 4. State — Managing a Variable

`State s a` represents a computation that maintains state of type `s` and returns a result of type `a`.

Conceptually:

```haskell
s -> (a, s)
```

The state is threaded automatically between operations.

```haskell
import Control.Monad.State
```

### Core operations

```haskell
get    :: State s s
put    :: s -> State s ()
modify :: (s -> s) -> State s ()
```

- `get`: retrieves the current state.
- `put`: replaces the state.
- `modify`: applies a function to update it.

### Running State computations

```haskell
runState  :: State s a -> s -> (a,s)
evalState :: State s a -> s -> a
execState :: State s a -> s -> s
```

```haskell
example :: State Int Int
example = do
  x <- get
  modify (+5)
  return (x*2)
```

```haskell
runState example 8   -- (16,13)
evalState example 8  -- 16
execState example 8  -- 13
```

**State laws:**

```haskell
get >> get      = get
get >>= put     = return ()
put x >> get    = put x >> return x
put x >> put y  = put y
```

These describe redundant reads and writes.

### Random Numbers Using State

The lecture defines:

```haskell
type Seed = Int
type Rand a = State Seed a

runRandom :: Rand a -> Seed -> a
runRandom = evalState
```

A pseudorandom generator:

1. Gets the current seed using `get`.
2. Computes a new seed.
3. Stores it using `put`.
4. Returns a number derived from that seed.

**Same initial seed = same sequence of results.** This is deterministic and reproducible.

### Useful Monad Functions

```haskell
replicateM :: Monad m => Int -> m a -> m [a]

liftM2 :: Monad m => (a -> b -> c) -> m a -> m b -> m c
```

- `replicateM`: executes an action repeatedly and collects its results.
- `liftM2`: combines two monadic computations using a binary function.

```haskell
rollDice n = replicateM n rollDie
```

Unlike `replicate`, `replicateM` repeats the *action*, so results may differ.

```haskell
liftM2 (,) [3,8] [14,20]
-- [(3,14),(3,20),(8,14),(8,20)]
```

### Applications

- `randomR (lo,hi)`: generate a value in a range.
- `pick`: choose a random list element.
- `shuffle`: assign random keys, zip, sort using `sortOn fst`, then extract values.
- `montePi`: generate random points in `[0,1]²`, count those satisfying `x*x + y*y <= 1`, and estimate `4 * hits / darts`.
- **Parsing:** use `State String` to track unconsumed input, avoiding manual handling of `(result, remainingInput)`.

**Caveats:** `pick` requires a nonempty list; `montePi` requires a positive dart count. The lecture's random-key sorting method can produce ties and is not guaranteed to be an unbiased shuffle.

---

## 5. Except — Structured Error Handling

`Maybe` handles failure but cannot explain *why* something failed.

`Except err` supports errors with meaningful information.

```haskell
import Control.Monad.Except
```

### Core operations

```haskell
throwError :: e -> Except e a

catchError :: Except e a -> (e -> Except e a) -> Except e a

runExcept :: Except e a -> Either e a
```

- `throwError`: raises an error.
- `catchError`: handles an error using a recovery function.
- `runExcept`: produces `Left error` or `Right result`.

### Example

```haskell
data Error = DivByZero | UnknownVariable String
  deriving Show

safeDivide :: Int -> Int -> Except Error Int
safeDivide x y = do
  when (y == 0) (throwError DivByZero)
  return (div x y)
```

```haskell
runExcept (safeDivide 12 3)  -- Right 4
runExcept (safeDivide 12 0)  -- Left DivByZero
```

### `when`

```haskell
when :: Applicative f => Bool -> f () -> f ()
```

Executes an action only when the condition is `True`.

### Why Except is useful

The lecture evaluates expressions using an environment:

```haskell
data Expr
  = Val Int
  | Var String
  | Add Expr Expr
  | Mul Expr Expr
  | Div Expr Expr
```

With `Maybe`, missing variables, overflow and division by zero all produce `Nothing`.

With `Except Error`, these become distinguishable errors:

```haskell
OutOfScope String
OverflowedAdd
DivByZero
```

Changing from `Maybe` to `Except` requires relatively few changes when computations already use `do` notation and monadic operations.

**Program to the interface:** write code using general monadic operations rather than depending unnecessarily on a particular monad's implementation.

### Limitation: Sequential Failure

Consider evaluating:

```haskell
Add (Var "x") (Var "y")
```

If both variables are missing, `Except` reports only the **first encountered error**.

The second computation is skipped after the first failure.

This motivates using `Applicative` techniques when we want to accumulate independent errors rather than stop immediately.

---

## Things to Remember

- [ ] `Functor` maps; `Applicative` combines; `Monad` sequences dependent computations.
- [ ] `join` flattens nested contexts; `(>>=)` combines `fmap` and `join`.
- [ ] `pure`/`return` wrap values; `return` does not exit a function.
- [ ] `x <- mx` extracts a result within `do`; `let x = ...` defines a pure value.
- [ ] `>>=` sequences with a result; `>>` discards the first result.
- [ ] `Maybe` propagates failure; lists represent multiple possibilities.
- [ ] `IO` handles external interactions and is sequenced using `do`.
- [ ] `State s` provides `get`, `put`, `modify` and three ways to run computations.
- [ ] `replicateM` repeats an action; `liftM2` combines two monadic results.
- [ ] `Except` provides meaningful errors but normally stops at the first failure.
- [ ] Prefer reusable monadic operations and programming to the interface.
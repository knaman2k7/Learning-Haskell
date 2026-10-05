# Types of Evaluation

## Applicative Evaluation

in f(x), evaluate x first then f(x)

square (1+2)
--> square(3)
--> 3 * 3
--> 9

## Normal Evaluation
in f(x), subsitute x into f

square (1+2)
--> (1+2) * (1+2)
--> (3) * (3)
--> 9


### Intuition says Applicative Evaluation is faster, however is another example:

two _ = 2
infinity = infinity + 1
two infinity

#### applicative evaluation:

two infinity
two ( infinity + 1)
two ( (infinity + 1) + 1 )
...

#### normal evaluation:

two ( infinity )
2


## Differences between the two

normal will always terminate
applicative might not


#### Church Roser Theorem

- if the evaluation terminates, then the two evaluation strategies will agree
- if the expression can terminate, normal evaluation will find it


# Tail recursion

?? GO OVER THIS

Collatz is tail recursive because no computation is required after collatz computes the recursive call


# Tuples

Some computations can output multiple values at the same time

tuples have a maximum of 64 values inside

# Polymorphism

id :: forall a . a -> a
id x = x

?? Go Over Identity function and this entire section


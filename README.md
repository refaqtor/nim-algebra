# Algebraic Expression Parser & Evaluator

This uses the Shunting-Yard algorithm to convert expressions with infixed operators to postfixed expressions, and then evaluates the expression.

## Example

```nim
import algebra

echo evaluate(expr"1.5+1.5")
#=> 3.0

echo evaluate(expr"a/ln(b)", {"a": 5.5, "b": 2.2})
#=> 6.975646720399666

echo evaluate(expr"sin(a)", "a", [0.0, 1.0, 2.0, 3.0, 4.0, 4.5])
#=> @[0.0, 0.8414709848078965, 0.9092974268256817, 0.1411200080598672, -0.7568024953079282, -0.977530117665097]
```

## Parsing Details

- After a function name (e.g. sin, cos, ln, etc.), a left parenthesis (`(`) must always immediately follow.
- The `expr` procedure returns the tokens after the Shunting-Yard algorithm is applied.

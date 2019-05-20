import
  sequtils,
  strutils,
  tables,
  math

from algorithm import `reversed`

type
  AlgError* = object of Exception

const
  OperatorTable = {
    "-": (0, false),
    "+": (0, false),
    "*": (1, false),
    "/": (1, false),
    "%": (1, false),
    "^": (2, true)
  }.toTable
  FunctionTable = {
    "sin":    proc (n: float): float = sin(n),
    "cos":    proc (n: float): float = cos(n),
    "tan":    proc (n: float): float = tan(n),
    "csc":    proc (n: float): float = csc(n),
    "sec":    proc (n: float): float = sec(n),
    "cot":    proc (n: float): float = cot(n),
    "arcsin": proc (n: float): float = arcsin(n),
    "arccos": proc (n: float): float = arccos(n),
    "arctan": proc (n: float): float = arctan(n),
    "arccsc": proc (n: float): float = arccsc(n),
    "arcsec": proc (n: float): float = arcsec(n),
    "arccot": proc (n: float): float = arccot(n),
    "ln":     proc (n: float): float = ln(n),
    "sqrt":   proc (n: float): float = sqrt(n),
    "abs":    proc (n: float): float = abs(n),
    "ceil":   proc (n: float): float = ceil(n),
    "floor":  proc (n: float): float = floor(n),
    "gamma":  proc (n: float): float = gamma(n),
    "round":  proc (n: float): float = round(n)
  }.toTable

proc precedence(c: string): int =
  if OperatorTable.hasKey(c):
    return OperatorTable[c][0]
  else: return -1

proc isValue(c: char): bool =
  if c.isAlphaNumeric or c == '.': return true
  else: return false

proc isFunction(s: string): bool =
  return FunctionTable.hasKey(s)

proc expr*(expression: string): seq[string] =
  var
    count = 0
    value:      string = ""
    operators:  seq[string]
    output:     seq[string]
  for token in expression:
    let isValue: bool = token.isValue
    if token == ' ': discard
    elif isValue: value &= token
    elif token == '(': operators.add("(")
    elif token == ')':
      var found = false
      for operator in reversed(operators):
        if operator == "(":
          discard operators.pop
          found = true
          break
        else:
          output.add($(operator))
          discard operators.pop
      if not found:
        raise newException(AlgError, "Mismatched Parenthesis")
    else:
      let newPrecedence = precedence($(token))
      if newPrecedence != -1:
        if len(operators) > 0:
          for operator in reversed(operators):
            if operators[high(operators)].isFunction or
                newPrecedence < precedence(operators[high(operators)]) or
                (newPrecedence == precedence(operators[high(operators)]) and
                not OperatorTable[operators[high(operators)]][1]):
              output.add($(operators.pop))
          operators.add($(token))
        else: operators.add($(token))
      else:
        raise newException(AlgError, "Unknown Operator: " & token)
    if len(value) > 0:
      if count < len(expression)-1 and not expression[count+1].isValue and not value.isFunction:
        output.add(value)
        value = ""
      elif count == len(expression)-1 and not value.isFunction:
        output.add(value)
        value = ""
      elif value.isFunction:
        if count < len(expression)-1 and expression[count+1] == '(':
          operators.add(value)
          value = ""
        else:
          raise newException(AlgError, "Missing opening parenthesis with function " & value)
    count += 1
  for operator in reversed(operators):
    if operator == "(": raise newException(AlgError, "Mismatched Parenthesis")
    else: output.add($(operator))
  return output

var emptyTable: Table[string, float]
proc evaluate*(shunted: seq[string], variables: Table[string, float] = emptyTable): float =
  var valueStack: seq[float]
  for term in shunted:
    if allIt(term, it.isValue) and not term.isFunction:
      if len(term) == 1 and Letters.contains(term[0]):
        if len(variables) > 0 and variables.hasKey(term):
          valueStack.add(variables[term])
        else:
          raise newException(AlgError, "Missing variable " & term)
      else:
        valueStack.add(parseFloat(term))
    elif term.isFunction:
      valueStack.add(FunctionTable[term](valueStack.pop))
    else:
      if len(valueStack) > 1:
        let
          v1 = valueStack.pop
          v2 = valueStack.pop
        case term
        of "+": valueStack.add(v2+v1)
        of "-": valueStack.add(v2-v1)
        of "*": valueStack.add(v2*v1)
        of "/": valueStack.add(v2/v1)
        of "%": valueStack.add(v2 mod v1)
        of "^": valueStack.add(pow(v2, v1))
        else: discard
      elif len(valueStack) == 1 and term == "-":
        valueStack.add(-valueStack.pop)
      elif len(valueStack) == 1 and term == "+":
        valueStack.add(valueStack.pop)
      else:
        raise newException(AlgError, "Hanging Operator " & term)
  if len(valueStack) > 1: raise newException(AlgError, "Left over Operators")
  elif len(valueStack) == 1: return valueStack.pop
  elif len(valueStack) == 0: return 0

proc evaluate*(shunted: seq[string], variables: openArray[(string, float)]): float =
  evaluate(shunted, variables.toTable)

proc evaluate*(shunted: seq[string], symbol: string, values: openArray[float]): seq[float] =
  var results: seq[float]
  for v in values:
    results.add(evaluate(shunted, {symbol: v}.toTable))
  results

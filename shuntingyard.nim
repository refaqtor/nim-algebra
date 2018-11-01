import
  sequtils,
  strutils,
  tables

from unicode import `reversed`

type
  ShuntingYard = ref object
    expression: string
    output:     string
    operators:  string
  SYError* = object of Exception

const
  OperatorTable = {
    '-': (0, false),
    '+': (0, false),
    '*': (1, false),
    '/': (1, false),
    '^': (2, true)
  }.toTable

proc precedence(c: char): int =
  if OperatorTable.hasKey(c):
    return OperatorTable[c][0]
  else: return -1

method parse(s: ShuntingYard) {.base.} =
  for token in s.expression:
    if token.isAlphaNumeric: s.output &= token
    elif token == '(': s.operators &= '('
    elif token == ')':
      var found = false
      for operator in reversed(s.operators):
        if operator == '(':
          s.operators = s.operators[0..^2]
          found = true
          break
        else:
          s.output &= ' ' & operator
          s.operators = s.operators[0..^2]
      if not found:
        raise newException(SYError, "Mismatched Parenthesis")
    elif token == ' ': discard
    else:
      let newPrecedence = precedence(token)
      if newPrecedence != -1:
        if len(s.operators) > 0:
          for operator in reversed(s.operators):
            if s.operators[len(s.operators)-1] != '(' and newPrecedence < precedence(s.operators[len(s.operators)-1]) or
                (newPrecedence == precedence(s.operators[len(s.operators)-1]) and
                not OperatorTable[s.operators[len(s.operators)-1]][1]):
              s.output &= ' ' & s.operators[len(s.operators)-1]
              s.operators = s.operators[0..^2]
          s.operators &= token
          s.output &= ' '
        else:
          s.operators &= token
          s.output &= ' '
      else:
        raise newException(SYError, "Unknown Operator " & token)
  for operator in reversed(s.operators): s.output &= ' ' & operator

proc shuntingYard*(e: string): string =
  var convert = ShuntingYard(expression: e)
  convert.parse()
  return convert.output

#--------------------
# Math and logic
#--------------------

proc `+`*[T](r: RqlQuery, b: T): RqlQuery =
  ## Sum two numbers, concatenate two strings, or concatenate 2 arrays
  NEW_QUERY(ADD, r, b)

proc `+`*[T](b: T, r: RqlQuery): RqlQuery =
  ## Sum two numbers, concatenate two strings, or concatenate 2 arrays
  r + b

proc add*[T](r: RqlQuery, b: T): RqlQuery {.inline.} =
  r + b

proc `-`*[T](r: RqlQuery, b: T): RqlQuery =
  ## Subtract two numbers.
  NEW_QUERY(SUB, r, b)

proc `*`*[T](r: RqlQuery, b: T): RqlQuery =
  ## Multiply two numbers, or make a periodic array.
  NEW_QUERY(MUL, r, b)

proc `/`*[T](r: RqlQuery, b: T): RqlQuery =
  ## Divide two numbers.
  NEW_QUERY(DIV, r, b)

proc `%`*[T](r: RqlQuery, b: T): RqlQuery =
  ## Find the remainder when dividing two numbers.
  NEW_QUERY(MOD, r, b)

proc `and`*[T](r: RqlQuery, b: T): untyped =
  ## Compute the logical “and” of two or more values
  NEW_QUERY(AND, r, b)

proc `&`*[T](r: RqlQuery, e: T): untyped =
  ## Shortcut for `and`
  r and e

proc `or`*[T](r: RqlQuery, b: T): RqlQuery =
  ## Compute the logical “or” of two or more values.
  NEW_QUERY(OR, r, b)

proc `|`*[T](r: RqlQuery, e: T): untyped =
  ## Shortcut for `or`
  r or e

proc `eq`*[T](r: RqlQuery, e: T): RqlQuery =
  ## Test if two values are equal.
  let t = r.expr(e)
  NEW_QUERY(EQ, r, t)

proc `==`*[T](r: RqlQuery, e: T): untyped =
  ## Shortcut for `eq`
  r.eq(e)

proc `ne`*[T](r: RqlQuery, e: T): RqlQuery =
  ## Test if two values are not equal.
  let t = r.expr(e)
  NEW_QUERY(NE, r, t)

proc `!=`*[T](r: RqlQuery, e: T): untyped =
  ## Shortcut for `ne`
  r.ne(e)

proc `gt`*[T](r: RqlQuery, e: T): RqlQuery =
  ## Test if the first value is greater than other.
  let t = r.expr(e)
  NEW_QUERY(GT, r, t)

proc `>`*[T](r: RqlQuery, e: T): untyped =
  ## Shortcut for `gt`
  r.gt(e)

proc `ge`*[T](r: RqlQuery, e: T): RqlQuery =
  ## Test if the first value is greater than or equal to other.
  let t = r.expr(e)
  NEW_QUERY(GE, r, t)

proc `>=`*[T](r: RqlQuery, e: T): untyped =
  ## Shortcut for `ge`
  r.ge(e)

proc `lt`*[T](r: RqlQuery, e: T): RqlQuery =
  ## Test if the first value is less than other.
  let t = r.expr(e)
  NEW_QUERY(LT, r, t)

proc `<`*[T](e: T, r: RqlQuery): untyped =
  ## Shortcut for `lt`
  r.gt(e)

proc `le`*[T](r: RqlQuery, e: T): RqlQuery =
  ## Test if the first value is less than or equal to other.
  let t = r.expr(e)
  NEW_QUERY(LE, r, t)

proc `<=`*[T](e: T, r: RqlQuery): untyped =
  ## Shortcut for `le`
  r.ge(e)

proc `not`*[T](r: RqlQuery, e: T): RqlQuery =
  ## Compute the logical inverse (not) of an expression.
  let t = r.expr(e)
  NEW_QUERY(NOT, r, t)

proc `~`*[T](r: RqlQuery, e: T): untyped =
  ## Shortcut for `not`
  r not e

proc random*(r: RethinkClient, x = 0, y = 1, isFloat = false): RqlQuery =
  ## Generate a random number between given (or implied) bounds.
  NEW_QUERY(RANDOM)

  if x != 0:
    result.addArg(newDatum(x))
  if x != 0 and y != 1:
    result.addArg(newDatum(y))
  if isFloat:
    result.setOption("float", isFloat)

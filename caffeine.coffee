#
# Copyright (c) 2013 Ambrus Csaszar
# Distributed as-is without warranty for any purpose. Do not reproduce.
#

# EXCEPTION BASE

class Exception extends Error
    # Constructor is necessary to make inheritance work in coffeescript
    constructor: (msg) ->
        @name = @constructor.name
        @message = msg
        Error.captureStackTrace(@, @constructor)


# UNIT TESTING

class AssertionException extends Exception
    constructor: ->
        super
        stack_toks = @stack.split("\n")
        if stack_toks[1].indexOf("TestSuite.Assert") > -1
            stack_toks.splice(1, 1)
            @stack = stack_toks.join("\n")

class TestSuite
    Assert: (cond, msg) ->
        if not cond
            if not msg
                msg = "Condition was '#{cond}'"
            throw new AssertionException(msg)

    AssertThrows: (exceptionClass, func) ->
        threw = false
        try
            func()
            throw new AssertionException("Expected an exception")
        catch e
            if e instanceof exceptionClass
                threw = true
        if not threw
            throw new AssertionException("Expected an exception")

    Run: () ->
        for k,v of @
            if k.toLowerCase().lastIndexOf("test", 0) == 0
                name = "#{@constructor.name}.#{k}"
                if v instanceof Function
                    try
                        v.bind(@)()
                        console.log "ok     #{name}"
                    catch e
                        if e instanceof AssertionException
                            console.log "FAILED #{name}"
                        else
                            console.log "ERROR  #{name}"
                        console.error e.stack
                else
                    console.warn "!!!    #{name} is prefixed with 'test' but isn't a function. This is discouraged"


# ASSUMPTIONS

class BadAssumptionException extends Exception

Assume = (val, msg) ->
    if not val
        throw new BadAssumptionException(msg)


# NUMBERS

class Num
    @IsInt: (n) ->
        return Math.floor(n) == +n
    @IsFloat: (n) ->
        return !Num.IsInt(n)
    @IsEven: (n) ->
        Assume(Num.IsInt(n), "input must be an integer - was '#{n}'")
        return n % 2 == 0 
    @IsOdd: (n) ->
        return !Num.IsEven(n)


# ITERABLES

# class Iterable
#     MoveNext: () ->
#         throw new BadAssumptionException(
#             "#{@constructor.name} derived class must implement MoveNext")

# class ArrayIterable extends Iterable
#     constructor: (@arr) ->
#         Assume(arr instanceof Array, "input to #{@constructor.name} must be an Array")
#         @i = -1
#         @CurrentValue = undefined
#     MoveNext: () ->
#         @i++
#         @CurrentValue = @arr[@i]
#         return Boolean(@i < @arr.length)
#     Get: (i) ->
#         return 

# class SelectExpr extends Iterable

# EXPORTS

# This is pretty gross....
module.exports =
    # Exception Base
    Exception: Exception
    # Testing
    AssertionException: AssertionException
    TestSuite: TestSuite
    # Assumptions
    BadAssumptionException: BadAssumptionException
    Assume: Assume
    # Numbers
    Num: Num

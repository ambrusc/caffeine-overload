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


# PROTOTYPE UTILS

Number.prototype.IsInt = () ->
    return Math.floor(@) == +@
Number.prototype.IsEven = () ->
    Assume(@IsInt(), "input must be an integer - was '#{@}'")
    return @ % 2 == 0 
Number.prototype.IsOdd = () ->
    return !@IsEven()


# ITERABLES

class Iterable
    MoveNext: () ->
        throw new BadAssumptionException(
            "#{@constructor.name} derived class must implement MoveNext")

class ArrayIterable extends Iterable
    constructor: (arr) ->
        Assume(arr instanceof Array, "input to #{@constructor.name} must be an Array")
    MoveNext: () ->


# EXPORTS

export_classes = (args...) ->
    for i in args
        module.exports[i.name] = i

global.Exception = Exception 
global.Assume = Assume
global.BadAssumptionException = BadAssumptionException

export_classes(
    # Testing
    AssertionException, 
    TestSuite,

    # Iterables
    ArrayIterable,
)

return


# class Expr
#     ToArray: () ->
#         if @in instanceof Array
#             ret = []
#             while 
#         if @in is 
#         return 

#     Where: (func) ->
#         return new WhereExpr(@in, func)

# class WhereExpr extends Expr
#     constructor: (@in, func) ->
#         @CurrentValue = undefined

#     MoveNext: () ->


# ident = (o) ->
#     a = "asdiff"
#     console.log a instanceof Object

# ident([])

# Array.prototype.Where = (func) ->
#     return @filter(func)
# Array.prototype.Select = (func) ->
#     return @map(func)

# console.log [1..12]
#     .Where((i) -> i.IsEven())
#     .Select((i) -> i * 2)
#     .ToArray()

# url = "http://webservices.nextbus.com/service/publicXMLFeed"

# routes =
#     agencyList: "#{url}?command=agencyList"

# http.get(routes.agencyList, (res) ->
#     res.setEncoding("utf8")
#     data = ""
#     res.on("data", (chunk) -> data += chunk)
#     res.on("end", () ->
#         parser.parseString(data, (err, result) ->
#             console.log JSON.stringify(result)
#         )
#     )
# )

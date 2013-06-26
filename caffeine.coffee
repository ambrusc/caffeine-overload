#
# *Copyright &copy; 2013 Ambrus Csaszar*
#
# Provides a set of basic utilities for  
#
#  * [Exceptions](#exceptions)
#  * [Assumptions](#assumptions)
#  * [Numbers](#numbers)
#  * [Unit Testing](#unittesting)

# <a id="exceptions"/>
# EXCEPTIONS
# ---

# We create a base class for OO-style exceptions, since Error objects don't
# generally work cross-platform with `instanceof` checks.
class Exception extends Error
    # The constructor is necessary to make inheritance work properly.
    constructor: (msg) ->
        @name = @constructor.name
        @message = msg
        Error.captureStackTrace(@, @constructor)


# <a id="assumptions"/>
# ASSUMPTIONS
# ---
# Before executing a function it's often useful to validate its preconditions.

# We provide a static class to encapsulate such checks.
class Assume

    # Failed assumptions throw `Assume.Exception`
    @Exception: class AssumeException extends Exception

    # The utility constructor calls the basic check, so you can write
    # `Assume ...` instead of having to write `Assume.True ...`
    constructor: (val, msg) -> Assume.True val, msg

    # The most basic assumption checks for truthiness.
    @True: (val, msg) ->
        if not val
            if not msg
                msg = "Expected a truthy value - got '#{val}'"
            throw new Assume.Exception msg

    # Assume a value exists.
    @Exists: (val, msg) -> 
        Assume val != undefined and val != null, "Expected a value - got '#{val}'"

    # Assume two values are equal.
    @Equal: (a, b, msg) -> Assume a == b, "Expected '#{a}' == '#{b}'"


# <a id="numbers"/>
# NUMBERS
# ---

# It's useful to know some basic things about numbers.
class Num
    @IsInt: (n) ->
        return Math.floor(n) == +n
    @IsFloat: (n) ->
        return not Num.IsInt n
    @IsEven: (n) ->
        Assume.True Num.IsInt(n), "Expected an Integer - got '#{n}'"
        return n % 2 == 0 
    @IsOdd: (n) ->
        return not Num.IsEven n


# <a id="unittesting"/>
# UNIT TESTING
# ---

# Write unit tests by extending TestSuite with methods prefixed with `Test`...
class TestSuite

    # Failed Assertions throw TestSuite.Exception
    @Exception: class TestSuiteException extends Exception
        constructor: ->
            super
            # We strip off the helper function portions of the stack trace
            stack_toks = @stack.split("\n")
            if stack_toks[1].indexOf("TestSuite.Assert") > -1
                stack_toks.splice(1, 1)
                @stack = stack_toks.join("\n")

    # The most basic Assertion tests for truthiness of `cond`.
    Assert: (cond, msg) ->
        if not cond
            if not msg
                msg = "Condition was '#{cond}'"
            throw new TestSuite.Exception(msg)

    # We can also assert that a `func` throws a particular class of Exception.
    AssertThrows: (exceptionClass, func) ->
        threw = false
        try
            func()
            throw new TestSuite.Exception("Expected an exception")
        catch e
            if e instanceof exceptionClass
                threw = true
        if not threw
            throw new TestSuite.Exception("Expected an exception")

    # Execute the unit tests defined in this test suite and output results to
    # the console.
    Run: () ->
        for k,v of @
            if k.toLowerCase().lastIndexOf("test", 0) == 0
                name = "#{@constructor.name}.#{k}"
                if v instanceof Function
                    try
                        v.bind(@)()
                        console.log "ok     #{name}"
                    catch e
                        if e instanceof TestSuite.Exception
                            console.log "FAILED #{name}"
                        else
                            console.log "ERROR  #{name}"
                        console.error e.stack
                else
                    console.warn "!!!    #{name} is prefixed with 'test' but isn't a function. This is discouraged"


# Public API
# ---

module.exports = Caffeine = { Assume, Exception, Num, TestSuite }

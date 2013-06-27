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

# We create a base class for OO-style exceptions, the avoids all the
# cross-platform inconsistencies and works with `instanceof` checks.
class Exception extends Error
    # The constructor is necessary to make inheritance work properly.
    constructor: (msg) ->
        @name = @constructor.name
        @message = msg
        @stack = (new Error).stack
        if InstallTrigger?  # Firefox
            @ChopStack 1    # Chop off the first line
        else if chrome? or process?   # V8/node
            @ChopStack 2    # Chop off the first two lines
        else
            @stack = err.stack

    # Sometimes we need to chop lines off the top of the stack to get it to be
    # correct
    ChopStack: (lines) ->
        if @stack?
            # Chop extraneous lines from the stack trace
            i = 0
            for n in [0...lines]
                i = @stack.indexOf("\n", i) + 1
            if i > 0
                @stack = @stack.substring i


# <a id="assumptions"/>
# ASSUMPTIONS
# ---
# Before executing a function it's often useful to validate its preconditions.

# Failed assumptions throw `Assume.Exception`
class AssumptionException extends Exception

# We provide a static class to encapsulate such checks.
class Assume

    # The utility constructor calls the basic check
    constructor: (val, msg) -> Assume._check val, msg

    # Assume a value exists.
    @Exists: (val, msg) -> Assume._check val?, "Expected a value - got '#{val}'"

    # Assume two values are equal.
    @Equal: (a, b, msg) -> Assume._check a == b, "Expected '#{a}' == '#{b}'"

    # The utility method checks does the meat of the assumption checking work
    @_check: (val, msg) ->
        if not val
            if not msg
                msg = "Expected a truthy value - got '#{val}'"
            err = new AssumptionException msg
            err.ChopStack 3
            throw err


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
        Assume Num.IsInt(n), "Expected an Integer - got '#{n}'"
        return n % 2 == 0 
    @IsOdd: (n) ->
        return not Num.IsEven n


# <a id="unittesting"/>
# UNIT TESTING
# ---

# Failed Assertions throw TestException
class TestException extends Exception
    constructor: ->
        super
        # We strip off the helper function portions of the stack trace
        stack_toks = @stack.split("\n")
        if stack_toks[1].indexOf("TestSuite.Assert") > -1
            stack_toks.splice(1, 1)
            @stack = stack_toks.join("\n")

# Test suites generate an array of results, one for each test.
class TestResult
    constructor: (@name, @status, @error) ->

# Write unit tests by extending TestSuite with methods prefixed with `Test`...
class TestSuite

    # The most basic Assertion tests for truthiness of `cond`.
    Assert: (cond, msg) ->
        if not cond
            if not msg
                msg = "Condition was '#{cond}'"
            throw new TestException(msg)

    # We can also assert that a `func` throws a particular class of Exception.
    AssertThrows: (exceptionClass, func) ->
        threw = false
        try
            func()
            throw new TestException("Expected an exception")
        catch e
            if e instanceof exceptionClass
                threw = true
        if not threw
            throw new TestException("Expected an exception")

    # By default, we log results to the console.
    LogToConsole: (result) ->
        nspace = 8 - result.status.length
        msg = result.status
        for i in [0...nspace]
            msg += " "
        msg += result.name

        if result.error?
            console.error msg
            console.error result.error.stack
        else
            console.log msg

    # We provide a way to get the names of the test methods to facilitate
    # creating in-browser unit tests.
    GetTestMethods: () ->
        methods = []
        for k,v of this
            if k.toLowerCase().lastIndexOf("test", 0) == 0
                name = "#{@constructor.name}.#{k}"
                if v instanceof Function
                    methods.push { name: name, func: v.bind(this) }
                else
                    console.warn "!!! #{name} is prefixed with 'test' but isn't a function. This is discouraged"
        methods

    # We can run the methods provided by `GetTestMethods`, and call a handler
    # with results.
    RunTestMethods: (methods, onResult) ->
        results = []
        for m in methods
            res = new TestResult m.name
            try
                m.func()
                res.status = "ok"
            catch e
                if e instanceof TestException
                    res.status = "failed"
                else
                    res.status = "error"
                res.error = e
            onResult? res
        results

    # Execute the unit tests defined in this test suite, return the results,
    # and print the output to the console by default.
    # `onResult` takes a `TestResult` object
    Run: (onResult = @LogToConsole) ->
        methods = @GetTestMethods()
        @RunTestMethods methods, onResult


# Public API
# ---

module.exports = Caffeine = { 
    Assume, AssumptionException, Exception, Num, TestException, TestSuite
}

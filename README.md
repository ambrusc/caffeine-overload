
Caffeine provides a few handy tools that are present in most OO languages,
exposed through a commonjs module. Its niceties are optimized for CoffeeScript.

    caff = require "caffeine"

Exceptions
---
Caffeine provides the extensible `Exception` class that captures stack trace
and succeeeds in instancesof inheritance checks in most browsers.
*If you find a case where this is not true, send me a pull request or just let
me know*

    class MyException extends caff.Exception

    try
        throw new MyException "some message"
    catch e
        console.log e instanceof Error        # 'true'
        console.log e instanceof Exception    # 'true'
        console.log e instanceof MyException  # 'true'

Assumptions
---
Programming errors can lead to precondition violations when executing functions,
resulting in hard-to-find bugs. Caffeine provides a simple API for validating
precondition at runtime, allowing the developer to surface these bugs early.

You can append an execption message to use, should the assumption fail.

    assume = caff.Assume
    assume true, "I should not throw"           # okay
    assume false, "I expected a true value"     # throws caff.Assume.Exception

    assume.Exists var                   # throws if 'var' is undefined or null
    assume.Equal a, b                   # throws if a != b

Numbers
---
Some simple checks are implented for numbers
 * Num.IsFloat
 * Num.IsInt
 * Num.IsEven
 * Num.IsOdd

Unit Testing
---
Simple unit tests are easy to write as well, and Assertions work similarly to
Assumptions.

    class MyTest extends caff.TestSuite
        TestSomething: () ->
            @Assert true
            @Assert false, "some message"    # I'll throw a caff.TestSuite.Exception

            bad = () -> throw new MyException "boo!"
            good = () -> console.log "I have a halo"

            @AssertThrows MyException, bad            # This will pass just fine
            @AssertThrows MyException, good           # This will fail


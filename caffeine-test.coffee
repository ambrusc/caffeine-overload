#
# *Copyright &copy; 2013 Ambrus Csaszar*
#
# Tests for caffeine.coffee
#

caff = require "./caffeine.coffee"

Exception = caff.Exception
Assume = caff.Assume
Num = caff.Num

# Validate the basic functions of the TestSuite
class TestTests extends caff.TestSuite
    TestOK: () ->
    TestError: () -> throw new Exception "Flog"
    TestFailure: () -> @Assert false, "Something weird happened" 
    TestFoo: "bar"
    Testtoo: []
    teStcar: {}

class CaffeineTests extends caff.TestSuite
    # Validate Exception inheritance
    TestExceptions: () ->
        @Assert Exception, "Must have Exception class"
        class TestEx extends Exception
        class TestEx2 extends TestEx
        e = new TestEx2
        @Assert e instanceof Error
        @Assert e instanceof Exception
        @Assert e instanceof TestEx
        @Assert e instanceof TestEx2

    TestNumber: () ->
        for n in [-1234,-2,0,2,4,24,123458482]
            @Assert Num.IsInt n
            @Assert Num.IsEven n
            @Assert not Num.IsOdd n
        for n in [-123,-1,1,3,5,7,19,23493281]
            @Assert Num.IsInt n
            @Assert not Num.IsEven n
            @Assert Num.IsOdd n
        for n in [-1232543543.999,-1.00000000001,-1.1,1.1,1.0000001,1234939429.999]
            @Assert not Num.IsInt n

# Export the tests publicly
module.exports = { CaffeineTests }

# And run them if we're in Node
if not window?
    new CaffeineTests().Run()

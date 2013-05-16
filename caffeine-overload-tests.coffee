#
# Copyright (c) 2013 Ambrus Csaszar
# Distributed as-is without warranty for any purpose. Do not reproduce.
#

over = require("./caffeine-overload")

class TestTests extends over.TestSuite
    TestOK: () ->
    TestError: () ->
        throw new Exception("Flog")
    TestFailure: () ->
        @Assert(false, "Something weird happened")
    TestFoo: "bar"
    Testtoo: []
    teStcar: {}

class Tests extends over.TestSuite
    TestExceptions: () ->
        class TestEx extends Exception
        class TestEx2 extends TestEx
        @Assert(new TestEx2() instanceof Error)
        @Assert(new TestEx2() instanceof Exception)
        @Assert(new TestEx2() instanceof TestEx)
        @Assert(new TestEx2() instanceof TestEx2)

    TestNumber: () ->
        for n in [-1234,-2,0,2,4,24,123458482]
            @Assert(n.IsInt())
            @Assert(n.IsEven())
            @Assert(not n.IsOdd())
        for n in [-123,-1,1,3,5,7,19,23493281]
            @Assert(n.IsInt())
            @Assert(not n.IsEven())
            @Assert(n.IsOdd())
        for n in [-1232543543.999,-1.00000000001,-1.1,1.1,1.0000001,1234939429.999]
            @Assert(not n.IsInt())

    TestIterables: () ->
        @AssertThrows(BadAssumptionException, () ->
            n = new over.ArrayIterable().MoveNext()
        )

new Tests().Run()

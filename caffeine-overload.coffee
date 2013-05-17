#
# Copyright (c) 2013 Ambrus Csaszar
# Distributed as-is without warranty for any purpose. Do not reproduce.
#
caff = require("./caffeine")


# GLOBALS

g = window ? global     # Browser or Node?
g.Exception = caff.Exception 
g.Assume = caff.Assume
g.BadAssumptionException = caff.BadAssumptionException


# PROTOTYPE UTILS

Number.prototype.IsInt = () -> caff.Num.IsInt(@)
Number.prototype.IsFloat = () -> caff.Num.IsFloat(@)
Number.prototype.IsEven = () -> caff.Num.IsEven(@)
Number.prototype.IsOdd = () -> caff.Num.IsOdd(@)

Array.prototype.Select = (transformation) -> return @.map(transformation)
Array.prototype.Where = (predicate) -> return @.filter(predicate)
Array.prototype.ToDictionary = (keySelector, valueSelector) ->
    ret = {}
    for i in @
        ret[keySelector(i)] = valueSelector(i)
    return ret

String.prototype.StartsWith = (substr) ->
    Assume(substr, "input to String.StartsWith must be a nonempty string - was '#{substr}'")
    @.lastIndexOf(substr, 0) == 0


# EXPORTS
module.exports = caff

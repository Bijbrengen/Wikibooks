local testframe = {} 
testframe.frameTitle = 'Sjabloon:Opmaak'
testframe.parentTitle = 'Parent title'

-- Precedence-testing values
testframe.firstFrameArg = 'first frame argument'
testframe.firstParentArg = 'first parent argument'
testframe.secondParentArg = 'second parent argument'
testframe.uniqueFrameArg = 'unique frame argument'
testframe.uniqueFrameArgKey = 'uniqueFrameArgKey'
testframe.uniqueParentArg = 'unique parent argument'
testframe.uniqueParentArgKey = 'uniqueParentArgKey'

-- Trimming and whitespace values.
-- Whitespace gets trimmed from named parameters, so keys for these need
-- to be numbers to make this a proper test.
testframe.blankArg = ''
testframe.blankArgKey = 100 
testframe.spacesArg = '\n   '
testframe.spacesArgKey = 101
testframe.untrimmedArg = '\n   foo bar   '
testframe.untrimmedArgKey = 102
testframe.trimmedArg = 'foo bar'
testframe.valueFuncValue = 'valueFuncValue'
testframe.defaultValueFunc = function() return testframe.valueFuncValue end
testframe.translate = {
	foo = 'F00',
	bar = '8@r',
	baz = '8@z',
	qux = 'qUx'
}

return testframe
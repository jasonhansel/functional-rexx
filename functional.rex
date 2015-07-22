/*
Functional REXX

- Tested with Regina REXX
- This file includes:
	* Sample functions
	* Unit tests generating TAP (Test Anything Protocol) output
	* The library itself (further documentation below)

*/

/* Define some functions */
add = !('...args', 'return car(args) + car(cdr(args))')

getIndex = !('list, index', 'do while index ~= 1; list = cdr(list); index = index - 1; end; return car(list)')
always = !('k', 'return !("val", "return k", "k")')
concat = !('a, b', 'return revlist(revlist(a, nil()), b)')

addOne = !('x', 'return 1 + x')
double = !('x', 'return 2 * x')
triple = !('x', 'return 3 * x')

divide = !('x, y', 'return x / y')
compose = !('x, y', 'return !("...args", "return ?(x, apply(y, args))", "x, y")')
map = !('f, list', 'result = nil(); do while list ~= nil() ; result = cons(?(f, car(list)), result); list = cdr(list); end; return revlist(result, nil())')

lPartial = !('f, ...start', 'return !("...rest", "return apply(f, ?(concat, start, rest))", "f, concat, start")', 'concat')
rPartial = !('f, val', 'return !("z", "return ?(f, z, val)", "f, val")')

listLength = !('list', 'len = 0; do while list ~= nil(); list = cdr(list); len = len + 1; end; return len')
flip = !('fn', "return !('x, y', 'return ?(fn, y, x)', 'fn')")
tail = !('list', 'do while cdr(list) ~= nil(); list = cdr(list); end; return car(list)')
uniq = !('list', 'result = nil(); do while list ~= nil(); if value("found."car(list)) ~= 1 then do ; _dummy = value("found."car(list), 1); result = cons(car(list), result); end; list = cdr(list); end; return revlist(result, nil())  ')
flatMap = !('f, list', 'result = nil(); do while list ~= nil() ; result = ?(concat, ?(f, car(list)), result); list = cdr(list); end; return revlist(result, nil())', 'concat')
reduce = !('f, initial, list', 'result = initial; do while list ~= nil(); result = ?(f, result, car(list)); list = cdr(list); end; return result')
split = !('list, separator', 'result = nil(); do while index(list, separator) ~= 0; parse value list with start (separator) rest; result = cons(start, result); list = rest; end; return revlist(cons(list, result))')

splitChars = !('list', 'result = nil(); do while list ~= ""; result = cons(substr(list, 1, 1), result); list = substr(list, 2); end; return revlist(result)')

filter = !('f, list', 'result = nil(); do while list ~= nil(); if ?(f, car(list)) then result = cons(car(list), result); list = cdr(list); end; return revlist(result, nil()) ')
join = !('list, separator', 'result = ""; do while list ~= nil(); if result ~= "" then result = result || separator; result = result || car(list); list = cdr(list); end; return result')

makeList = !('...args', 'return args')




say 'TAP version 13'

call header 'Ordinary recursion'
do
	factorial = !('n', 'if n = 1 then return 1; else return n * ?(__self, n - 1)');
end
call assert ?(factorial, 5), 120
call assert ?(factorial, 1), 1


/* https://github.com/adlawson/js-zcombinator/blob/develop/src/z.js */
call header 'Z combinator'
do
	inner = !('fn, r', 'return !("x", "return ?( ?(fn, ?(r, r)), x )", "fn, r") ')
	recurse = !('recur', 'return ?(recur, recur)')
	Z = ?(compose, recurse, ??(lPartial, inner))
	factorial = ?(Z, !('fn', 'return !("n", "if n = 1 then return 1; else return n * ?(fn, n - 1);", "fn")'))
end
call assert ?(factorial, 5), 120
call assert ?(factorial, 1), 1


call header 'variadic compose()'
do
	doubleSum = ?(compose, double, add)
end
call assert ?(doubleSum, 5, 6), 22
call assert ?(doubleSum, 5, 0), 10

call header 'splitChars()'
do
	list = ?(splitChars, 'abcd')
end
call assert ?(listLength, list), 4
call assert ?(getIndex, list, 1), 'a'
call assert ?(getIndex, list, 2), 'b'
call assert ?(getIndex, list, 3), 'c'
call assert ?(getIndex, list, 4), 'd'


call header 'variadic lPartial()'
do
	sumList = ?(lPartial, reduce, add, 0)
	sumListWith = ?(lPartial, reduce, add)
	testList = cons(1, cons(8, cons(9, cons(2, nil()))))
end
call assert ?(sumList, testList), 20
call assert ?(sumListWith, 0, testList), 20
call assert ?(sumListWith, 5, testList), 25




call header 'shortcut lPartial()'
do
	sumList = ??(reduce, add, 0)
	sumListWith = ??(reduce, add)
	testList = cons(1, cons(8, cons(9, cons(2, nil()))))
end
call assert ?(sumList, testList), 20
call assert ?(sumListWith, 0, testList), 20
call assert ?(sumListWith, 5, testList), 25

call header 'apply()'
call assert apply(add, cons(2, cons(3, nil())) ), 5
call assert apply(listLength,  cons( cons(2, nil()) , nil()  ) ), 1



call header 'join()'
do
	list = cons('a', cons('b', cons('a', cons('c', nil()))))
	list2 = nil()
end
call assert ?(join, list, ' '), 'a b a c'
call assert ?(join, list2, ' '), ''



call header 'split()'
do
	list = ?(split, 'a b c d', ' ')
end
call assert ?(getIndex, list, 1), 'a'
call assert ?(getIndex, list, 2), 'b'
call assert ?(getIndex, list, 3), 'c'
call assert ?(getIndex, list, 4), 'd'

call header 'makeList()'
do
	list = ?(makeList, 'a', 'b', 'c', 'd')
	listB = ?(split, 'z', ' ')
	listC = ?(split, '', ' ')
end
call assert ?(getIndex, list, 1), 'a'
call assert ?(getIndex, list, 2), 'b'
call assert ?(getIndex, list, 3), 'c'
call assert ?(getIndex, list, 4), 'd'
call assert ?(getIndex, listB, 1), 'z'
call assert ?(getIndex, listC, 1), ''

call header 'filter()'
do
	list = ?(filter, !('x', 'return x ~= "a"'), ?(split, 'a b c d', ' '))
end
call assert ?(listLength, list), 3
call assert ?(getIndex, list, 1), 'b'
call assert ?(getIndex, list, 2), 'c'
call assert ?(getIndex, list, 3), 'd'





call header 'reduce()'
do
	list = cons(1, cons(5, cons(7, cons(6, nil()))))
end
call assert ?(reduce, add, 0, list), (1+5+7+6)



call header 'flatMap()'
do
	list = cons('a', cons('b', cons('a', cons('c', nil()))))
	filterer = !('x', 'if x == "a" then return nil(); else return cons(x"z", nil())')
	res = ?(flatMap, filterer, list)
end
call assert ?(listLength, res), 2
call assert ?(getIndex, res, 1), 'bz'
call assert ?(getIndex, res, 2), 'cz'


call header 'uniq()'
do
	list = cons('a', cons('b', cons('a', cons('c', nil()))))
	list = ?(uniq, list)
end
call assert ?(getIndex, list, 1), 'a'
call assert ?(getIndex, list, 2), 'b'
call assert ?(getIndex, list, 3), 'c'
call assert ?(listLength, list), 3


call header 'tail()'
do
	list = cons('a', cons('b', nil()))
	list2 = cons('a', cons('b', cons('c', nil())))
end
call assert ?(tail, list), 'b'
call assert ?(tail, list2), 'c'


call header 'flip()'
do
	undivide = ?(flip, divide)
end
call assert ?(undivide, 2, 1), 0.5
call assert ?(undivide, 1, 2), 2

call header 'listLength()'
do
	list = cons('a', cons('b', nil()))
	list2 = cons('a', cons('b', cons('c', nil())))
	list3 = nil()
end
call assert ?(listLength, list), 2
call assert ?(listLength, list2), 3
call assert ?(listLength, list3), 0

call header 'rPartial()'
do
	halve = ?(rPartial, divide, 2)
end
call assert ?(halve, 3), 1.5
call assert ?(halve, 4), 2


call header 'concat()'
do
	list = cons('a', cons('b', nil()))
	list2 = cons('e', cons('f', nil()))
	listC = ?(concat, list, list2)
end
call assert ?(getIndex, listC, 1), 'a'
call assert ?(getIndex, listC, 2), 'b'
call assert ?(getIndex, listC, 3), 'e'
call assert ?(getIndex, listC, 4), 'f'


call header 'always()'
do
	alwaysFive = ?(always, 5)
end
call assert ?(alwaysFive, 0), 5
call assert ?(alwaysFive, 1), 5
call assert ?(alwaysFive, 2), 5




call header 'getIndex()'
do
	list = cons('a', cons('b', cons('c', cons('d', nil()))))
end
call assert ?(getIndex, list, 1), 'a'
call assert ?(getIndex, list, 2), 'b'
call assert ?(getIndex, list, 3), 'c'
call assert ?(getIndex, list, 4), 'd'



call header 'car(), cdr(), cons()'
call assert car(cons('a'.ENDOFLINE'e', 'b')), 'a' || .ENDOFLINE || 'e'
call assert cdr(cons('a', 'b'.ENDOFLINE'f')), 'b' || .ENDOFLINE || 'f'
call assert cdr(cons(cons('a', 'c'), 'b')), 'b'
call assert car(car(cons(cons('a', 'c'), 'b'))), 'a'
call assert cdr(car(cons(cons('a', 'c'), 'b'))), 'c'


call header 'compose()'
do
	addTwo = ?(lPartial, add, 2)
end
call assert ?(addOne, 1), 2
call assert ?(double, 5), 10
call assert ?(?(compose, addOne, double), 5), 11
call assert ?(?(compose, addOne, triple), 5), 16
call assert ?(?(compose, triple, ?(compose, addOne, double) ), 5), 33



call header 'Unstemming'
do
	numbers.0 = 4
	numbers.1 = 15
	numbers.2 = 10
	numbers.3 = 0
	numbers.4 = 6
	unstemmed = destem('numbers.')
end
call assert car(unstemmed), 15
call assert car(cdr(unstemmed)), 10
call assert car(cdr(cdr(unstemmed))), 0
call assert car(cdr(cdr(cdr(unstemmed)))), 6

call header 'Mapping'
do
	newList = ?(map, double, unstemmed)
end
call assert car(newList), 30
call assert car(cdr(newList)), 20
call assert car(cdr(cdr(newList))), 0
call assert car(cdr(cdr(cdr(newList)))), 12

call header 'Restem'
do
	call restem 'new.', newList
end
call assert new.0, 4
call assert new.1, 30
call assert new.2, 20
call assert new.3, 0
call assert new.4, 12

call header 'add() and addTwo()'
call assert ?(add, 2, 3), 5
call assert ?(addTwo, 1), 3
call assert ?(addTwo, 2), 4
call assert ?(addTwo, 3), 5



call header 'map(), compose(), lPartial()'
do
	output = !('x', 'say x ; return x')
	newListOne.0 = numbers.0
	do i = 1 to numbers.0
		newListOne.i = (numbers.i * 2) + 50
	end
	call restem 'newListTwo.', ?(map, ?(compose, ?(lPartial, add, 50), double), destem('numbers.'))
end
call assert newListOne.0, 4
call assert newListOne.1, 80
call assert newListOne.2, 70
call assert newListOne.3, 50
call assert newListOne.4, 62

call assert newListTwo.0, 4
call assert newListTwo.1, 80
call assert newListTwo.2, 70
call assert newListTwo.3, 50
call assert newListTwo.4, 62

exit

/*
	The ! procedure is used to create anonymous functions,
	which are stored in strings.

	- The first parameter is a comma-separated list of arguments.
	  Spread parameters can be used to create variadic functions.
	- The second parameter is the contents of the procedure
	- The third (optional) parameter is a comma-separated list of
	  variables that the function should be able to access. This serves
	  as a way of implementing lexical scope.
*/
!:
	parse arg _args, _text, _uses

	_settings = ""
	do while _uses ~= ""
		parse value _uses with first ', ' _uses
		_settings = _settings .ENDOFLINE first '=' escape(value(first))
	end

	_arglist = nil()
	do while _args ~= ""
		if index(_args, '...') == 1 then do
			parse value _args with '...'_spreadv
			_arglist = cons(_spreadv, cons('...', _arglist))
			_args = ''
		end
		else do
			parse value _args with start ', ' _args
			_arglist = cons(start, _arglist)
		end
	end

	return cons(_settings .ENDOFLINE _text, revlist(_arglist))

/*
The "escape" procedure converts a string into a REXX string literal,
for use within INTERPRET.
*/
escape:
	procedure
	parse arg str
	dq = '"'
	sq = "'"
	str = changestr('"', str, dq||sq||dq||sq||dq)
	str = changestr(.ENDOFLINE, str, '".ENDOFLINE"')
	return '"'str'"'

/*
The ? procedure is used to apply anonymous functions to arguments.
This uses INTERPRET, which presents a possible performance issue.
*/
?:
	procedure
	parse arg proc

	/* Gather arguments */
	_arg_tpl = cdr(proc)
	do _index = 0 while _arg_tpl ~= nil()
		if car(_arg_tpl) == '...' then do
			/* Spread parameter */
			_args = nil()
			do i = (_index + 1) to arg()
				_args = cons(arg(i), _args)
			end
			_dummy = value(car(cdr(_arg_tpl)), cdr(revlist(_args)))
			leave
		end
		_dummy = value(car(_arg_tpl), arg(_index + 2))
		_arg_tpl = cdr(_arg_tpl)
	end
	__self = proc

	interpret car(proc)

/*
?? is just a shortcut for partial application (currying), which is useful
in languages where functions can take multiple arguments.
*/
??:
	procedure

	_args = cons('abc', nil())
	do i = 1 to arg()
		_args = cons(arg(i), _args)
	end
	_startArgs = cdr(revlist(_args))

	fn = car(_startArgs)
	_start = revlist(cdr(_startArgs))

	return !("...args", "return apply(fn, revlist(_start, args))", "fn, _start")

/*
apply(proc, args) applies an anonymous procedure to a list of arguments.
*/
apply:
	procedure
	parse arg proc, arguments

	_list = arguments

	/* Gather arguments*/
	_arg_tpl = cdr(proc)
	do while _arg_tpl ~= nil()
		if car(_arg_tpl) == '...' then do
			_dummy = value( car(cdr(_arg_tpl)), _list )
			leave
		end
		_dummy = value(car(_arg_tpl), car(_list))
		_list = cdr(_list)
		_arg_tpl = cdr(_arg_tpl)
	end

	interpret car(proc)

/*
cons(a, b) joins two values together in a pair.
(The names "cons", "car", and "cdr" all come from LISP.)

This can be used to create linked lists or other data structures.
For example, the list "1, 2, 3" can be represented as
	cons(1, cons(2, cons(3, nil())))
*/
cons:
	procedure
	parse arg first, second
	return right(length(first), 10, '0') || first || second

/*
car(x) gets the first element of a pair.
*/
car:
	procedure
	parse arg of
	return substr(of, 11, substr(of, 1, 10))

/*
cdr(x) gets the second element of a pair.
*/
cdr:
	procedure
	parse arg of
	return substr(of, 11 + substr(of, 1, 10))

/*
Obtains a value to use for "nil," as in LISP.
This cannot be a global variable since REXX
does not support lexical scope.
*/
nil:
	procedure
	return '[[[nil]]]'

/*
destem('stem.') converts a stem variable into a linked list.
*/
destem:
	parse arg stem
	procedure expose (stem)

	head = nil()
	do i = 1 to value(stem'0')
		head = cons(value(stem || i), head)
	end

	return revlist(head)

/*
revlist quickly reverses a list created with cons.
*/
revlist:
	procedure
	parse arg list, accumulator

	if accumulator == "" then accumulator = nil()

	state = cons(list, accumulator)
	do while car(state) ~= nil()
		/* Move one item from car(state) to cdr(state) */
		state = cons(  cdr(car(state)), cons(car(car(state)), cdr(state)) )
	end

	return cdr(state)

/*
restem('stem.', list) turns a list created using "cons" back into a stem variable.
Needed for interop. purposes.
*/
restem:
	parse arg stem, list
	procedure expose list (stem)
	/* Store the items */
	do i = 1 while list ~= nil()
		first = car(list)
		_dummy = value(stem || i, car(list))
		list = cdr(list)
	end
	/* Store the length */
	_dummy = value(stem'0', i - 1)
	return

/*
assert() is used to assert that two variables are equal.
Generates TAP output.
*/
assert:
	procedure
	parse arg left, right
	if left ~= right then do

		say 'not ok'
		say '  ---'
		say '  data:'
		say '    expected:' escape(right)
		say '    actual:' escape(left)
		say '  ...'
	end
	else do
		say 'ok'
	end
	return

/*
header() is used to create a heading. Generates TAP output.
*/
header:
	procedure
	parse arg heading
	say '#' heading
	return
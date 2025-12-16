# HLSInterpreter v3.0 - Test Cases

## Test the complex command syntax

### Example 1: The main example
```
store 0 in n
print 5 multiply by n if 5 modulus n equals 0 and increment n , loop 10 times
```

**Expected behavior:**
- Loop 10 times
- Each iteration: increment n, then if 5 modulus n equals 0, print 5*n
- Should print: nothing (5%1-10 are never 0, but for n=5: print 25, n=10: skip since we start at 0)

### Example 2: Simple loop with increment
```
store 0 in n
increment n , loop 5 times
show n
```

**Expected:** n = 5

### Example 3: Conditional print
```
store 10 in x
print x if x greater than 5
```

**Expected:** 10

### Example 4: Expression evaluation
```
store 5 in n
print 5 multiply by n
```

**Expected:** 25

### Example 5: Modulus operation
```
store 5 in a
store 2 in b
print a modulus b
```

**Expected:** 1

### Example 6: Nested with 'and'
```
store 1 in x
increment x and print x
```

**Expected:**
- x becomes 2
- prints 2

### Example 7: Complex nesting
```
store 1 in n
print n and increment n , loop 3 times
```

**Expected:**
- Loop 3 times
- Each iteration: print n, then increment n
- Output: 1, 2, 3

## Testing Strategy

1. Start with simple commands
2. Test expressions
3. Test conditions
4. Test single nesting (one comma)
5. Test double nesting (two commas)
6. Test 'and' separator
7. Test combination of comma and 'and'

## Command Syntax Reference

### Separators:
- `and` - Execute next statement in sequence
- `,` - Wrap everything on the LEFT in the structure on the RIGHT

### Example breakdown:
```
print 5 multiply by n if 5 modulus n equals 0 and increment n , loop 10 times
```

Parse right-to-left:
1. `loop 10 times` - outermost structure
2. Everything before comma goes inside loop
3. `increment n` - second statement (after `and`)
4. `print 5 multiply by n if 5 modulus n equals 0` - first statement

Equivalent pseudocode:
```
loop 10 times {
    if (5 % n == 0) {
        print 5 * n;
    }
    increment n;
}
```

## Note on Implementation

The current v3 implementation:
- ✅ Parses and executes expressions (multiply, modulus, plus, minus, divided by)
- ✅ Evaluates conditions (equals, greater than, less than, not equals)
- ✅ Handles 'and' separator for sequential execution
- ✅ Handles comma for nesting structures
- ✅ Supports loop N times
- ✅ Supports if condition
- ✅ Variables with store/show/increment
- ✅ Conditional print (print expr if condition)

## Correct Test Sequence

Test in this order to verify functionality:

1. `store 5 in x` - Variable storage
2. `show x` - Should show: x = 5
3. `print 10` - Should print: 10
4. `print 5 multiply by 2` - Should print: 10
5. `store 5 in n` then `print 10 modulus n` - Should print: 0
6. `print 10 if 5 equals 5` - Should print: 10
7. `store 0 in x` then `increment x` then `show x` - Should show: x = 1
8. `store 1 in n` then `increment n , loop 3 times` then `show n` - Should show: n = 4
9. `store 1 in n` then `print n if n greater than 0 and increment n , loop 3 times`

## Final Complex Example

```
store 1 in n
print 5 multiply by n if 5 modulus n equals 0 and increment n , loop 10 times
show n
```

**Expected:**
- Loops 10 times
- Each iteration: checks if 5 % n == 0, prints 5*n if true, then increments n
- n goes from 1 to 11
- Should print 5 when n=1 (5%1=0), then 25 when n=5 (5%5=0), then 5 when n=10? (5%10=5, no)
- Final n = 11

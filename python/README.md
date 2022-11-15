# Python

### Table of Content
* [General Commands](#general-commands)
* [Strings](#strings)
* [Bytes](#bytes)
* [Script Console](#script-console)
* [Links](#links)

## General Commands
```
type(var) --> returns the type of the variable
help(str) --> like man in bash
```

## Strings
Multi line string:
```
str_var="""multi
line
string"""
```

Escape character:
```
str_var="The character \" is escaped and will be shown at print"
```

Raw string: (to avoid escaping with backslash)
```
str_var=r'c:\path\to\file'
```

## Bytes
Similar to strings but instead of being sequences of Unicode code they are sequences of bytes.  
  
Define a byte:
```
some_byte=b'some byte'
```

Example code decoding bytes to unicode from the web:
```
from urllib.request import urlopen
story = urlopen('https://sixty-north.com/c/t.txt')
story_words = []
for line in story:
	line_words = line.decode('utf8').split()
	for word in line_words:
		story_words.append(word)
```

## Script Console

```
tracemalloc to debug memory leak (see allocations)
objgraph to debug memory leak (find reference -> holding the object consuming memory)
```

## Links
* [built in functions](https://docs.python.org/3/library/functions.html)

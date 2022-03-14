Bash
===========

<!--ts-->
  * [Process commands](#process-commands)
  * [Search directories](#search-directories)
  * [Substrings](#substrings)
  * [Regular expressions](#regular-expressions)
  * [References](#references)
  * [Links](#links)
<!--te-->

Process commands
====
Find process full command. [Taken from here](https://unix.stackexchange.com/questions/163145/how-to-get-whole-command-line-from-a-process).
```
process_full_command=$(ps -p [PID] -o args)
echo $process_full_command
```

Search directories
===
```
find . \
     -path "./.config/dir1" -prune -o \
     -name ".test" -prune -o \
     -type f -print0 |
  xargs -0 grep -io pattern

grep -R -i <pattern> --exclude-dir="dir1" --exclude-dir="dir2"
```

Substrings
====
```
# Taken from https://github.com/bobbyiliev/introduction-to-bash-scripting/blob/main/ebook/en/content/008-bash-arrays.md
letters=( "A""B""C""D""E" ) 
echo "${letters:2:3}"  --> returns CDE
```

Regular expressions
===
```
## Expressions
[:alnum:]  --> all alphanumeric characters (upper+lower+digits)
[:digit:]  --> digits
[:lower:]  --> lower
[:upper:]  --> upper
[!abc...]  --> match the opposite of the characters listed in the brackets 
?          --> match any single character
```
```
## Examples
sed 's/[^[:upper:] ,.]//g'  --> removes all the characters that are not (upper whitespace comma or dot)
```

References
===
```
$?    --> last command status code
$#    --> number of provided arguments
$*    --> all provided arguments as a string
$@    --> all provided arguments as an array
$0    --> the running script way to call its filename
$$    --> the running process PID
$EUID --> Current userID (root user ID is 0)
```

Links
====
* [ShellCheck locally](https://github.com/koalaman/shellcheck)
* [jq manual](https://stedolan.github.io/jq/manual/)
* [Quiz API- to create a fun quiz tool](https://quizapi.io/docs/1.0/overview)
* [Parser for nginx/apache logs](https://github.com/bobbyiliev/introduction-to-bash-scripting/blob/main/ebook/en/content/020-nginx-and-apache-log-parser.md)
* [Sed Examples](https://linuxhint.com/50_sed_command_examples/#s43).
* [Conditional Expressions](https://github.com/bobbyiliev/introduction-to-bash-scripting/blob/main/ebook/en/content/009-bash-conditional-expressions.md)
* [Simple Case example](https://github.com/bobbyiliev/introduction-to-bash-scripting/blob/main/ebook/en/content/010-bash-conditionals.md#switch-case-statements)
* Shell Colors:
  * [Detailed #1](https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux).
  * [Detailed #2](https://unix.stackexchange.com/questions/148/colorizing-your-terminal-and-shell-environment).
  * [POSIX Compatability](https://unix.stackexchange.com/questions/461071/color-codes-for-echo-dont-work-when-running-a-script-over-ssh).
* [$* vs $@](https://unix.stackexchange.com/questions/41571/what-is-the-difference-between-and#94135)
* [Install Fonts](https://www.linuxhowto.net/install-nerd-fonts-to-add-glyphs-in-your-code-on-linux/)
* [Shift command exaplin](https://www.geeksforgeeks.org/shift-command-in-linux-with-examples/)
* [source a file with curl](https://stackoverflow.com/questions/10520605/bashs-source-command-not-working-with-a-file-curld-from-internet)
* [lima + nerdctl](https://medium.com/@oribenhur/a-better-alternative-for-docker-desktop-3e8fa38d618)
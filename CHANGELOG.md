## 0.11.0
* improve reporting of WD issues (thanks @leuschel)

## 0.10.0
* improved call to ProB binary (thanks @leuschel)
* improved some regular expressions used to capture errors (thanks @leuschel)

## 0.9.0
* support changed output format of ProB 1.8.3

## 0.8.3
* support new ProB error message format (version 1.8.1)

## 0.8.2
* remove duplicate keys for snippets

## 0.8.0
* update rules grammar and snippets

## 0.7.1
* fix for newer ProB versions: remove colorized console output before applying regex

## 0.7.0
* switch to linter v2

## 0.6.0
* windows support (pull request by @dohan)
* new snippets

## 0.5.3
* fix broken snippet, fixes preferences view

## 0.5.2
* fixed error detection in case of unexpected newlines (pull request by @dohan)

## 0.5.1
* improved syntax highlighting for newer ProB versions (pull request by @dohan)

## 0.5.0
* improved syntax highlighting (pull request by @dohan)
* additional keywords for rule machines (pull request by @dohan)

## 0.4.2
* fix error reporting in case of multiple errors in the same file (pull request by @dohan)

## 0.4.1
* fix parsing of type errors
* improve performance
* fix off-by-one error in positions

## 0.4.0
* fix parsing of error messages reported by ProB versions > 1.5.1-beta6

## 0.3.3
* fix missing file type for refinements (pull request by @dohan)

## 0.3.2
* add / fix line comments

## 0.3.1
* fix reporting of parser errors reported by ProB CLI without position information

## 0.3.0
* added linter / reporting of parse and type errors using ProB CLI

## 0.2.2
* autocomplete for relations and functions

## 0.2.1
* license and keywords added

## 0.2.0
* support for Atelier-B Unicode format
* some bugfixes in classical B highlighter

## 0.1.6
* highlighting for records
* merge pull requests by @dohan:
  * autocomplete for VARIABLES, CONSTANTS and ASSERTIONS clauses
  * several fixes to syntax highlighting

## 0.1.5
* more improvements to highlighting of operators

## 0.1.4
* autocomplete snippets for SELECT and CASE
* fix highlighting of integer constants
* fix issue 5: or (and others) when part of identifiers
* fix issue 6: highlighting of assignment operators

## 0.1.3
* autocomplete snippet for PRE, VAR, ANY, LET, IF, IF ELSE, CHOICE
* follow naming conventions more strictly
* fix issue 1: do not highlight keywords in strings
* fix issue 2: highlight machine keyword

## 0.1.2
* intermediate release after renaming the package

## 0.1.1
* add language snippet for while substitution

## 0.1.0 - First Release
* basic support for classical B

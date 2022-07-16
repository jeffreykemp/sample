As per: https://www.json.org/

* [JSON Syntax diagram](diagram.html)
* [EBNF Syntax](json.ebnf)

```
json ::= object | array

object ::= '{' member ( ',' member )* '}'

array ::= '[' element ( ',' element )* ']'

member ::= string ':' element

element ::= string
          | number
          | object
          | array
          | 'true'
          | 'false'
          | 'null'

string ::= '"' ( [^"\] | escape )* '"'                                             /* ws: explicit */

escape ::= '\' ( ["\/bnfrt] | 'u' hex hex hex hex )                                /* ws: explicit */

hex ::= [0-9A-Fa-f]                                                                /* ws: explicit */

number ::= '-'? ( [1-9] [0-9]* | '0' ) ( '.' [0-9]+ )? ( [eE] [-+]? [0-9]+ )?      /* ws: explicit */
```

Whitespace is implicit in the rules above, except when otherwise indicated (`ws: explicit`). Whitespace in JSON is:
```
ws ::= #x9 | #xA | #xD | #x20
```

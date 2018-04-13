start: stmts;
@stmts: stmt*;
@stmt: simple_stmt_list | block_stmt | empty_stmt ;
@simple_stmt_list: simple_stmt_list2 NL?;
@simple_stmt_list2: simple_stmt ';'? | simple_stmt ';' simple_stmt_list2;
@simple_stmt: print|flow|assert|expr_list|assign;
@block_stmt: if_statm | while | for | funcdef;
?empty_stmt: NL | LCURLY NL? RCURLY;
name_list : NAME COMMA?
          | NAME COMMA name_list
          | LPAREN name_list RPAREN
          ;
?var_list  : var ','?
          | var ',' var_list
          | LPAREN var_list RPAREN
          | LBRACK var_list RBRACK
          ;

assert: ASSERT '\(' expr (',' expr)? '\)';

assign: NAME ASSIGNS expr
      | NAME ASSIGNS assign
      ;
print: PRINT (expr_list)?;
@flow: return  | break | continue;
break    : BREAK;
continue    : CONTINUE;
return: RETURN expr_list?;
@code_block: LCURLY NL? stmts NL? RCURLY;
suite: NL? code_block | simple_stmt_list;
if_statm  : IF '\(' expr '\)' suite
      ( ELIF expr suite )*
      ( ELSE suite )?
    ;
while: WHILE '\(' expr '\)' suite (ELSE suite)?;
for: FOR LPAREN var_list IN iterable RPAREN suite (ELSE suite)?;
funcdef: NAME '<--' FUNCTION LPAREN param_list RPAREN suite ;
param_list: simple_param_list
          | (def_param ',')+ simple_param_list
          ;
@simple_param_list: def_param ','?
               | MUL NAME (',' POW NAME)?
               | POW NAME
               |
               ;
def_param: (NAME | LPAREN name_list RPAREN) ('<-' expr)? ;
@expr : bin_expr
      | un_expr
      | funccall
      | var
      | value
      | inline_if
      ;
?expr_list: expr ','?
         | expr ',' expr_list
         ;
var: NAME
   | attrget
   | itemget
   ;
funccall: expr LPAREN (arg_list) RPAREN ;
arg_list: simple_arg_list
       | arg ',' arg_list
       | expr ',' arg_list
       ;
@simple_arg_list: arg ','?
               | expr ','?
               | MUL expr (',' POW expr)?
               | POW expr
               | ;

arg: NAME '<-' expr;
itemget: expr LBRACK (expr) RBRACK ;
attrget: expr DOT NAME;
?un_expr: '-' expr
        | '\+' expr
        | '\~' expr
        | NOT expr;
?bin_expr: (expr OR )? and_expr;
?and_expr: (and_expr AND )? rel_expr;
?rel_expr: (rel_expr rel_symbol)? add_expr;
?add_expr: (add_expr add_symbol)? mul_expr;
?mul_expr: (mul_expr mul_symbol)? spec_expr;
?spec_expr: (spec_expr spec_symbol)? pow_expr;
?pow_expr: (pow_expr POW)? value;

add_symbol: '\+' | '-';
mul_symbol: '\*' | '/';
spec_symbol: MOD | FDIV;
rel_symbol: GTE | LTE | GT | LT | EQ | NEQ;
@value: number
     | string
     | list
     | tuple
     | dict
     | set
     | repr_expr
     | bool
     | '\(' expr '\)'
     | var;
?iterable: list
        | string
        | range;
range: number ':' number ;
number: DEC_NUMBER | HEX_NUMBER | OCT_NUMBER | FLOAT_NUMBER | IMAG_NUMBER | INT_NUMBER ;
?list : LBRACK (list_inner)? RBRACK ;
tuple: LPAREN (list_inner)? RPAREN ;
?list_inner	: expr | expr COMMA (expr (COMMA)? )* ;
set  : LCURLY list_inner RCURLY ;
dict : LCURLY dict_inner RCURLY ;
dict_inner  : (expr ':' expr (COMMA)? )* ;
repr_expr: '`' expr_list '`';
bool: TRUE | FALSE;

inline_if: IF LPAREN expr RPAREN simple_stmt ELSE simple_stmt;
safe_expr_list: safe_expr ','?
              | safe_expr ',' safe_expr_list
              ;
safe_expr: bin_expr
         | un_expr
         | funccall
         | var
         | LPAREN safe_expr RPAREN
         | value
         ;
string: (STRING|LONG_STRING) string? ;
INT_NUMBER: '[0-9]+';
DEC_NUMBER: '[1-9]\d*[lL]?';
HEX_NUMBER: '0[xX][\da-fA-F]*[lL]?';
OCT_NUMBER: '0[0-7]*[lL]?';
FLOAT_NUMBER: '((\d+\.\d*|\.\d+)([eE][-+]?\d+)?|\d+[eE][-+]?\d+)';
IMAG_NUMBER: '(\d+[jJ]|((\d+\.\d*|\.\d+)([eE][-+]?\d+)?|\d+[eE][-+]?\d+)[jJ])';
STRING : 'u?r?("(?!"").*?(?<!\\)(\\\\)*?"|\'(?!\'\').*?(?<!\\)(\\\\)*?\')' ;
LONG_STRING : '(?s)u?r?(""".*?(?<!\\)(\\\\)*?"""|\'\'\'.*?(?<!\\)(\\\\)*?\'\'\')'
    (%newline)
    ;
LPAREN: '\(';
RPAREN: '\)';
LBRACK: '\[';
RBRACK: '\]';
LCURLY: '\{';
RCURLY: '\}';
COLON: ':';
SEMICOLON: ';';
VBAR: '\|';
AT: '@';
COMMA: ',';
ASSIGNS: '<-';
LTE: '<=';
LT: '<';
GTE: '>=';
GT: '>';
EQ: '==';
NEQ: '!=';
MOD: '%%';
DOT: '\.';
DIV: '/';
MUL: '\*';
POW: '\^';
FDIV: '%/%';
SHL: '\<\<';
SHR: '\>\>';
ELLIPSIS: '(?<=(\[|,))\.\.\.';


NL: '(\r?\n[\t ]*)+'
    (%newline)
    ;

WS: '[\t \f]+' (%ignore);
LINE_CONT: '\\[\t \f]*\r?\n' (%ignore) (%newline);
NAME: '[a-zA-Z_][a-zA-Z_0-9]*(?!r?"|r?\')'  //"
    (%unless
        PRINT: 'print';
        FUNCTION: 'function';
        ASSERT: 'assert';
        AS: 'as';
        CLASS: 'class';
        FINALLY: 'finally';
        IF: 'if';
        ELIF: 'elif';
        ELSE: 'else';
        FOR: 'for';
        WHILE: 'while';
        BREAK: 'break';
        CONTINUE: 'continue';
        RETURN: 'return';
        AND: 'and';
        OR: 'or';
        NOT: 'not';
        IS: 'is';
        IN: 'in';
        TRUE: 'true';
        FALSE: 'false';
    );
PLUS: '\+';
MINUS: '-';
%newline_char: '\n';
COMMENT: '\#[^\n]*' (%ignore);
NEWLINE: '\n' (%ignore);
import operator as op
from plyplus import Grammar, STransformer

calc_grammar = Grammar("""
    @start: assign;
    // Rules
    ?assign: (id eq_symbol)? logic;
    ?logic: (logic logic_symbol)? add;
    ?add: (add add_symbol)? mul;
    ?mul: (mul mul_symbol)? atom;
    @atom: neg | number | '\(' add '\)' | boolean | id;
    neg: '-' atom;
    // Tokens
    number: '[\d.]+';
    eq_symbol: '<-';

    boolean : true | false;
    true: TRUE;
    false: FALSE;
    logic_symbol: '\&' | '\|';

    id: ID;
    ID: '\w+'
    (%unless
    TRUE: 'TRUE';
    FALSE: 'FALSE';
    );

    mul_symbol: '\*' | '/';
    add_symbol: '\+' | '-';


    WS: '[ \t]+' (%ignore);
""")


class Calc(STransformer):

    def _bin_operator(self, exp):
        arg1, operator_symbol, arg2 = exp.tail
        operator_func = {'+': op.add, '-': op.sub, '*': op.mul, '/': op.div, '&': op.and_, '|': op.or_}[
            operator_symbol]
        return operator_func(arg1, arg2)

    def _assignment(self, exp):
        arg1, operator_symbol, arg2 = exp.tail
        return arg2


    number = lambda self, exp: float(exp.tail[0])
    neg = lambda self, exp: -exp.tail[0]
    boolean = lambda self, node: node.tail[0] == 'TRUE'
    var = lambda self, exp: exp.tail[0]
    __default__ = lambda self, exp: exp.tail[0]

    bin_expr = _bin_operator
    assign = _assignment


def main():
    calc = Calc()
    while True:
        try:
            s = raw_input('> ')
        except EOFError:
            break
        if s == '':
            break
        tree = calc_grammar.parse(_read('sample.r'))
        # tree.to_png_with_pydot('list_parser_tree.png')
        print(calc.transform(tree))


main()

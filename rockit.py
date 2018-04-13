from __future__ import absolute_import, print_function
from io import open

import unittest
import time
import sys, os, glob
import logging

from plyplus import grammars, common
from plyplus.plyplus import Grammar
from plyplus import STransformer
import operator as op
from plyplus.common import TokValue

logging.basicConfig(level=logging.INFO)

CUR_PATH = os.path.split(__file__)[0]
names = {}


class RParser(STransformer):
    def _bin_operator(self, exp):
        arg1, operator_symbol, arg2 = exp.tail
        print(type(arg1), arg2)

        if type(arg1) == TokValue:
            arg1 = names[str(arg1)]
        if type(arg2) == TokValue:
            arg2 = names[str(arg2)]

        operator_func = {'+': op.add, '-': op.sub, '*': op.mul, '/': op.div, 'and': op.and_, 'or': op.or_, '>': op.gt,
                         '<': op.lt, '>=': op.ge, '<=': op.le, '==': op.eq, '!=': op.ne, '**': op.pow,
                         '//': op.floordiv
                         }[operator_symbol]
        return operator_func(arg1, arg2)

    def _assignment(self, exp):
        var_name, value = exp.tail
        names[var_name] = value
        return value

    def _if(self, exp):
        _if_tok, expr, suite = exp.tail[0]
        if expr:
            return expr
        else:
            return

    number = lambda self, exp: float(exp.tail[0])
    neg = lambda self, exp: -exp.tail[0]
    bool = lambda self, node: node.tail[0] == 'true'
    var = lambda self, exp: exp.tail[0]  # if str(exp.tail[0]) not in names.keys() else names[str(exp.tail[0])]
    __default__ = lambda self, exp: exp.tail[0]

    bin_expr = _bin_operator
    # arg = _assignment
    assign = _assignment
    if_expr = _if


def _read(n, *args):
    kwargs = {'encoding': 'iso-8859-1'}
    with open(os.path.join(CUR_PATH, n), *args, **kwargs) as f:
        return f.read()


if os.name == 'nt':
    if 'PyPy' in sys.version:
        PYTHON_LIB = os.path.join(sys.prefix, 'lib-python', sys.winver)
    else:
        PYTHON_LIB = os.path.join(sys.prefix, 'Lib')
else:
    PYTHON_LIB = [x for x in sys.path if x.endswith('%s.%s' % sys.version_info[:2])][0]

# print(os.getcwd())
with grammars.open(os.getcwd()+'/grammar.g') as g:
    g = Grammar(g)

p = RParser()
tree = g.parse(_read('sample.r'))


tree.to_png_with_pydot('list_parser_tree.png')
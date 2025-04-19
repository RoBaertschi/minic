package ast

import "../lexer"

Operator_Type :: enum {
    Add,
    Sub,
    Mult,
    Div,
}

Base_Expression :: struct {
    token: lexer.Token,
}

Operator_Expression :: struct {
    using base: Base_Expression, // Token refers to the operator
    type: Operator_Type,
    operands: []Expression,
}

Call_Expression :: struct {
    using base: Base_Expression, // Token refers to the identifier
    identifier: string,
    arguments: []Expression,
}

Expression :: union #no_nil {
    Operator_Expression,
    Call_Expression,
}

File :: struct {
    expressions: []Expression,
}

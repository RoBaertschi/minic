package ast

Operator_Type :: enum {
    Add,
    Sub,
    Mult,
    Div,
}

Operator_Expression :: struct {
    type: Operator_Type,
    operands: []Expression,
}

Call_Expression :: struct {
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

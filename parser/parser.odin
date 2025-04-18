package parser

import "../ast"
import "../lexer"
import "core:fmt"
import "core:strings"
import "core:mem"

// A hard error, something that should make the program clean and exit, this does not indicate a parser error but a other runtime error
Error :: union {
    mem.Allocator_Error,
}

Error_Callback :: #type proc(offending_token: lexer.Token, fmt: string, args: ..any)

default_error_callback :: proc(offending_token: lexer.Token, format: string, args: ..any) {
	loc := offending_token.loc
	fmt.eprintf("%s(%d:%d) Parser Error: ", loc.file, loc.line, loc.column)
	fmt.eprintf(format, ..args)
	fmt.eprintf("\n")
}

Parser :: struct {
	// Immutable
	l:              lexer.Lexer,

	// State
	cur_token:      lexer.Token,
	peek_token:     lexer.Token,
	error_callback: Error_Callback,

	// Mutable
	errors:         int,
}

init :: proc(p: ^Parser, l: lexer.Lexer, error_callback := default_error_callback) {
	p.l = l
	p.errors = 0
	p.error_callback = error_callback
	next_token(p)
	next_token(p)
}

destroy :: proc(p: ^Parser) {
    lexer.destroy_token(p.cur_token)
    lexer.destroy_token(p.peek_token)
}


@(private)
next_token :: proc(p: ^Parser) {
    lexer.destroy_token(p.cur_token)
	p.cur_token = p.peek_token
	p.peek_token = lexer.next_token(&p.l)
}

error :: proc(p: ^Parser, format: string, args: ..any) {
	if p.error_callback != nil {
		p.error_callback(p.cur_token, format, ..args)
	}
	p.errors += 1
}

expect_peek :: proc(p: ^Parser, type: lexer.Token_Type) -> bool {
	return expect_peekf(p, type, "Expected \"%v\", got \"%v\".", type, p.peek_token.type)
}

expect_peekf :: proc(p: ^Parser, type: lexer.Token_Type, format := "", args: ..any) -> bool {
	if p.peek_token.type == type {
		next_token(p)
		return true
	}
	error(p, format, ..args)
	return false
}

expect_peek_string :: proc(p: ^Parser) -> (str: string, ok: bool, err: Error) {
	if p.peek_token.type == .Identifier {
		next_token(p)
		clone := strings.clone(p.cur_token.data.(string)) or_return
        return clone, true, nil
	}
	error(
		p,
		"Expected a \"%v\", but got \"%v\"",
		lexer.Token_Type.Identifier,
		p.peek_token.type,
	)
	return "", false, nil
}

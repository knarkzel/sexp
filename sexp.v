module main

import os
import strconv
import arrays

enum Literal {
	left_paren
	right_paren
	plus
}

struct Symbol {
	name string
}

struct Number {
	value f64
}

type Token = Literal | Number | Symbol

fn read(input string) ?[]Token {
	mut index := 0
	mut tokens := []Token{}
	for index < input.len {
		match input[index] {
			` ` {}
			`(` {
				tokens << Literal.left_paren
			}
			`)` {
				tokens << Literal.right_paren
			}
			`+` {
				tokens << Literal.plus
			}
			else {
				for i, c in input[index..] {
					if c == ` ` || c == `)` {
						token := input[index..index + i]
						if token.bytes().all(it.is_digit() || it == `.` || it == `-`) {
							tokens << Number{strconv.atof_quick(token)}
						} else {
							tokens << Symbol{token}
						}
						index += i - 1
						break
					}
				}
			}
		}
		index += 1
	}
	return tokens
}

// evalutes sexp
fn eval(input []Token) ?Token {
	end := find_matching(input) or { return none }
	method := input[1]
	rest := input[2..end]
	match method {
		Literal {
			if method == .plus {
				numbers := rest.map(match it {
					Number { it.value }
					else { 0 }
				})
				sum := arrays.sum<f64>(numbers) or { return none }
				return Number{sum}
			}
		}
		Symbol {}
		else {
			return none
		}
	}
	return none
}

fn find_matching(input []Token) ?int {
	mut parens := 0
	for i, token in input {
		match token {
			Literal {
				if token == .left_paren {
					parens += 1
				}
				if token == .right_paren {
					parens -= 1
				}
			}
			else {}
		}
		if parens == 0 {
			return i
		}
	}
	return none
}

fn main() {
	input := os.read_file('input.txt') ?.trim_space()
	tokens := read(input) ?
	output := eval(tokens) ?
	println(tokens)
	println(output)
}

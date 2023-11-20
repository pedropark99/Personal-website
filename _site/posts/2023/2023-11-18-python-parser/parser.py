from typing import Dict, Any
from typing import List
import re

EXPRESSION_EXAMPLES = [
    "'platform.blipraw.events'",
    '"blip" + "." + "events"',
    "database + \".\" + table_name",
    'f"{database}.{table_name}"'
]

is_not_blank = lambda x: x != "" and not re.search(r"^ +$", x)
def tokenizer(input_string: str) -> List[str]:
    candidates = ["'", '"', '+', '{', '}']
    break_points = list()
    for i in range(len(input_string)):
        current_char = input_string[i]
        if current_char in candidates:
            break_points.append(i)
        if current_char == "f" and (i + 1) < len(input_string):
            next_char = input_string[i + 1]
            if next_char in ['"', "'"]:
                break_points.append(i)

    if len(break_points) == 0:
        return [input_string]

    tokens = list()
    last_index = 0
    for index in break_points:
        tokens.append(input_string[last_index:index])
        tokens.append(input_string[index:(index+1)])
        last_index = index + 1

    tokens.append(input_string[last_index:])
    return list(filter(is_not_blank, tokens))



class ParserCache:
    '''Class that represents a cache to store the current state of the parser.'''
    def __init__(self, tokens: List[str]) -> None:
        self.tokens = tokens
        self.current_index = 0
        self.ast = list()
        if len(tokens) > 0:
            self.current_token = tokens[self.current_index]
        else:
            self.current_token = None
        return

    def len(self) -> int:
        return len(self.tokens)

    def current_token(self) -> str:
        return self.current_token

    def next_token(self) -> None:
        self.current_index += 1
        if self.current_index < len(self.tokens):
            self.current_token = self.tokens[self.current_index]
        return


def parse(input_string: str) -> List[Dict[str, Any]]:
    tokens = tokenizer(input_string)
    parser_cache = ParserCache(tokens)
    parsing_result = _parse_input(parser_cache)
    return parsing_result.ast


def _parse_input(parser_cache: ParserCache) -> ParserCache:
    if parser_cache.len() == 0:
        return parser_cache

    if parser_cache.current_token() in ['"', "'"]:
        parser_cache = _parse_string(parser_cache)
    elif parser_cache.current_token() == '+':
        parser_cache = _parse_addition(parser_cache)
    else:
        parser_cache = _parse_identifier(parser_cache)

    parser_cache.next_token()
    if parser_cache.current_index <= parser_cache.len() - 1:
        parser_cache = _parse_input(parser_cache)

    return parser_cache


def _parse_identifier(parser_cache: ParserCache) -> ParserCache:
    parser_cache.ast.append({
        'type': 'IDENTIFIER',
        'value': str(parser_cache.current_token())
    })
    return parser_cache


def _parse_addition(parser_cache: ParserCache) -> ParserCache:
    left_operand = parser_cache.ast[-1]
    del parser_cache.ast[-1]
    parser_cache.next_token()
    right_operand = parser_cache.current_token()
    parser_cache.ast.append({
        'type': 'ADDITION',
        'left': left_operand,
        'right': right_operand
    })
    return parser_cache



def _parse_string(parser_cache: ParserCache) -> ParserCache:
    parser_cache.next_token()

    stack = list()
    while parser_cache.current_index < parser_cache.len() - 1:
        if parser_cache.current_token() in ['"', "'"]:
            break
        if parser_cache.current_token() == '{':
            parser_cache.next_token()
            parser_cache = _parse_formatted_string(parser_cache)
            continue

        stack.append(current_token)
        parser_cache.next_token()
    
    parser_cache.ast.append({
        'type': 'STRING',
        'value': stack
    })

    return parser_cache


def _parse_formatted_string(parser_cache: ParserCache) -> ParserCache:
    stack = list()
    while parser_cache.current_index < parser_cache.len() - 1:
        if parser_cache.current_token() == '}':
            parser_cache.next_token()
            break
        stack.append(parser_cache.current_token())
        parser_cache.next_token()

    parsing_subexpression = ParserCache(stack)
    parsing_subexpression = _parse_input(parsing_subexpression)
    parser_cache.ast.append({
        'type': 'EXPR',
        'value': parsing_subexpression.ast
    })

    return parser_cache
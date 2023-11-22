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
        self.ast = list()
        self.tokens = tokens
        self.index = 0
        if len(tokens) > 0:
            self.token = tokens[self.index]
        else:
            self.token = None
        return

    def len(self) -> int:
        return len(self.tokens)

    def current_token(self) -> str:
        return self.token
    
    def current_index(self) -> int:
        return self.index

    def next_token(self) -> None:
        self.index += 1
        if self.index < len(self.tokens):
            self.token = self.tokens[self.index]
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
    if parser_cache.current_index() <= parser_cache.len() - 1:
        parser_cache = _parse_input(parser_cache)

    return parser_cache


def _parse_identifier(parser_cache: ParserCache) -> ParserCache:
    parser_cache.ast.append({
        'type': 'IDENTIFIER',
        'value': str(parser_cache.current_token()).strip()
    })
    return parser_cache


def _parse_addition(parser_cache: ParserCache) -> ParserCache:
    left_operand = parser_cache.ast[-1]
    del parser_cache.ast[-1]
    parser_cache.next_token()
    right_operand = _parse_right_operand(parser_cache)
    parser_cache.ast.append({
        'type': 'ADDITION',
        'left_operand': left_operand,
        'right_operand': right_operand
    })
    return parser_cache

def _parse_right_operand(parser_cache: ParserCache) -> ParserCache:
    stack = list()
    while parser_cache.current_index() <= parser_cache.len() - 1:
        if parser_cache.current_token() == "+":
            parser_cache.next_token()
            temp_parse_cache = ParserCache(stack)
            parsed_left_operand = _parse_input(temp_parse_cache)
            right_operand = _parse_right_operand(parser_cache)
            return {
                'type': 'ADDITION',
                'left_operand': parsed_left_operand.ast[0],
                'right_operand': right_operand
            }

        stack.append(parser_cache.current_token())
        parser_cache.next_token()
    
    temp_parse_cache = ParserCache(stack)
    parsed_right_operand = _parse_input(temp_parse_cache)
    return parsed_right_operand.ast[0]
    

def _parse_string(parser_cache: ParserCache) -> ParserCache:
    char_that_opens_the_string = parser_cache.current_token()
    parser_cache.next_token()
    # Add a placeholder in the top of the AST
    parser_cache.ast.append({
        'type': 'STRING',
        'value': list()
    })

    while parser_cache.current_index() < parser_cache.len() - 1:
        if parser_cache.current_token() in ['"', "'"]:
            break
        if parser_cache.current_token() == '{':
            parser_cache.next_token()
            parser_cache = _parse_formatted_string(parser_cache)
            continue
        
        elem_ref = parser_cache.ast[-1]
        elem_ref['value'].append(parser_cache.current_token())
        parser_cache.next_token()
    
    return parser_cache


def _parse_formatted_string(parser_cache: ParserCache) -> ParserCache:
    stack = list()
    while parser_cache.current_index() < parser_cache.len() - 1:
        if parser_cache.current_token() == '}':
            parser_cache.next_token()
            break
        stack.append(parser_cache.current_token())
        parser_cache.next_token()

    parsed_subexpression = ParserCache(stack)
    parsed_subexpression = _parse_input(parsed_subexpression)
    elem_ref = parser_cache.ast[-1]
    elem_ref['value'].append({
        'type': 'EXPR',
        'value': parsed_subexpression.ast
    })
    return parser_cache


for example in EXPRESSION_EXAMPLES:
    parsed_expr = parse(example)
    print("====================================")
    print("  * Input expression: ", example)
    print("  * Parsed AST: ", parsed_expr)
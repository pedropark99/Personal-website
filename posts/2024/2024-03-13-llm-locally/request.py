import requests
import json
import re

url = 'http://localhost:11434/api/generate'
body = '{"model": "codellama:7b", "prompt": "Write me a function that outputs the fibonacci sequence"}'
def parse_response(resp: str) -> dict:
    resp = resp.content.decode("utf-8")
    resp = re.sub(r'\}\n\{', '},\n{', resp)
    resp = f'[{resp}]'
    return json.loads(resp)

r = requests.post(url, data = body)
r = parse_response(r)
t = list()
for token in r:
    t.append(token['response'])

print(''.join(t))
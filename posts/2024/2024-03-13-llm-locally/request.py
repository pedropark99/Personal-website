import requests
import json
import re

url = 'http://localhost:11434/api/generate'
body = '{"model": "codellama:7b", "prompt": "Write me a function that outputs the fibonacci sequence"}'


r = requests.post(url, data = body)
r = str(r.content)
r = r'[' + r + r']'
r = re.sub(r'\}\n\{', '},\n{', r)
print(r)
print(type(r))
print(json.loads(r))

t = list()
for token in r:
    t.append(token['response'])

print(''.join(t))
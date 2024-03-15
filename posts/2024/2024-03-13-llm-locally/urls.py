import requests
import json


url = 'http://localhost:11434/api/generate'
body = '{"model": "codellama:7b", "prompt": "Write me a function that outputs the fibonacci sequence"}'


r = requests.post(url, data = body)

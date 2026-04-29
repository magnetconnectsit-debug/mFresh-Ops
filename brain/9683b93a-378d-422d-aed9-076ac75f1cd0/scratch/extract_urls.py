import json
import re

log_path = r'C:\Users\ASUS\.gemini\antigravity\brain\9683b93a-378d-422d-aed9-076ac75f1cd0\.system_generated\logs\overview.txt'
urls = set()

with open(log_path, 'r', encoding='utf-8') as f:
    for line in f:
        try:
            data = json.loads(line)
            content = data.get('content', '')
            found = re.findall(r'https://opsapitest.magnetconnects.com/public/api/[a-zA-Z0-9_-]+', content)
            urls.update(found)
        except:
            pass

for url in sorted(urls):
    print(url)

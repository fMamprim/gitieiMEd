import os
import re
import html

input_dir = r'c:\Users\felip\Documents\gitieiMEd\modloader\Prioridade 100\ext'
output_dir = r'c:\Users\felip\Documents\gitieiMEd\modloader\Prioridade 100\help_md'

if not os.path.exists(output_dir):
    os.makedirs(output_dir)

def html_to_md(html_content):
    # Extract body content if possible
    body_match = re.search(r'<body.*?>(.*?)</body>', html_content, flags=re.IGNORECASE | re.DOTALL)
    if body_match:
        text = body_match.group(1)
    else:
        text = html_content
    
    # Strip scripts and styles
    text = re.sub(r'<script.*?>.*?</script>', '', text, flags=re.IGNORECASE | re.DOTALL)
    text = re.sub(r'<style.*?>.*?</style>', '', text, flags=re.IGNORECASE | re.DOTALL)
    
    # Basic replacements
    text = re.sub(r'<h[1-3].*?>(.*?)</h[1-3]>', r'\n\n# \1\n\n', text, flags=re.IGNORECASE | re.DOTALL)
    text = re.sub(r'<h[4-6].*?>(.*?)</h[4-6]>', r'\n\n## \1\n\n', text, flags=re.IGNORECASE | re.DOTALL)
    text = re.sub(r'<p.*?>(.*?)</p>', r'\n\n\1\n\n', text, flags=re.IGNORECASE | re.DOTALL)
    text = re.sub(r'<br\s*/?>', r'\n', text, flags=re.IGNORECASE)
    text = re.sub(r'<li.*?>(.*?)</li>', r'\n- \1', text, flags=re.IGNORECASE | re.DOTALL)
    text = re.sub(r'<(b|strong).*?>(.*?)</\1>', r'**\2**', text, flags=re.IGNORECASE | re.DOTALL)
    text = re.sub(r'<(i|em).*?>(.*?)</\1>', r'*\2*', text, flags=re.IGNORECASE | re.DOTALL)
    text = re.sub(r'<a href=\"?(.*?)\"?>(.*?)</a>', r'[\2](\1)', text, flags=re.IGNORECASE | re.DOTALL)
    
    # Remove all remaining tags
    text = re.sub(r'<[^>]+>', '', text)
    
    # Unescape html entities
    text = html.unescape(text)
    
    # Clean up whitespace
    text = re.sub(r'\n{3,}', '\n\n', text)
    return text.strip()

count = 0
for root, _, files in os.walk(input_dir):
    for file in files:
        if file.lower().endswith(('.htm', '.html')):
            in_path = os.path.join(root, file)
            rel_path = os.path.relpath(root, input_dir)
            
            out_root = os.path.join(output_dir, os.path.dirname(rel_path))
            if not os.path.exists(out_root):
                os.makedirs(out_root)
                
            out_path = os.path.join(out_root, os.path.splitext(file)[0] + '.md')
            
            try:
                with open(in_path, 'r', encoding='utf-8', errors='ignore') as f_in:
                    html_content = f_in.read()
                
                md_content = html_to_md(html_content)
                
                with open(out_path, 'w', encoding='utf-8') as f_out:
                    f_out.write(md_content)
                count += 1
            except Exception as e:
                print(f'Error processing {file}: {e}')

print(f'Converted {count} files successfully!')

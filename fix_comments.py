import json
import subprocess

def get_annotations(start, end):
    cmd = ["./z80bench-cli", "annotation", "list-range", ".", hex(start), hex(end)]
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        return []
    try:
        data = json.loads(result.stdout)
        return data.get("annotations", [])
    except json.JSONDecodeError:
        annotations = []
        for line in result.stdout.strip().split('\n'):
            if line:
                entry = json.loads(line)
                if "annotations" in entry: return entry["annotations"]
                annotations.append(entry)
        return annotations

annotations = get_annotations(0x2603, 0x268C)
batch_commands = []

for ann in annotations:
    addr = ann["addr"]
    comment = ann["comment"]
    if not comment: continue
    
    # Strip any existing leading semicolons from each line first
    lines = [line.lstrip(';').lstrip() for line in comment.split('\n')]
    
    # Reconstruct with ; for subsequent lines
    new_comment_lines = [lines[0]]
    for line in lines[1:]:
        new_comment_lines.append(f"; {line}")
    
    new_comment = "\\n".join(new_comment_lines)
    batch_commands.append(f'annotation set {addr} comment "{new_comment}"')

if batch_commands:
    with open("fix_batch.txt", "w") as f:
        f.write("\n".join(batch_commands) + "\n")
    print(f"Generated {len(batch_commands)} commands in fix_batch.txt")

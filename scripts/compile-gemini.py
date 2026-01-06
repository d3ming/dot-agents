#!/usr/bin/env python3
import os
import re
import sys

# Configuration
PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TEMPLATE_DIR = os.path.join(PROJECT_ROOT, 'gemini', 'templates', 'commands')
OUTPUT_DIR = os.path.join(PROJECT_ROOT, 'gemini', '.gemini', 'commands')

def resolve_path(path_ref):
    """Resolves a file path reference. 
    Supports absolute paths or relative to PROJECT_ROOT."""
    if os.path.isabs(path_ref):
        return path_ref
    return os.path.join(PROJECT_ROOT, path_ref)

def process_file(filename):
    src_path = os.path.join(TEMPLATE_DIR, filename)
    dest_path = os.path.join(OUTPUT_DIR, filename)

    print(f"Processing {filename}...")
    
    try:
        with open(src_path, 'r') as f:
            content = f.read()
    except FileNotFoundError:
        print(f"  ❌ Template not found: {src_path}")
        return

    # Regex to find @{path/to/file}
    # Matches @{ ... }
    pattern = re.compile(r'@\{([^}]+)\}')
    
    def replacer(match):
        ref_path = match.group(1).strip()
        abs_path = resolve_path(ref_path)
        
        if not os.path.exists(abs_path):
            print(f"  ⚠️  Warning: Referenced file not found: {abs_path}")
            return f"[MISSING: {ref_path}]"
        
        try:
            with open(abs_path, 'r') as f:
                return f.read()
        except Exception as e:
            print(f"  ❌ Error reading {abs_path}: {e}")
            return f"[ERROR reading {ref_path}]"

    new_content = pattern.sub(replacer, content)

    # Write to output
    os.makedirs(os.path.dirname(dest_path), exist_ok=True)
    with open(dest_path, 'w') as f:
        f.write(new_content)
    print(f"  ✅ Written to {dest_path}")

def main():
    if not os.path.exists(TEMPLATE_DIR):
        print(f"Template directory not found: {TEMPLATE_DIR}")
        sys.exit(0)

    # Ensure output dir exists
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    files = [f for f in os.listdir(TEMPLATE_DIR) if f.endswith('.toml')]
    if not files:
        print("No .toml templates found.")
        return

    print(f"Compiling {len(files)} command(s) from {TEMPLATE_DIR}...")
    for filename in files:
        process_file(filename)
    print("Done.")

if __name__ == "__main__":
    main()

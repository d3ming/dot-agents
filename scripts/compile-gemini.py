#!/usr/bin/env python3
import os
import re
import sys

PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TEMPLATE_DIR = os.path.join(PROJECT_ROOT, 'gemini', 'templates', 'commands')
OUTPUT_DIR = os.path.join(PROJECT_ROOT, 'gemini', '.gemini', 'commands')
SKILLS_DIR = os.path.join(PROJECT_ROOT, 'master', 'skills')

def resolve_path(path_ref):
    """Resolves a file path reference. 
    Supports absolute paths or relative to PROJECT_ROOT."""
    if os.path.isabs(path_ref):
        return path_ref
    return os.path.join(PROJECT_ROOT, path_ref)

def expand_includes(content):
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

    return pattern.sub(replacer, content)


def write_output(filename, content):
    dest_path = os.path.join(OUTPUT_DIR, filename)
    os.makedirs(os.path.dirname(dest_path), exist_ok=True)
    with open(dest_path, 'w') as f:
        f.write(content)
    print(f"  ✅ Written to {dest_path}")


def process_template(filename):
    src_path = os.path.join(TEMPLATE_DIR, filename)
    print(f"Processing template {filename}...")

    try:
        with open(src_path, 'r') as f:
            content = f.read()
    except FileNotFoundError:
        print(f"  ❌ Template not found: {src_path}")
        return False

    new_content = expand_includes(content)
    write_output(filename, new_content)
    return True


def iter_skill_dirs():
    if not os.path.isdir(SKILLS_DIR):
        return []
    return sorted(
        d for d in os.listdir(SKILLS_DIR)
        if os.path.isdir(os.path.join(SKILLS_DIR, d)) and not d.startswith('.')
    )


def generate_skill_command(skill_name, existing_filenames):
    filename = f"{skill_name}.toml"
    if filename in existing_filenames:
        return False

    skill_path = os.path.join(SKILLS_DIR, skill_name, 'SKILL.md')
    if not os.path.isfile(skill_path):
        return False

    template = (
        f'description = "Run the {skill_name} skill instructions."\n\n'
        'prompt = """\n'
        f'Use the shared {skill_name} skill instructions.\n\n'
        f'@{{master/skills/{skill_name}/SKILL.md}}\n'
        '"""\n'
    )

    content = expand_includes(template)
    write_output(filename, content)
    return True

def main():
    if not os.path.exists(TEMPLATE_DIR):
        print(f"Template directory not found: {TEMPLATE_DIR}")
        sys.exit(0)

    # Ensure output dir exists
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    templates = [f for f in os.listdir(TEMPLATE_DIR) if f.endswith('.toml')]
    print(f"Compiling {len(templates)} template command(s) from {TEMPLATE_DIR}...")

    existing_filenames = set(templates)
    for filename in templates:
        process_template(filename)

    generated = 0
    for skill_name in iter_skill_dirs():
        if generate_skill_command(skill_name, existing_filenames):
            generated += 1

    desired = set(templates)
    desired.update(f"{name}.toml" for name in iter_skill_dirs())

    for filename in os.listdir(OUTPUT_DIR):
        if filename.endswith('.toml') and filename not in desired:
            os.remove(os.path.join(OUTPUT_DIR, filename))
            print(f"  🧹 Removed stale command: {filename}")

    print(f"Done. Templates: {len(templates)} | Generated: {generated}")

if __name__ == "__main__":
    main()

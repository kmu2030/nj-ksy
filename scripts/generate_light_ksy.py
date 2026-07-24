#!/usr/bin/env python3

import sys
import os
import importlib
import json
from functools import reduce
from io import StringIO
from pathlib import Path
from ruamel.yaml import YAML

def snake_to_pascal(snake_str):
    return ''.join(x.capitalize() for x in snake_str.split('_'))

def main():
    if len(sys.argv) < 3:
        print(f"Usage: python {os.path.basename(__file__)} <scan directory path> <out directory path> [parser type]", file=sys.stderr)
        sys.exit(1)

    target_dir = Path(sys.argv[1])
    out_dir = Path(sys.argv[2])
    parser_type = "immediate" if len(sys.argv) > 3 and sys.argv[3] == "immediate" else "lazy"

    # Resolve the scan path.
    if not target_dir.exists():
        print(f"Error: The specified path does not exist: {target_dir}", file=sys.stderr)
        sys.exit(1)
    abs_target_dir = target_dir.resolve()
    if abs_target_dir not in sys.path:
        sys.path.append(str(abs_target_dir))

    # YAML settings.
    yaml = YAML()
    yaml.default_flow_style = False
    yaml.default_allow_unicode = True
    yaml.indent(sequence=4, offset=2)

    parsers = []
    ksygen_prop = 'to_ksy'
    ksy_props = [f"{parser_type}_eval_ksy"]

    # Create parser objects.
    for item in abs_target_dir.iterdir():
        if not item.is_file() or not item.name.endswith('.py') or item.name == '__init__.py':
            continue

        # Generate a class name from the file name.
        module_name = item.name[:-3]
        cls_name = snake_to_pascal(module_name)

        try:
            module = importlib.import_module(module_name)
            if not hasattr(module, cls_name):
                continue

            cls = getattr(module, cls_name)
            if not hasattr(cls, 'from_bytes'):
                continue

            buf_size = 256
            obj = None
            while True:
                try:
                    obj = cls.from_bytes(b'\x00' * buf_size)
                    break
                except Exception as e:
                    buf_size *= 2
            if not hasattr(obj, ksygen_prop):
                continue

            parsers.append(obj)

        except Exception as e:
            print(f"Warning: An error occurred while processing {item.name}, so it is being skipped: {e}", file=sys.stderr)
            continue

    stream = StringIO()

    # Scan generate KSY properties and output the KSY.
    for obj in parsers:
        for k in ksy_props:
            try:
                ksy_raw = reduce(getattr, [ksygen_prop, k, 'value'], obj)
                ksy_json = json.loads(ksy_raw)
                yaml.dump(ksy_json, stream)

                out_dir.mkdir(parents=True, exist_ok=True)
                out_path = out_dir / f"{ksy_json["meta"]["id"]}.ksy"
                with open(out_path, 'w', encoding='utf-8') as f:
                    f.write(stream.getvalue())
            except Exception as e:
                print(f"Error: Failed to process KSY properties: {e}", file=sys.stderr)
            finally:
                stream.truncate(0)
                stream.seek(0)

if __name__ == "__main__":
    main()

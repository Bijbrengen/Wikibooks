import argparse
import os
import shutil
import subprocess
import sys
from pathlib import Path


TEST_ROOT = Path(__file__).resolve().parent

ALL_LUA_SUITES = [
    "Array",
    "Box",
    "Call",
    "Chess",
    "Color",
    "Convert",
    "Extract",
    "Include",
    "Interface",
    "Logo",
    "Luggage",
    "Mediawiki",
    "Pattern",
    "Security",
    "Text",
    "Timestamp",
    "Validation",
]


def run_static_tests():
    return subprocess.run(
        [
            sys.executable,
            "-m",
            "unittest",
            "discover",
            "-s",
            str(TEST_ROOT),
            "-p",
            "test_*.py",
        ],
        check=False,
    ).returncode


def find_lua():
    for candidate in ("lua", "lua5.1", "luajit"):
        path = shutil.which(candidate)
        if path:
            return path

    local_app_data = os.environ.get("LOCALAPPDATA")
    common_paths = []
    if local_app_data:
        common_paths.append(Path(local_app_data) / "Programs" / "LuaJIT" / "bin" / "luajit.exe")
    common_paths.extend(
        [
            Path("C:/Program Files/LuaJIT/bin/luajit.exe"),
            Path("C:/Program Files/LuaJIT/luajit.exe"),
            Path("C:/Program Files (x86)/LuaJIT/bin/luajit.exe"),
            Path("C:/Program Files (x86)/LuaJIT/luajit.exe"),
        ]
    )
    for path in common_paths:
        if path.exists():
            return str(path)

    return None


def main():
    parser = argparse.ArgumentParser(description="Run local tests for the mirrored Wikibooks Layout module.")
    parser.add_argument("--static-only", action="store_true", help="Only run Python static checks.")
    parser.add_argument("--all", action="store_true", help="Run every mirrored Lua suite under Production/Test.")
    parser.add_argument("--suite", action="append", help="Lua suite name under Production/Test, e.g. Text.")
    args = parser.parse_args()

    static_status = run_static_tests()
    if static_status != 0 or args.static_only:
        return static_status

    lua = find_lua()
    if lua is None:
        print("Lua runtime not found; static tests passed, Lua/Scribunto test execution skipped.")
        print("Install Lua 5.1/LuaJIT or run these modules in a local MediaWiki/Scribunto instance.")
        return 0

    command = [lua, str(TEST_ROOT / "run_layout_tests.lua")]
    suites = ALL_LUA_SUITES if args.all else (args.suite or [])
    for suite in suites:
        command.append(suite)

    return subprocess.run(command, check=False).returncode


if __name__ == "__main__":
    raise SystemExit(main())

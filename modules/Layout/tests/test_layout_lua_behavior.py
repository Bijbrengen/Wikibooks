import os
import subprocess
import sys
import textwrap
import unittest
from pathlib import Path

from run_layout_tests import find_lua


LAYOUT_ROOT = Path(__file__).resolve().parents[1]
TEST_ROOT = Path(__file__).resolve().parent


@unittest.skipIf(find_lua() is None, "Lua runtime not available")
class LayoutLuaBehaviorTests(unittest.TestCase):
    def run_lua(self, script):
        env = os.environ.copy()
        env["LAYOUT_TEST_ROOT"] = str(TEST_ROOT)
        return subprocess.run(
            [find_lua(), "-"],
            input=script,
            text=True,
            capture_output=True,
            cwd=LAYOUT_ROOT,
            env=env,
            check=False,
        )

    def test_include_missing_module_raises_clear_error(self):
        script = textwrap.dedent(
            r"""
            dofile(os.getenv("LAYOUT_TEST_ROOT") .. "/run_layout_tests.lua")
            local CFG = require("Module:Layout/Production/Configuration")
            local ok, message = pcall(function()
                CFG.INCLUDE("production", "module-that-does-not-exist")
            end)
            if ok then
                error("expected CFG.INCLUDE to fail for missing module")
            end
            message = tostring(message)
            assert(message:find("Module:Layout include not found", 1, true), message)
            assert(message:find("environment 'production'", 1, true), message)
            assert(message:find("module 'module-that-does-not-exist'", 1, true), message)
            assert(message:find("Module:Layout/Production/", 1, true), message)
            """
        )
        result = self.run_lua(script)
        self.assertEqual("", result.stderr)
        self.assertEqual(0, result.returncode, result.stdout + result.stderr)

    def test_optional_include_allows_missing_modules(self):
        script = textwrap.dedent(
            r"""
            dofile(os.getenv("LAYOUT_TEST_ROOT") .. "/run_layout_tests.lua")
            local CFG = require("Module:Layout/Production/Configuration")
            local missing = CFG.INCLUDE_OPTIONAL("production", "module-that-does-not-exist")
            assert(missing == nil, "missing optional include should return nil")
            local text = CFG.INCLUDE_OPTIONAL("production", "text")
            assert(type(text) == "table", "existing optional include should load")
            assert(type(text.trim) == "function", "existing optional include should expose module functions")
            """
        )
        result = self.run_lua(script)
        self.assertEqual("", result.stderr)
        self.assertEqual(0, result.returncode, result.stdout + result.stderr)


if __name__ == "__main__":
    unittest.main()

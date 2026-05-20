import json
import re
import unittest
from pathlib import Path


LAYOUT_ROOT = Path(__file__).resolve().parents[1]
TEST_ROOT = Path(__file__).resolve().parent
MANIFEST = LAYOUT_ROOT / "_manifest.json"
KNOWN_LEGACY = json.loads((TEST_ROOT / "known_legacy_requires.json").read_text(encoding="utf-8"))

REQUIRE_RE = re.compile(r"\brequire\s*\(\s*['\"]([^'\"]+)['\"]\s*\)")


def module_to_path(module_name):
    if module_name == "Module:Layout":
        return LAYOUT_ROOT / "_module.lua"
    prefix = "Module:Layout/"
    if not module_name.startswith(prefix):
        return None
    relative = module_name[len(prefix):]
    return LAYOUT_ROOT.joinpath(*relative.split("/")).with_suffix(".lua")


def strip_lua_comments(source):
    source = re.sub(r"--\[\[.*?\]\]", "", source, flags=re.DOTALL)
    return "\n".join(line.split("--", 1)[0] for line in source.splitlines())


class LayoutMirrorStaticTests(unittest.TestCase):
    def test_manifest_files_exist(self):
        manifest = json.loads(MANIFEST.read_text(encoding="utf-8-sig"))
        pages = manifest["pages"]

        self.assertEqual(manifest["page_count"], len(pages))
        missing = [
            page["file"]
            for page in pages
            if not (LAYOUT_ROOT / page["file"]).exists()
        ]
        self.assertEqual([], missing)

    def test_explicit_lua_requires_resolve_or_are_documented(self):
        missing = []
        documented = []

        for lua_file in LAYOUT_ROOT.rglob("*.lua"):
            source = strip_lua_comments(lua_file.read_text(encoding="utf-8-sig"))
            for required in REQUIRE_RE.findall(source):
                if required in KNOWN_LEGACY:
                    documented.append((lua_file.relative_to(LAYOUT_ROOT).as_posix(), required))
                    continue

                required_path = module_to_path(required)
                if required_path is None:
                    missing.append((lua_file.relative_to(LAYOUT_ROOT).as_posix(), required, "outside Module:Layout"))
                elif not required_path.exists():
                    missing.append((lua_file.relative_to(LAYOUT_ROOT).as_posix(), required, str(required_path)))

        self.assertEqual([], missing)
        self.assertTrue(
            documented,
            "The legacy allowlist should document at least one currently mirrored legacy require.",
        )

    def test_existing_wikibooks_test_modules_are_discoverable(self):
        expected = {
            "Array.lua",
            "Call.lua",
            "Color.lua",
            "Include.lua",
            "Pattern.lua",
            "Text.lua",
            "Timestamp.lua",
        }
        found = {path.name for path in (LAYOUT_ROOT / "Production" / "Test").glob("*.lua")}
        self.assertTrue(expected.issubset(found))

    def test_sjabloon_opmaak_fixture_invokes_layout_production(self):
        template = (TEST_ROOT / "fixtures" / "Sjabloon_Opmaak.raw.wiki").read_text(encoding="utf-8")
        self.assertIn("{{#Invoke:Layout|production", template)

        parameter_pairs = {
            "object": "Object",
            "support": "Support",
            "format": "Formaat",
            "orientation": "Orientatie",
            "color": "Kleur",
            "title": "Titel",
            "definition": "Definitie",
            "description": "Beschrijving",
            "progress": "Voortgang",
            "source": "Bron",
            "reference": "Referentie",
            "collection": "Collectie",
            "part": "Onderdeel",
        }

        for frame_arg, dutch_template_arg in parameter_pairs.items():
            with self.subTest(frame_arg=frame_arg):
                self.assertRegex(template, rf"\|\s*{frame_arg}\s*=")
                self.assertIn("{{{" + dutch_template_arg + "|", template)

        for index in range(1, 101):
            self.assertIn("{{{" + str(index) + "|}}}", template)


if __name__ == "__main__":
    unittest.main()

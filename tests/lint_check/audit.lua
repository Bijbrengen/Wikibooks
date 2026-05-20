-- Test Audit Script
package.path = package.path .. ";d:/repos/Leerpret/wikibooks/modules/Module_Layout/Production/?.lua"
package.path = package.path .. ";d:/repos/Leerpret/wikibooks/modules/Module_Layout/Production/View/?.lua"

_G.mw = require("tests/lint_check/mock_mw")

local function test_component(name, call_mock)
    print("Testing Component: " .. name)
    local module = require(name)
    local status, result = pcall(module.main, call_mock)
    if status then
        -- Check for common lint issues in the result string
        if result:find("<span>.-<div>") then
            print("  [!] LINT ERROR: div inside span found!")
        end
        if result:find("<b>.-<div>") then
            print("  [!] LINT ERROR: div inside b found!")
        end
        if result:find("<i>.-<div>") then
            print("  [!] LINT ERROR: div inside i found!")
        end
        print("  [OK] Rendered successfully.")
    else
        print("  [X] CRASH: " .. tostring(result))
    end
end

-- Mock call object
local call = {
    include = function(n) return require(n) end,
    content = {
        book = {},
        series = { image = "Test.png", link = "TestLink", book = {} },
        chapter = {},
        bookshelf = { image = "Test.png", link = "TestLink", book = {} }
    },
    color = {
        [2] = { hex = "#123456", tints = { [5] = "#abc", [7] = "#def", [8] = "#ghi" }, shades = { [2] = "#000", [10] = "#111" } },
        [1] = { hex = "#654321", tints = { [8] = "#fed" } }
    },
    message = {
        PROGRESS = { NOTHING = "%s", IO = "%s", RO = "%s", GO = "%s", ZO = "%s", DEVELOPMENT = "" },
        CATEGORY = { WIKIPEDIA_LINK_MISSING = "Missing" }
    },
    style = { BLACK = "black" }
}

-- Add more mocks for required modules
package.loaded["gradient"] = require("Gradient")
package.loaded["progress"] = require("Progress")
package.loaded["bookshelf"] = require("Bookshelf")
package.loaded["toc"] = require("Toc")
package.loaded["infobox"] = require("Infobox")
package.loaded["logo"] = require("Logo")
package.loaded["definition"] = require("Definition")
package.loaded["description"] = require("Description")
package.loaded["wikipedia"] = require("Wikipedia")
package.loaded["category"] = require("Category")
package.loaded["wikijunior"] = require("Wikijunior")
package.loaded["text"] = { trim = function(s) return s end }

-- Test core components
test_component("Bookshelf", call)
test_component("Chapter", call)
test_component("Series", call)
test_component("Definition", { definition = "<div>Test</div>", color = call.color, include = call.include })
test_component("Description", { frame = { args = { part = "<div>Test</div>" } }, color = call.color, include = call.include })

print("\nAudit Complete.")

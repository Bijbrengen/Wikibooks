-- All Scribunto libraries are located in the global table mw.
-- All variables of this module should be explicitly scoped as a local variable.
-- However this is not as STRICT as we think.
-- When you have a table in Lua and you create a reference to that table, you're essentially creating a "shared" access to the same table.
-- It may not be a global variable in the strictest sense, but it can have similar behavior.
require( "strict" );

-- A call to a module uses the parserfunction {{#invoke:...}} where ... is the modulename. In this case Layout.
-- The return value stores the functions which are given as a first argument ... when using {{#invoke:Layout|...}}
-- The variable layout collects these functions.
local layout = {};

-- Functions called by {{#invoke:}} will be passed a frame object as single parameter.
-- This Frame-object contains the parameters passed to {{#invoke:}}, and can be used to access context-specific features of the wikitext parser.
-- In this module the main function directs to the interface through four functions specifying the environment
-- (production, stage, development, sandbox) called by {{{{#invoke:Layout|<environment>|...}}.
-- The {{#invoke:Layout|main|...}} call is checked on errors and if so the errors are returned to inform the user if the user has not turned off showing errors.
-- When no errors are found or the user has set to ignore errors, the corresponding environment en submodules are invoked.
function layout.main( frame, environment )
    -- In the Scribunto extension for MediaWiki, 
    -- when you invoke a function from a module in a template, 
    -- the function is called with a single argument, the frame object. 
    -- If your function definition has additional parameters, 
    -- these additional arguments will not receive values when the function is called 
    -- through the template.
    -- The configuration data depends on the environment
    -- So if the user has call this main function directly 
    -- the environment variable will always be nil
    -- We then default the environment to the production environment
    -- to prevent accidental calling untested functionality.
	if environment == nil then environment = "production"; end

    -- The default configuration data is stored in the CFG variable of the production environment.
    -- The path is the only hardcoded data outside the configuration data.
    -- Now load the CFG from the correct environment
    local CFG = require( 'Module:Layout/' .. environment:gsub( "^%l", string.upper ) .. '/Configuration' );

    -- The interface of the Module:Layout validates the call and redirects it to the correct system for further actions.
    local interface = CFG.INCLUDE( environment, "interface" );

    -- The interface receives the frame, the configuration data and the environment as input and returns always a valid response
	return interface.main( frame, CFG, environment );
end

-- Loads the production environment. This environment is the actual used and tested functionality of the Module:Layout.
function layout.production( frame )
    return layout.main( frame, "production" );
end

-- Loads the stage environment. This environment is reserved for putting new of changed functionality waiting to be updated to the production environment.
function layout.stage( frame )
    return layout.main( frame, "stage" );
end

-- Loads the development environment. This environment is reserved for developing new of changed functionality. If finished it is moved to the stage environment.
function layout.development( frame )
    return layout.main( frame, "development" );
end

-- Loads the sandbox environment. This environment is for playing or trying out without concrete developing new of changed functionality.
function layout.sandbox( frame )
    return layout.main( frame, "sandbox" );
end

-- The module returns a Lua table containing the functions that may be called by {{#invoke:}} stored in the variable layout.
return layout;
-- CFG is returned by require() and then passed around as shared configuration.
-- Keep this table declarative: behavior belongs in submodules where possible.
local CFG = {}

CFG.VERSION            = "0.0";
CFG.LANGUAGE           = "NL";
-- Template entry points for each release environment.
CFG.INTERFACE_TEMPLATE = { 
	production  = "Sjabloon:Opmaak", 
	stage       = "Sjabloon:Opmaak/Wachtruimte", 
	development = "Sjabloon:Opmaak/Werkplaats", 
	sandbox     = "Sjabloon:Opmaak/Zandbak"
};
-- Search order inside each environment. The empty location means the environment root.
CFG.LOCATIONS          = { "", "Configuration/", "Model/", "Interface/", "View/", "Library/" }
-- Fallback order: less stable environments may override production modules.
CFG.ENVIRONMENTS       = { "sandbox", "development", "stage", "production" }
CFG.TONES              = 10; -- Number of tones in color

-- Cache found module paths to avoid expensive mw.title.new().exists checks.
local path_cache = {};

-- Load one or more Layout submodules for an environment.
-- Example: CFG.INCLUDE( "development", "interface", "language/nl/progress" )
-- first tries Development, then Stage, then Production until each module is found.
-- Module names are normalized per path segment, so "language/nl" becomes "Language/Nl".
local function include_modules( environment, required, ... ) -- : unpack of LUA submodules
    -- The variable number of arguments are the module names.
    local modules   = {...};
    local requested_environment = environment;
    local found_environment = nil;
    for index, value in ipairs( CFG.ENVIRONMENTS ) do
        if value == environment then
            found_environment = index;
            break;
        end
    end    
    local includes = {}; -- Store loaded modules in the same order as requested.
    local tried_paths = {};

    -- Start at the requested environment and walk towards production.
    -- If the environment name is unknown, production is used as the safe default.
    for i = found_environment or #CFG.ENVIRONMENTS, #CFG.ENVIRONMENTS do
        -- Module paths use an uppercase first letter for the environment segment.
        local env_name = CFG.ENVIRONMENTS[ i ]:gsub( "^%l", string.upper );
	    for index, modulename in ipairs( modules ) do
	        if ( includes[ index ] == nil ) then 
		        -- Normalize every path segment before building the Module:Layout title.
				local path_segments = {};
				for segment in string.gmatch( modulename, "([^/]+)" ) do
				    local capitalized = string.upper( string.sub( segment, 1, 1 ) ) .. string.lower( string.sub( segment, 2 ) );
				    table.insert( path_segments, capitalized );
				end
				local normalized_name = table.concat( path_segments, "/" );
				tried_paths[ index ] = tried_paths[ index ] or {};

                -- Check if we already found this module in this environment or a previous one.
                local cache_key = env_name .. ":" .. normalized_name;
                if path_cache[ cache_key ] then
                    includes[ index ] = require( path_cache[ cache_key ] );
                else
		            -- Use mw.title.new(...).exists so missing override modules can fall through.
		            for _, location in ipairs( CFG.LOCATIONS ) do
		   	            local title_path =  "Module:Layout/"   .. env_name .. "/" .. location .. normalized_name;
		   	            table.insert( tried_paths[ index ], title_path );
		   	            if mw.title.new( title_path ).exists then
                            path_cache[ cache_key ] = title_path;
		   	        	    includes[ index ] = require( title_path );
		   	        	    break;
		   	            end
		   	        end
                end
		   	end    
	    end
    end

    for index, modulename in ipairs( modules ) do
        if required and includes[ index ] == nil then
            error(
                string.format(
                    "Module:Layout include not found for environment '%s', module '%s'. Tried: %s",
                    tostring( requested_environment ),
                    tostring( modulename ),
                    table.concat( tried_paths[ index ] or {}, ", " )
                ),
                2
            );
        end
    end
    return unpack( includes, 1, #modules ); -- Return separate values, matching the requested module order.
end

function CFG.INCLUDE( environment, ... )
    return include_modules( environment, true, ... );
end

function CFG.INCLUDE_OPTIONAL( environment, ... )
    return include_modules( environment, false, ... );
end

return CFG;

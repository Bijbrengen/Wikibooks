-- The call object carries one Layout invocation through the pipeline.
-- It stores raw parameters, normalized parameters, validation state and feedback.
local call = {}

-- Note helpers turn plain strings or string.format arguments into feedback text.
local note = {};

function note.composition( ... )
	-- Accept either a literal message or a string.format-style call.
	local result = "";
	local arguments = { ... };
	if #arguments == 0 then return false; end
	if #arguments == 1 then 
		result = arguments[1];
	else
		result = string.format( ... );
	end;
	return result;
end

-- Define methods that will be bound to every call instance.
local methods = {}

function methods.add_debug( self, ... ) -- : boolean
	if #self.debugging < 1 or not note.composition( ... ) then return false; end
	self.debugging[ #self.debugging ] = self.debugging[ #self.debugging ] .. "<br><br>" .. note.composition( ... );
	return true;
end

function methods.add_mistake( self, ... ) -- : boolean
	-- Any mistake blocks rendering until the caller explicitly receives feedback.
	self.pass = false;
	if #self.mistake < 1 or not note.composition( ... ) then return false; end
	self.mistake[ #self.mistake ] = self.mistake[ #self.mistake ] .. "<br><br>" .. note.composition( ... );
	return true;
end

function methods.add_new_debug( self, ... ) -- : boolean
	if not note.composition( ... ) then return false; end
	self.debugging[ #self.debugging + 1 ] = note.composition( ... );
	return true;
end

function methods.add_new_mistake( self, ... ) -- : boolean
	-- Start a separate mistake entry and mark the call as unsafe to render.
	self.pass = false;
	if not note.composition( ... ) then return false; end
	self.mistake[ #self.mistake + 1 ] = note.composition( ... );
	return true;
end

-- The init function now returns a NEW instance of the call object.
function call.init ( CFG, environment )
    local instance = {
        debugging = {},
        help      = {},
        mistake   = {},
        named     = {},
        unnamed   = {},
        content   = "",
        style     = "",
        environment = environment or "production",
        pass      = true
    }
    
    -- Bind methods to the instance so they can be called as call.method(...) 
    -- while still having access to the instance data via 'instance'.
    instance.add_debug       = function(...) return methods.add_debug(instance, ...) end
    instance.add_mistake     = function(...) return methods.add_mistake(instance, ...) end
    instance.add_new_debug   = function(...) return methods.add_new_debug(instance, ...) end
    instance.add_new_mistake = function(...) return methods.add_new_mistake(instance, ...) end
    
    -- Bind module loading to the selected environment and its fallback chain.
    -- We automatically deep-copy any returned tables to prevent shared state pollution.
    local array = CFG.INCLUDE( instance.environment, "array" );
    local function copy_if_table( ... )
        local results = { ... };
        for i = 1, #results do
            if type( results[i] ) == "table" then
                results[i] = array.copy( results[i] );
            end
        end
        return unpack( results );
    end

    instance.include          = function ( ... ) return copy_if_table( CFG.INCLUDE( instance.environment, ... ) ) end;
    instance.include_optional = function ( ... ) return copy_if_table( CFG.INCLUDE_OPTIONAL( instance.environment, ... ) ) end;
    
    instance.add_new_debug("The Call object has been initialized");
    
    return instance
end

return call;


local luggage = {};

-- Translate valid named template parameters into internal call fields.
-- Enumerated parameters are mapped from localized labels back to internal values.
function luggage.carry_on( call )
	-- Helpers used for value checks and case-insensitive lookup.
	local text, array  = call.include( "text", "array" );

    -- All valid internal parameter names are listed in the hook configuration.
	for _, parameter in ipairs( call.hook.PARAMETER ) do
		call[ parameter ] = false;
		if call.named[ parameter ] and call.named[ parameter ] ~= "" then
			-- Free-text parameters can be copied directly.
			if call.message.HOOK[ string.upper( parameter ) ] == nil then
		        call[ parameter ] = call.named[ parameter ];
			else
				-- Enumerated parameters are translated via the localized hook table.
				local search = array.search( call.message.HOOK[ string.upper( parameter ) ], call.named[ parameter ], true );	
			    if search then 
				    call[ parameter ] = call.hook[ string.upper( parameter ) ][ search ];
			    end
		    end
		end		
    end	
	return call;
end

-- Keep only the information needed after rendering, mainly for feedback output.
function luggage.claim( call )
	return { 
		pass = call.pass, 
		message = call.message, 
		support = call.support, 
		debugging = call.debugging, 
		mistake = call.mistake, 
		help = call.help };
end

-- Hydrate the call object with configuration, language data, hooks, styles and frame args.
function luggage.drop( call, frame, CFG, environment )
	call.CFG           = CFG;
	call.frame         = frame;
	call.version       = CFG.VERSION;
    call.template      = CFG.INTERFACE_TEMPLATE[ call.environment ];
    call.language      = CFG.LANGUAGE;
    call.language_path = "language/" .. call.language;
    call.message       = call.include( call.language_path );
    call.hook          = call.include( "hook" );
    call.style         = call.include( "style" );
    call.tones         = CFG.TONES;

	call.message.PARAM = {};
	for i, key in ipairs(call.hook.PARAMETER) do
	    local value = call.message.HOOK.PARAMETER[i];
	    call.message.PARAM[string.upper( key )] = value;
	end

	-- Helpers used while copying context from MediaWiki into the call object.
	local text  = call.include( "text" );

	local parent = call.frame:getParent();
	if parent then 
		call.invoker = text.trim( parent:getTitle() );
	else
		call.invoker = text.trim( call.frame:getTitle() );
	end
	call.caller      = mw.title.getCurrentTitle();

    -- Split frame arguments into named and unnamed parameters and store them as strings.
	for key, value in pairs( frame.args ) do
        if type( key ) == "string" then
            call.named[ key ] = tostring( value );
        else
            call.unnamed[ key ] = tostring( value );	
        end
	end

    -- Translate valid object names by looking up the object-specific language files.
    call.message.HOOK.OBJECT = {};
    call.message.OBJECT = {};
    
	-- Store both the ordered localized labels and an uppercase lookup table.
    for index, objectname in ipairs( call.hook.OBJECT ) do
		local object_language_path = call.language_path .. "/" .. objectname;
		local object_language = call.include_optional( object_language_path );
		if object_language ~= nil and object_language.NAME ~= nil then
		    call.message.HOOK.OBJECT[ index ] = object_language.NAME;
		    call.message.OBJECT[string.upper(objectname)] = object_language.NAME
		end
	end
	
	return call;
end

-- Convert and enrich validated call parameters before rendering.
function luggage.loading( call )
	-- Inventory contains parameter-specific normalizers and defaults.
	local inventory = call.include( "inventory" );

    -- Convert and complete values for every configured parameter.
    for _, parameter in ipairs( call.hook.PARAMETER ) do
        if type( inventory[ parameter] ) == "function" then call[ parameter ] = inventory[ parameter ]( call ); end
    end

    -- Add messages specific to the chosen object.
    for index, objectname in ipairs( call.hook.OBJECT ) do
		local object_language_path = call.language_path .. "/" .. objectname;
		local object_language = call.include_optional( object_language_path );
		if object_language ~= nil then
		    call.message[ string.upper( objectname ) ] = object_language;
        end
	end

    -- Let the object-specific content module prepare renderable content.
    local content = call.include_optional( "content/" .. call.object );
    if content then call = content.main( call ); end

    return call;
end

return luggage;

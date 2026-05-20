-- The content of a template as wiki-object
local content = {}

local TEMPLATE = {};
TEMPLATE.ICON  = "[[File:OOjs UI icon bold-a.svg|40x40px%s]]";

-- This function adds template contents to the call object for use in the view
function content.main( call )
	-- The functions from other modules that are used in this function
    local extract = call.include( "extract" );

    -- This will be stored in the call.content variable
    local result = {};

    -- In the header we link to edit the documentation by an icon and give some comments about the status of development of the template
	local link = "";
	if call.source then link = "|link=" .. call.source; end 
	result.header      = string.format( TEMPLATE.ICON, link ) .. string.format( call.message.TEMPLATE.DEVELOPMENT, call.version );
  
    -- The actual content of the template is stored in the call.content.elaboration  
    result.elaboration = extract.content( call );
    
    -- Pass the constants to call.content
    result.TEMPLATE    = TEMPLATE;
    call.content = result;
    return call;
end

return content;
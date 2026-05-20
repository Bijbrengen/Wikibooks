-- This view shows the age based on the dates
local age = {};

function age.main( call )
	local response = "";
	response = call.content;
    return response;
end

return age;
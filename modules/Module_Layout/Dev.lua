local dev = {};

function dev.book_series( frame )
   local new_args = private.getParameters( frame.args, {'type', 'title'} );
   local my_type = new_args['type'] or '';
   local title = new_args['title'] or '';
--   return private.get_unnamed_parameters( frame);
--   return  readPage(title);
local pageName = "Ondernemend leren/Boekinhoud"
local templateName = "Boek/Inhoud"
local parameterName = "Status"
local parameterValue = extractTemplateParameter(pageName, templateName, parameterName)
return parameterValue

end

function dev.comma_separated_argument_list( frame )
    return private.separated_argument_list( frame, "," );
end

function dev.find_book_series( frame )
	local new_args = private.getParameters( frame.args, {'boek'} );
	local boek = new_args['boek'] or '';
	local bookseries = frame:expandTemplate{title='Wikibooks:Boekenseries'};
	local splitseries = mw.text.split( bookseries, ',' );
	local found = '';
	for k,v in pairs(splitseries) do
		local sjabloon = mw.title.new( v .. '/Boekenreeks' );
		if sjabloon.exists then
			local books = frame:expandTemplate{title=':' ..v .. '/Boekenreeks', args={'Lijst'}};
	  	    local splitbooks = mw.text.split( books, ',' );
			for ke,va in pairs(splitbooks) do
			    if (boek == va ) then found = v end
			end    
		end
	end
    return tostring(found);
end

function dev.return_separated_argument_list( frame )
    return private.separated_argument_list( frame, "<br>" );
end

function dev.split ( frame )
	local new_args = private.getParameters( frame.args, {'text', 'position', 'separator'} );
	local text = new_args['text'] or '';
	local separator = new_args['separator'] or '%s';
	local splittable = mw.text.split( text, separator ); 
	local positionstring = new_args['position'] or '0';
	local position =  tonumber(positionstring);
	return splittable[position];
end

function dev.percentage_completed( frame )
    local new_args = private.getParameters( frame.args, {'status'} );
    local new_status = new_args['status'] or '';
    local percentage = {
        ["0"] = "00",
        ["0%"] = "00",
        ["00%"] = "00",
        ["25"] = "25",
        ["25%"] = "25",
        ["50"] = "50",
        ["50%"] = "50",
        ["75"] = "75",
        ["75%"] = "75",
        ["100"] = "100",
        ["100%"] = "100"
    }
    return percentage[new_status];
end

function dev.phase_category( frame )
    local new_args = private.getParameters( frame.args, {'status'} );
    local new_status = new_args['status'] or '';
    local phase = {
        ["0"] = "[[Categorie:Fase0]]",
        ["0%"] = "[[Categorie:Fase0]]",
        ["00%"] = "[[Categorie:Fase0]]",
        ["25"] = "[[Categorie:Fase1]]",
        ["25%"] = "[[Categorie:Fase1]]",
        ["50"] = "[[Categorie:Fase2]]",
        ["50%"] = "[[Categorie:Fase2]]",
        ["75"] = "[[Categorie:Fase3]]",
        ["75%"] = "[[Categorie:Fase3]]",
        ["100"] = "[[Categorie:Fase4]]",
        ["100%"] = "[[Categorie:Fase4]]"
    }
    return phase[new_status];
end

function dev.template( frame )
	local new_args = private.getParameters( frame.args, {'sjabloon'} );
	local sjabloon = new_args['sjabloon'] or '';
	return frame:expandTemplate{title=sjabloon};
end

function dev.title( frame )
   return mw.title.getCurrentTitle():getContent();	
end

function dev.list_title_with_status_square( frame )
	local title_lists = '';
    for k,v in pairs(frame.args) do
    	if (v ~= nil and v ~= '') then
    		title_lists =  title_lists .. "* [[" .. v .. "]]&nbsp;" .. private.status_square( frame, v ) .. "\n";
    	end
    end
    return title_lists;
end

function dev.list_title_with_progress_bar( frame )
	local title_lists = '';
    for k,v in pairs(frame.args) do
    	if (v ~= nil and v ~= '') then
    		title_lists =  title_lists .. '* [[' .. v .. ']]<div style="display:inline" style="float:right;">' .. private.status_progress_bar( frame, v ) .. '</div>\n';
    	end
    end
    return title_lists;
end

function dev.overview_box( frame )
   local new_args = private.getParameters( frame.args, {'title', 'content'} );
   local title = new_args['title'] or '';
   local content = new_args['content'] or '';
   local result =     '<table width="320px" style="float:left; clear:right; margin: 1em 2em 1em 2em; background-color:#f8f8f8; color: black; border: 1px solid rgb(170, 170, 170);">';
   result = result .. '    <tr>';
   result = result .. '        <td>';
   result = result .. '            <p style="text-align: center; padding:5px; margin: 1 px; color:darkblue; font-size: 135%; background-color: #f8f8f8; color: black; border: 1px solid rgb(170, 170, 170);">';
   result = result .. '                <b>' .. title .. '</b>';
   result = result .. '            </p>';
   result = result .. '        </td>';
   result = result .. '    </tr>';
   result = result .. '    <tr>';
   result = result .. '        <td>';
   result = result .. '            ' .. content;
   result = result .. '        </td>';
   result = result .. '    </tr>';
   result = result .. '</table>';
   return result;
end

function dev.string_title_with_status_square( frame )
	local title_lists = '';
    for k,v in pairs(frame.args) do
    	if (v ~= nil and v ~= '') then
    	    if (k ~= 1) then title_lists= title_lists .. " - "; end
   	        title_lists =  title_lists .. "[[" .. v .. "]]&nbsp;" .. private.status_square( frame, v );
    	end
    end
    return title_lists;
end

return dev;
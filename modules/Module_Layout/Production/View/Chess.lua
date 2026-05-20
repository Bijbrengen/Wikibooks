local chess = {};

function chess.main( call )
    local response = "";

    response = chess.wrapper( call );
    return response;
end

function chess.wrapper( call )
    local wrapper_chessboard = mw.html.create('div');
    wrapper_chessboard:css( { float  = 'left', clear = 'left', margin = '0.5em 1em 0.5em 0' } )
        :css( 'text-align', 'center' );	
	if call.definition then  
        local boldText = mw.html.create('div')
            :css('font-weight', 'bold')
            :wikitext( call.definition )
		wrapper_chessboard:node( boldText );
	end
    wrapper_chessboard:node( chess.board( call ) );
    local clearDiv = mw.html.create('div')
        :css('clear', 'left');
    wrapper_chessboard:node(  clearDiv );
    wrapper_chessboard:allDone();
    return wrapper_chessboard;
end

function chess.board( call )
	local chessboard = mw.html.create( 'div' )
        :css( 'border', '1px solid #b0b0b0' )
        :css( 'background-color', '#f9f9f9' )
        :css( 'color', 'black' )
        :css( 'padding-top', '6px' );
	chessboard:node( chess.grid( call ) );
	if call.description then  
        local html = mw.html.create('div')
            :addClass('thumbcaption')
            :css('margin-left', '4px')
            :css('margin-right', '4px')
            :wikitext( call.description );
        chessboard:node( html );
    end
    return chessboard;
end

function chess.files( letters )
    local letters_row = mw.html.create('tr')
    letters_row:css('vertical-align', 'middle')
    letters_row:tag('td')
        :wikitext('[[File:Solid white.svg|18px|link=|alt=]]')
        :done()
    for file, letter in ipairs( letters ) do
        letters_row:tag('td')
            :css('background-color', 'white')
            :css('color', 'black')
            :wikitext( letter)
            :done()
    end
    letters_row:tag('td')
        :wikitext('[[File:Solid white.svg|18px|link=|alt=]]')
        :done()
    return letters_row;
end

function chess.grid( call )
	local chessboard_grid = mw.html.create('table')
	    :attr('cellpadding', '0')
	    :attr('cellspacing', '0')
	    :css('border', '1px solid #b0b0b0')
	    :css('margin', 'auto');
	-- All unnamed parameters contain information about the chessboard grid.
    local letters =  call.content.CHESS.LETTERS_WHITE;
    if call.orientation == "black" then letters =  call.content.CHESS.LETTERS_BLACK; end
	chessboard_grid:node( chess.files( letters ) );
    if call.orientation == "white" then
        for i = 8, 1, -1 do
            chessboard_grid:node( chess.rank( i, call.content.matrix[i], letters, call ) );
        end
    else
	    for i = 1, 8, 1 do
	        chessboard_grid:node( chess.rank( i, call.content.matrix[i], letters, call) );
	    end
    end
	-- Name the files by letters on the last row
    chessboard_grid:node( chess.files( letters ) );
    return chessboard_grid;
end

function chess.rank( number, ranksquares, letters, call )
	if type( number ) ~= "number" or number < 1 or number > 8 then number = 1; end
    if type( letters ) ~= "table" or #letters ~= 8 then letters =  call.content.CHESS.LETTERS_WHITE; end
    if not ( ranksquares and ranksquares.a and ranksquares.b and ranksquares.c and ranksquares.d and ranksquares.e and ranksquares.f and ranksquares.g and ranksquares.h ) then
        ranksquares =  call.content.CHESS.RANK;
    end
	local ranknumber = mw.html.create('td');
    ranknumber:css('background-color', 'white');
    ranknumber:css('color', 'black');
    ranknumber:css('text-align', 'center');
    ranknumber:wikitext( number );
    local rank = mw.html.create( 'tr' );
    rank:css( 'vertical-align', 'middle' );
    rank:node( ranknumber );
    -- Tthe type function is used to check if the variable is a table.
    -- The #var expression is used to check the length of the table, which should be 8. 
    -- The next function is used to check if there are any named parameters in the table, and should return nil if there are none.
    for file, letter in ipairs( letters ) do
        rank:node( chess.square(  letter .. tostring( number ), ranksquares[ letter ], call ) );
    end

    local ranknumber_right = mw.html.create('td')
        :css('background-color', 'white')
        :css('color', 'black')
        :css('text-align', 'center')
        :wikitext( number );
    rank:node( ranknumber_right );

	return rank;
end

function chess.square( name, piece, call )
    local file = string.sub( name, 1, 1 );
    if file == nil or file:byte() < 97 or file:byte() > 104 then name  = "a1"; end
    local rank = tonumber( string.sub( name, 2, 2 ) );
    if rank == nil or rank < 1 or rank > 8 then name  = "a1"; end
    
	-- Get the name of the piece if exists
	local piece_description = call.message.CHESS.WITHOUT_A_PIECE;
	if piece ~= "" and call.message.CHESS.ABBREVIATION[ piece ] ~= nil then piece_description = call.message.CHESS.WITH_A_PIECE .. call.message.CHESS.ABBREVIATION[ piece ]; end
    
	-- Create the table cell element
	local chessboard_square = mw.html.create('td')
	    :css( 'background-color', chess.square_color( name, call.color[2].shades[10], call.color[2].tints[7] ) )
        :css( 'color', 'black' )
	    :css( 'text-align', 'center' )
	    :wikitext( '[[File:Chess ' .. piece .. 't45.svg|26px|alt=' .. call.message.CHESS.SQUARE .. name .. piece_description .. ']]' );

	return chessboard_square;
end

function chess.square_color( name, black, white ) -- : string
  -- Get the file and rank numbers from the square_name
    local file = string.sub( name, 1, 1 );
    if file == nil then return white; end
    local rank = tonumber( string.sub( name, 2, 2 ) );
    if rank == nil or rank < 1 or rank > 8 then return white; end

    -- Check if the square is on a white or black square
    if ( (file == 'a' or file == 'c' or file == 'e' or file == 'g') and (rank % 2 == 1) ) or
       ( (file == 'b' or file == 'd' or file == 'f' or file == 'h') and (rank % 2 == 0) ) 
    then
        return black;
    else
        return white;
    end
end

return chess;
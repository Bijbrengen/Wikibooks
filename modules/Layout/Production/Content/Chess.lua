local content = {};

function content.main( call )
	-- The functions from other modules that are used in this function
	local array  = call.include( "array");

    -- Move constants into the function or ensure they are immutable.
    local CHESS = {};
    CHESS.LETTERS_WHITE = { "a", "b", "c", "d", "e", "f", "g", "h" };
    CHESS.LETTERS_BLACK = { "h", "g", "f", "e", "d", "c", "b", "a" };
    CHESS.RANK          = { a = "", b = "", c = "", d = "", e = "", f = "", g = "", h = "" };

	local chessboard_ranks = {}; -- to store the ranks
	local chessboard_files = nil; -- to store the definition of the files and their order
    local letter_position = 1;
    -- Check every unnamed parameter to obtain information about the board
    for i, v in ipairs( call.unnamed ) do
        -- every rank starts with the row number 
        local ranknumber = tonumber( v );
        -- Check if the parameter is a valid rank number
        if ranknumber ~= nil and ranknumber >= 1 and ranknumber <= 8 then
        	-- The 8 follwing unnamed parameters should be defining board squares of that rank
        	chessboard_ranks[ ranknumber ] = array.slice( call.unnamed, i + 1, i + 8 );
        	-- Check if this is the first number and if so initialze the file definition based on this number
        	if chessboard_files == nil then 
        		if ranknumber == 1 then
        			chessboard_files = array.copy( CHESS.LETTERS_BLACK );
        		else
        			chessboard_files = array.copy( CHESS.LETTERS_WHITE );
        		end
        	end
        end
        -- Check if the parameter is a valid file letter and then overwrite the default definition of the files
        if array.search( CHESS.LETTERS_WHITE, v ) and letter_position <= 8 then
            -- Ensure we have a working copy of the file definitions if not already initialized
            if chessboard_files == nil then chessboard_files = array.copy( CHESS.LETTERS_WHITE ); end
        	chessboard_files[ letter_position ] = v;
        	letter_position = letter_position + 1;
        end
    end

    local chessboard_matrix = {};
    -- Initialize the squares with empty values so we get a full matrix;
    for i = 1, 8 do
        chessboard_matrix[i] = { a = "", b = "", c = "", d = "", e = "", f = "", g = "", h = "" };
    end
    -- Now fill from the ranks and the file definition the matrix
    for i, v in ipairs( chessboard_ranks ) do
        local new_rank = {};
    	for index, value in ipairs( v ) do
    		new_rank[ chessboard_files[ index ] ] = value;
    	end
    	chessboard_matrix[ i ] = new_rank;
    end
    
    local result = {};
    result.matrix = chessboard_matrix;
    result.CHESS  = CHESS;
    call.content  = result;
	return call;
end

function content.PGNtoFEN( pgn )
  -- Set up the initial position
  local board = {}
  for i = 1, 8 do
    board[i] = {}
    for j = 1, 8 do
      board[i][j] = " "
    end
  end

  -- Parse the PGN moves
  local moves = {}
  for move in pgn:gmatch("%S+") do
    if move:sub(1, 1) ~= "[" then
      table.insert(moves, move)
    end
  end

  -- Apply the moves to the board
  for i, move in ipairs(moves) do
    -- Parse the move
    local fromFile, fromRank, toFile, toRank = move:match("(%a)(%d)(%a)(%d)")
    local piece = move:sub(1, 1)
    if piece == "N" then
      piece = "knight"
    elseif piece == "B" then
      piece = "bishop"
    elseif piece == "R" then
      piece = "rook"
    elseif piece == "Q" then
      piece = "queen"
    elseif piece == "K" then
      piece = "king"
    end

    -- Apply the move to the board
    board[tonumber(fromRank)][fromFile:byte() - 96] = " "
    board[tonumber(toRank)][toFile:byte() - 96] = piece
  end

  -- Convert the board to FEN
  local fen = ""
  for i = 8, 1, -1 do
    local emptySquares = 0
    for j = 1, 8 do
      local square = board[i][j]
      if square == " " then
        emptySquares = emptySquares + 1
      else
        if emptySquares > 0 then
          fen = fen .. emptySquares
          emptySquares = 0
        end
        if square == "knight" then
          fen = fen .. "N"
        else
          fen = fen .. square:sub(1, 1):upper()
        end
      end
    end
    if emptySquares > 0 then
      fen = fen .. emptySquares
    end
    if i > 1 then
      fen = fen .. "/"
    end
  end
  fen = fen .. " w - - 0 1"

  return fen
end

return content;

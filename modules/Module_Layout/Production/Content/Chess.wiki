local content = {};

-- Constants for piece names used in the View
local PIECES = {
    white = { P = "pl", N = "nl", B = "bl", R = "rl", Q = "ql", K = "kl" },
    black = { p = "pd", n = "nd", b = "bd", r = "rd", q = "qd", k = "kd" }
}

function content.main( call )
    local array = call.include( "array" );
    local CHESS = {};
    CHESS.LETTERS_WHITE = { "a", "b", "c", "d", "e", "f", "g", "h" };
    CHESS.LETTERS_BLACK = { "h", "g", "f", "e", "d", "c", "b", "a" };
    CHESS.RANK          = { a = "", b = "", c = "", d = "", e = "", f = "", g = "", h = "" };

    local format = call.Format or "";
    local result = { CHESS = CHESS };
    
    -- Auto-detect format if not specified
    if format == "" then
        if call.pgn and call.pgn ~= "" then
            format = "pgn";
        elseif call.fen and call.fen ~= "" then
            format = "fen";
        else
            -- Check if unnamed parameters contain rank numbers, which indicates the grid format
            for _, v in ipairs( call.unnamed ) do
                local n = tonumber( v );
                if n and n >= 1 and n <= 8 then
                    format = "bord positie";
                    break;
                end
            end
            -- If still not found, check if the first unnamed parameter looks like FEN or PGN
            if format == "" and call.unnamed[1] then
                if call.unnamed[1]:match("^%d+%.") then
                    format = "pgn";
                elseif call.unnamed[1]:match("/") then
                    format = "fen";
                end
            end
        end
    end
    
    if format == "pgn" then
        result.matrix = content.parsePGN( call );
    elseif format == "fen" then
        result.matrix = content.parseFEN( call.fen or call.unnamed[1] );
    else
        -- Use existing grid logic
        result.matrix = content.parseGrid( call, CHESS, array );
    end
    
    call.content = result;
    return call;
end

-- Existing grid logic extracted to a function
function content.parseGrid( call, CHESS, array )
    local chessboard_ranks = {};
    local chessboard_files = nil;
    local letter_position = 1;

    for i, v in ipairs( call.unnamed ) do
        local ranknumber = tonumber( v );
        if ranknumber ~= nil and ranknumber >= 1 and ranknumber <= 8 then
            chessboard_ranks[ ranknumber ] = array.slice( call.unnamed, i + 1, i + 8 );
            if chessboard_files == nil then 
                if ranknumber == 1 then
                    chessboard_files = array.copy( CHESS.LETTERS_BLACK );
                else
                    chessboard_files = array.copy( CHESS.LETTERS_WHITE );
                end
            end
        end
        if array.search( CHESS.LETTERS_WHITE, v ) and letter_position <= 8 then
            if chessboard_files == nil then chessboard_files = array.copy( CHESS.LETTERS_WHITE ); end
            chessboard_files[ letter_position ] = v;
            letter_position = letter_position + 1;
        end
    end

    local matrix = {};
    for i = 1, 8 do
        matrix[i] = { a = "", b = "", c = "", d = "", e = "", f = "", g = "", h = "" };
    end
    for i, v in ipairs( chessboard_ranks ) do
        local new_rank = {};
        for index, value in ipairs( v ) do
            new_rank[ chessboard_files[ index ] ] = value;
        end
        matrix[ i ] = new_rank;
    end
    return matrix;
end

-- FEN Parser
function content.parseFEN( fen )
    if not fen then return nil end
    local matrix = {}
    for i = 1, 8 do
        matrix[i] = { a = "", b = "", c = "", d = "", e = "", f = "", g = "", h = "" }
    end
    
    local parts = mw.text.split( fen, " " )
    local board_str = parts[1]
    local ranks = mw.text.split( board_str, "/" )
    
    for i = 1, 8 do
        local rank_idx = 9 - i -- FEN starts from rank 8
        local rank_str = ranks[i]
        local file_idx = 1
        for j = 1, #rank_str do
            local char = rank_str:sub(j,j)
            local num = tonumber(char)
            if num then
                file_idx = file_idx + num
            else
                local file_name = string.char(96 + file_idx)
                local piece = ""
                if char:match("%u") then
                    piece = PIECES.white[char]
                else
                    piece = PIECES.black[char]
                end
                matrix[rank_idx][file_name] = piece
                file_idx = file_idx + 1
            end
        end
    end
    return matrix
end

-- PGN Parser and Simulator
function content.parsePGN( call )
    local pgn = call.pgn or call.unnamed[1] or ""
    local onderdeel = call.Onderdeel or ""
    local voortgang = call.Voortgang or ""
    
    -- Select chapter/game if multiple exist
    if onderdeel ~= "" then
        local games = {}
        local current_game = ""
        for line in pgn:gmatch("[^\r\n]+") do
            if line:match("^%[Event ") or line:match("^%[ChapterName ") then
                if current_game ~= "" then table.insert(games, current_game) end
                current_game = line .. "\n"
            else
                current_game = current_game .. line .. "\n"
            end
        end
        table.insert(games, current_game)
        
        local selected_game = nil
        for _, g in ipairs(games) do
            if g:find(onderdeel, 1, true) then
                selected_game = g
                break
            end
        end
        if not selected_game and tonumber(onderdeel) then
            selected_game = games[tonumber(onderdeel)]
        end
        pgn = selected_game or games[1] or pgn
    end
    
    -- Extract moves
    local moves = {}
    -- Strip metadata and comments
    local clean_pgn = pgn:gsub("%b[]", ""):gsub("%b{}", ""):gsub("%d+%.%.%.", ""):gsub("%d+%.", " ")
    for move in clean_pgn:gmatch("%S+") do
        if move ~= "*" and move ~= "1-0" and move ~= "0-1" and move ~= "1/2-1/2" then
            table.insert(moves, move)
        end
    end
    
    -- Initialize board
    local matrix = content.parseFEN("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
    
    -- Determine target move count
    local target_moves = #moves
    if voortgang ~= "" then
        if tonumber(voortgang) then
            target_moves = tonumber(voortgang) * 2 -- Assume full moves
            if voortgang:match("w$") then target_moves = tonumber(voortgang:sub(1,-2)) * 2 - 1
            elseif voortgang:match("b$") then target_moves = tonumber(voortgang:sub(1,-2)) * 2 end
        elseif voortgang == "begin" then
            target_moves = 0
        end
    end
    
    -- Simulate moves
    for i = 1, math.min(target_moves, #moves) do
        local color = (i % 2 == 1) and "white" or "black"
        content.applyMove(matrix, moves[i], color)
    end
    
    return matrix
end

function content.applyMove( matrix, move, color )
    local p_color = (color == "white") and "l" or "d"
    
    -- Castling
    if move == "O-O" then
        local r = (p_color == "l") and 1 or 8
        matrix[r].e, matrix[r].f, matrix[r].g, matrix[r].h = "", "r"..p_color, "k"..p_color, ""
        return
    elseif move == "O-O-O" then
        local r = (p_color == "l") and 1 or 8
        matrix[r].e, matrix[r].d, matrix[r].c, matrix[r].b, matrix[r].a = "", "r"..p_color, "k"..p_color, "", ""
        return
    end

    -- Strip check/mate symbols
    move = move:gsub("[+#?!]", "")
    
    -- Promotion
    local promotion = move:match("=(%a)")
    if promotion then
        move = move:gsub("=%a", "")
        promotion = promotion:lower() .. p_color
    end

    local p_type, from_f_hint, from_r_hint, is_capture, to_f, to_r
    
    if move:match("^%a%d$") then -- e4
        p_type = 'p'
        to_f, to_r = move:match("^(%a)(%d)$")
    elseif move:match("^%a[x]%a%d$") then -- exd5
        p_type = 'p'
        from_f_hint, to_f, to_r = move:match("^(%a)[x](%a)(%d)$")
        is_capture = true
    elseif move:match("^%a%a%d$") then -- Be4 or Nf3
        p_type = move:sub(1,1):lower()
        to_f, to_r = move:match("^%a(%a)(%d)$")
    elseif move:match("^%a[x]%a%d$") then -- Bxe4
        p_type = move:sub(1,1):lower()
        to_f, to_r = move:match("^%a[x](%a)(%d)$")
        is_capture = true
    elseif move:match("^%a%a%a%d$") then -- Nbd2 or R1e2
        p_type = move:sub(1,1):lower()
        local hint = move:sub(2,2)
        if hint:match("%a") then from_f_hint = hint else from_r_hint = tonumber(hint) end
        to_f, to_r = move:match("^%a.%a(%d)$")
    elseif move:match("^%a%a[x]%a%d$") then -- Nbxd2 or R1xe2
        p_type = move:sub(1,1):lower()
        local hint = move:sub(2,2)
        if hint:match("%a") then from_f_hint = hint else from_r_hint = tonumber(hint) end
        to_f, to_r = move:match("^%a.[x](%a)(%d)$")
        is_capture = true
    elseif move:match("^%a%a%a%a%d$") then -- Nb1d2
        p_type = move:sub(1,1):lower()
        from_f_hint = move:sub(2,2)
        from_r_hint = tonumber(move:sub(3,3))
        to_f, to_r = move:sub(4,4), tonumber(move:sub(5,5))
    end
    
    to_r = tonumber(to_r)
    if not to_r then return end
    
    -- Find source square
    local found_r, found_f
    for r = 1, 8 do
        for f_byte = 97, 104 do
            local f = string.char(f_byte)
            local p = matrix[r][f]
            if p == p_type .. p_color then
                if (not from_f_hint or from_f_hint == f) and (not from_r_hint or from_r_hint == r) then
                    if content.isLegalMove(matrix, p, r, f, to_r, to_f) then
                        found_r, found_f = r, f
                        break
                    end
                end
            end
        end
        if found_r then break end
    end
    
    if found_r then
        matrix[found_r][found_f] = ""
        matrix[to_r][to_f] = promotion or (p_type .. p_color)
    end
end

function content.isLegalMove( matrix, piece, from_r, from_f, to_r, to_f )
    local p_type = piece:sub(1,1)
    local p_color = piece:sub(2,2)
    local dr = math.abs(to_r - from_r)
    local df = math.abs(to_f:byte() - from_f:byte())
    
    if p_type == 'n' then
        return (dr == 2 and df == 1) or (dr == 1 and df == 2)
    elseif p_type == 'b' then
        if dr ~= df then return false end
        local step_r = (to_r > from_r) and 1 or -1
        local step_f = (to_f:byte() > from_f:byte()) and 1 or -1
        for i = 1, dr - 1 do
            if matrix[from_r + i * step_r][string.char(from_f:byte() + i * step_f)] ~= "" then return false end
        end
        return true
    elseif p_type == 'r' then
        if dr ~= 0 and df ~= 0 then return false end
        if dr ~= 0 then
            local step = (to_r > from_r) and 1 or -1
            for i = 1, dr - 1 do
                if matrix[from_r + i * step][from_f] ~= "" then return false end
            end
        else
            local step = (to_f:byte() > from_f:byte()) and 1 or -1
            for i = 1, df - 1 do
                if matrix[from_r][string.char(from_f:byte() + i * step)] ~= "" then return false end
            end
        end
        return true
    elseif p_type == 'q' then
        if dr == df then
            local step_r = (to_r > from_r) and 1 or -1
            local step_f = (to_f:byte() > from_f:byte()) and 1 or -1
            for i = 1, dr - 1 do
                if matrix[from_r + i * step_r][string.char(from_f:byte() + i * step_f)] ~= "" then return false end
            end
            return true
        elseif dr == 0 or df == 0 then
            if dr ~= 0 then
                local step = (to_r > from_r) and 1 or -1
                for i = 1, dr - 1 do
                    if matrix[from_r + i * step][from_f] ~= "" then return false end
                end
            else
                local step = (to_f:byte() > from_f:byte()) and 1 or -1
                for i = 1, df - 1 do
                    if matrix[from_r][string.char(from_f:byte() + i * step)] ~= "" then return false end
                end
            end
            return true
        end
    elseif p_type == 'k' then
        return dr <= 1 and df <= 1
    elseif p_type == 'p' then
        if df == 0 then
            if p_color == 'l' then
                if to_r == from_r + 1 then return matrix[to_r][to_f] == "" end
                if to_r == from_r + 2 and from_r == 2 then return matrix[from_r+1][to_f] == "" and matrix[to_r][to_f] == "" end
            else
                if to_r == from_r - 1 then return matrix[to_r][to_f] == "" end
                if to_r == from_r - 2 and from_r == 7 then return matrix[from_r-1][to_f] == "" and matrix[to_r][to_f] == "" end
            end
        elseif df == 1 then
            if p_color == 'l' then return to_r == from_r + 1
            else return to_r == from_r - 1 end
        end
    end
    return false
end

return content;
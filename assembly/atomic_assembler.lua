local function split_string(input_str, delimiter)
	local result = {}
	for match in (input_str .. delimiter):gmatch("(.-)" .. delimiter) do
		table.insert(result, match)
	end
	return result
end

function AssembleAtomicCode(buffer)
	local brainfuck_code = ""

	buffer = buffer:gsub(" ", ";")
	buffer = buffer:gsub("\n", ";")
	buffer = buffer:gsub("\t", ";")

	local tokens = split_string(buffer, ";")
	local is_comment = false

	for index, token in ipairs(tokens) do
		if token == "##" and is_comment then
			brainfuck_code = brainfuck_code .. "\n"
			is_comment = false
		elseif token == "##" and not is_comment then
			brainfuck_code = brainfuck_code .. "\n"
			is_comment = true
		elseif is_comment then
			brainfuck_code = brainfuck_code .. token .. " "
		elseif token == "up" then
			brainfuck_code = brainfuck_code .. ">"
		elseif token == "down" then
			brainfuck_code = brainfuck_code .. "<"
		elseif token == "inc" then
			brainfuck_code = brainfuck_code .. "+"
		elseif token == "dec" then
			brainfuck_code = brainfuck_code .. "-"
		elseif token == "get" then
			brainfuck_code = brainfuck_code .. ","
		elseif token == "set" then
			brainfuck_code = brainfuck_code .. "."
		elseif token == "begin" then
			brainfuck_code = brainfuck_code .. "["
		elseif token == "end" then
			brainfuck_code = brainfuck_code .. "]"
		else
			if token ~= "\0" then
				print("ERROR: The token " .. token .. " is not an atomic token!" .. token)
			end
		end
	end

	return brainfuck_code
end

function AssembleComplexCode(content)
	local atomic = ""
	memory_pointer = 0
	local state = "idle"
	local instruction = {}

	content = content:gsub(" ", ";")
	content = content:gsub("\n", ";")
	content = content:gsub("\t", ";")

	local tokens = split_string(content, ";")
	local is_comment = false

	for index, token in ipairs(tokens) do
		if token == "##" and is_comment then
			atomic = atomic .. " ##\n"
			is_comment = false
		elseif token == "##" and not is_comment then
			atomic = "## " .. atomic .. "\n"
			is_comment = true
		elseif is_comment then
			atomic = atomic .. token .. " "
		elseif state == "idle" then
			state, instruction = decode_instruction(token)
		elseif state == "twooperands" then
			table.insert(instruction, token)
			state = "oneoperand"
		elseif state == "oneoperand" then
			table.insert(instruction, token)
			state = "handling"
		elseif state == "handling" then
			atomic = handle_instrcution(content, instruction)
		else
			if token ~= "\0" then
				print("ERROR: The token " .. token .. " is not a valid instruction!")
			end
		end
	end

	return atomic
end

local function decode_instruction(operand_token)
	local singop = {}
	local oneop = { "loop" }
	local twoop = { "add", "sub" }

	if singop[operand_token] ~= nil then
		return "handle", { operand_token }
	elseif oneop[operand_token] ~= nil then
		return "oneoperand", { operand_token }
	elseif twoop[operand_token] ~= nil then
		return "twooperands", { operand_token }
	end

	return "idle", {}
end

local function abs(number)
	if number < 0 then
		return number * -1
	else
		return number
	end
end

local function get_fix_move(origin, destination)
	local direction
	local route = ""

	if origin < destination then
		direction = "up"
	else
		direction = "down"
	end

	for i = 0, abs(destination - origin) do
		route = route .. direction .. " "
	end

	return route
end

local function handle_instrcution(content, instruction)
	local atomic_code

	if instruction[1] == "add" then
		local reg1 = tonumber(instruction[2]:sub(2)) + 8
		local reg2 = tonumber(instruction[3]:sub(2)) + 8
		local old_pos = memory_pointer

		atomic_code = "## ADD " .. instruction[2] .. " to " .. instruction[3] .. " ##\n"

		local move_to_operation = get_fix_move(old_pos, reg1)
		local reg1_to_t1 = get_fix_move(reg1, 0)
		local t2_to_reg1 = get_fix_move(2, reg1)
		local reg1_to_t2 = get_fix_move(reg1, 2)
		local t1_to_reg2 = get_fix_move(1, reg2)
		local reg2_to_t1 = get_fix_move(reg2, 1)
		local t1_to_origin = get_fix_move(1, old_pos)

		atomic_code = atomic_code .. move_to_operation
		-- Move reg1 into t1,t2
		atomic_code = atomic_code .. "begin dec " .. reg1_to_t1 .. "inc up inc " .. t2_to_reg1 .. "end "
		-- Move t2 into reg1
		atomic_code = atomic_code .. reg1_to_t2 .. "begin dec " .. t2_to_reg1 .. "inc " .. reg1_to_t2 .. "end "
		-- Move to t1
		atomic_code = atomic_code .. "down "
		-- Move t1 into reg2
		atomic_code = atomic_code .. "begin dec " .. t1_to_reg2 .. "inc " .. reg2_to_t1 .. "end "
		-- Restore old position
		atomic_code = atomic_code .. t1_to_origin
	elseif instruction[1] == "sub" then
		local reg1 = tonumber(instruction[2]:sub(2)) + 8
		local reg2 = tonumber(instruction[3]:sub(2)) + 8
		local old_pos = memory_pointer

		local move_to_operation = get_fix_move(old_pos, reg1)
		local reg1_to_t1 = get_fix_move(reg1, 1)
		local t1_to_reg1 = get_fix_move(1, reg1)
		local reg1_to_reg2 = get_fix_move(reg1, reg2)
		local reg2_to_t1 = get_fix_move(reg2, 1)
		local t1_to_origin = get_fix_move(1, old_pos)

		atomic_code = "## SUB " .. instruction[2] .. " to " .. instruction[3] .. " ##\n"

		--move to reg1
		atomic_code = atomic_code .. move_to_operation
		-- move reg1 into t1
		atomic_code = atomic_code .. "begin dec " .. reg1_to_t1 .. "inc " .. t1_to_reg1 .. "end "
		-- move to t1
		atomic_code = atomic_code .. reg1_to_t1
		-- move t1 to reg1 and remove from reg2
		atomic_code = atomic_code
			.. "begin dec "
			.. t1_to_reg1
			.. "inc "
			.. reg1_to_reg2
			.. "dec "
			.. reg2_to_t1
			.. "end "
		-- return to origin
		atomic_code = atomic_code .. t1_to_origin
	elseif instruction[1] == "loop" then
		local reg = tonumber(instruction[2]:sub(2)) + 8
		print("ERROR: Loops are not yet implemented!")
	else
		print("ERROR: The instruction " .. instruction[1] .. " is not a valid instruction!")
		return content
	end

	return content .. atomic_code
end

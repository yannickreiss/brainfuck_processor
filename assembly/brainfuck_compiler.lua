function wait(seconds)
	local start = os.time()
	repeat
	until os.time() > start + seconds
end

function CompileBrainfuck(brainfuck, target)
	local machine_code = "("

	if target == "vhdl" then
		machine_code = "("
	elseif target == "logisim" then
		machine_code = "v3.0 hex words plain\n"
	else
		print("ERROR: Target " .. target .. " is not supported!")
	end

	for i = 0, #brainfuck do
		local token = brainfuck:sub(i, i)

		if target == "vhdl" then
			if token == ">" then
				machine_code = machine_code .. 'b"000",'
			elseif token == "<" then
				machine_code = machine_code .. 'b"001",'
			elseif token == "+" then
				machine_code = machine_code .. 'b"010",'
			elseif token == "-" then
				machine_code = machine_code .. 'b"011",'
			elseif token == "," then
				machine_code = machine_code .. 'b"100",'
			elseif token == "." then
				machine_code = machine_code .. 'b"101",'
			elseif token == "[" then
				machine_code = machine_code .. 'b"110",'
			elseif token == "]" then
				machine_code = machine_code .. 'b"111",'
			end
		elseif target == "logisim" then
			local found_token = false
			if token == ">" then
				machine_code = machine_code .. "0"
				found_token = true
			elseif token == "<" then
				machine_code = machine_code .. "1"
				found_token = true
			elseif token == "+" then
				machine_code = machine_code .. "2"
				found_token = true
			elseif token == "-" then
				machine_code = machine_code .. "3"
				found_token = true
			elseif token == "," then
				machine_code = machine_code .. "4"
				found_token = true
			elseif token == "." then
				machine_code = machine_code .. "5"
				found_token = true
			elseif token == "[" then
				machine_code = machine_code .. "6"
				found_token = true
			elseif token == "]" then
				machine_code = machine_code .. "7"
				found_token = true
			end

			if found_token then
				if (#machine_code - 20) % 64 == 0 then
					machine_code = machine_code .. "\n"
				else
					machine_code = machine_code .. " "
				end
			end
		else
			print("ERROR: Target " .. target .. " is not supported!")
		end
	end

	if target == "vhdl" then

	machine_code = machine_code .. 'others => "000");\n'

	elseif target == "logisim" then
		while #machine_code < 533 do
			machine_code = machine_code .. '0'
			
			if (#machine_code - 20) % 64 == 0 then
				machine_code = machine_code .. "\n"
			else
				machine_code = machine_code .. " "
			end
		end
	else
		print("ERROR: Target " .. target .. " not found!")
	end

	return machine_code
end

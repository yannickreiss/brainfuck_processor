require("complex_assembler")
require("atomic_assembler")
require("brainfuck_compiler")

local file = io.open("basic_logic.bf", "r")
local content = ""
if file ~= nil then
	content = file:read("*all")
else
	print("ERROR: Input file not found!")
end

local atomic = AssembleComplexCode(content)

local brainfuck = AssembleAtomicCode(atomic)

local machine_code = CompileBrainfuck(brainfuck, "logisim")

print(brainfuck)
print(machine_code)

local logisim_file = io.open("logisim.mem", "w")

logisim_file:write(machine_code)

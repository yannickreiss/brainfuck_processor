-- branch.vhd
-- Created on: Di 26. Sep 13:47:51 CEST 2023
-- Author(s): Yannick Reiss <yannick.reiss@protonmail.ch>
-- Content: Branch unit / ALU for program counter XD
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- TODO: CHECK PUSH AND POP AND THE PHASES/STATES OF PC_ENABLE

-- Entity branch: branch
entity branch is
    port(
        clk	        :	in	std_logic;
		instruction	:	in	std_logic_vector(2 downto 0);
		instr_addr	:	in	std_logic_vector(7 downto 0);
        cell_value  :   in  std_logic_vector(7 downto 0);

        skip        :   out std_logic;
		pc_enable	:	out	std_logic;
        jump        :   out std_logic;
		pc_out	    :   out	std_logic_vector(7 downto 0)
    );
end branch;

-- Architecture impl of branch:
architecture impl of branch is
    type stack is array(0 to 255) of std_logic_vector(7 downto 0);

    signal addr_stack       : stack := (others => (others => '0'));
    signal nested           : std_logic_vector(7 downto 0) := (others => '0'); -- count nested loops
    signal skip_internal    : std_logic := '0';
    signal stack_ptr        : std_logic_vector(7 downto 0) := (others => '0');
    signal pc_enable_internal : std_logic := '1';

begin

    -- Process p_branch: set skip to true
    p_branch : process (clk, skip_internal, instruction, cell_value)
    begin
        if rising_edge(clk) then

            if instruction = "110" and unsigned(cell_value) = 0 and unsigned(nested) = 0 and skip_internal = '0' then
                skip_internal <= '1';
            end if;

            -- set skip to false
            if instruction = "111" and unsigned(nested) = 0 and skip_internal = '1' then
                skip_internal <= '0';
            end if;

            -- Process p_nest : raise nest by one as [ is passed
            if instruction = "110" and skip_internal = '1' then
                nested <= std_logic_vector(unsigned(nested) + 1);
            end if;

            -- Process p_unnest : lower nest, as ] is passed
            if instruction = "111" and unsigned(nested) > 0 and skip_internal = '1' then
                nested <= std_logic_vector(unsigned(nested) - 1);
            end if;

            -- Process p_push : raise stack and push address
            if instruction = "110" and unsigned(cell_value) > 0 and skip_internal = '0' then

                if pc_enable_internal = '0' then
                    -- restore push_state and push address
                    addr_stack(to_integer(unsigned(stack_ptr))) <= instr_addr;
                    pc_enable_internal <= '1';
                else
                    -- raise stack, disable pc and unset push_state
                    stack_ptr <= std_logic_vector(unsigned(stack_ptr) + 1);
                    pc_enable_internal <= '0';
                end if;
            end if;

            -- Process p_pop : read address to jump address and lower stack
            if instruction = "111" and unsigned(cell_value) > 0 and skip_internal = '1' then
                if pc_enable_internal = '0' then
                    -- set address to pc_out, disable pc and unset push_state
                    -- pc_out <= addr_stack(to_integer(unsigned(stack_ptr))); TODO: restore if error with continuous assignment
                    pc_enable_internal <= '1';
                else
                    -- set pc to enabled, restore push_state and lower stack
                    pc_enable_internal <= '0';
                    stack_ptr <= std_logic_vector(unsigned(stack_ptr) - 1);
                end if;
            end if;

            -- regulate jump
            if instruction = "111" and unsigned(cell_value) > 0 and skip_internal = '0' and pc_enable_internal = '1' then
                jump <= '1';
            else
                jump <= '0';
            end if;
        end if;
    end process;

    skip        <=  skip_internal;
    pc_enable   <=  pc_enable_internal;
    pc_out      <= addr_stack(to_integer(unsigned(stack_ptr)));

end impl;

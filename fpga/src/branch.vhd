-- branch.vhd
-- Created on: Di 26. Sep 13:47:51 CEST 2023
-- Author(s): Yannick Reiss <yannick.reiss@protonmail.ch>
-- Content: Branch unit / ALU for program counter XD
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Entity branch: branch
entity branch is
    port(
        clk	        :	in	std_logic;
		instruction	:	in	std_logic_vector(2 downto 0);
		instr_addr	:	in	std_logic_vector(7 downto 0);
        cell_value  :   in  std_logic_vector(7 downto 0);

        skip        :   out std_logic;
		pc_enable	:	out	std_logic;
		pc_out	    :   out	std_logic_vector(7 downto 0)
    );
end branch;

-- Architecture impl of branch:
architecture impl of branch is
    type stack is array(0 to 255) of std_logic_vector(7 downto 0);

    signal addr_stack       : stack := (others => (others => '0'));
    signal nested           : std_logic_vector(7 downto 0) := (others => '0'); -- count nested loops
    signal jump_destination : std_logic_vector(7 downto 0);
    signal skip_internal    : std_logic := '0';
    signal stack_ptr        : std_logic_vector(7 downto 0) := (others => '0');
    signal push_state       : std_logic;

begin

    -- Process p_skip: set skip to true
    p_skip : process (clk)
    begin
        if rising_edge(clk) then
            if instruction = "110" and unsigned(cell_value) = 0 and unsigned(nested) = 0 and skip_internal = '0' then
                skip_internal <= '1';
            end if;
        end if;
    end process;
    
    -- Process p_continue: set skip to false
    p_continue : process (clk)
    begin
        if rising_edge(clk) then
            if instruction = "111" and unsigned(nested) = 0 and skip_internal = '1' then
                skip_internal <= '0';
            end if;
        end if;
    end process;
    
    -- Process p_nest : raise nest by one as [ is passed
    p_nest : process (clk)
    begin
        if rising_edge(clk) then
            if instruction = "110" and skip_internal = '1' then
                nested <= std_logic_vector(unsigned(nested) + 1);
            end if;
        end if;
    end process;
    
    -- Process p_unnest : lower nest, as ] is passed
    p_unnest : process (clk)
    begin
        if rising_edge(clk) then
            if instruction = "111" and unsigned(nested) > 0 and skip_internal = '1' then
                nested <= std_logic_vector(unsigned(nested) - 1);
            end if;
        end if;
    end process;
    
    -- Process p_push : raise stack and push address
    p_push : process (clk)
    begin
        -- TODO: Implement
    end process;
    
    -- Process p_pop : read address to jump address and lower stack
    p_pop : process (clk)
    begin
        -- TODO: Implement
    end process;
    
    skip <= skip_internal;

end impl;

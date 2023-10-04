-- tb_bfpu
-- 2023-10-04
-- Author: Yannick Reiß
-- E-Mail: yannick.reiss@protonmail.ch
-- Copyright: MIT
-- Content: Entity tb_bfpu - Run bfpu for testbench.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;

entity bfpu_tb is
end bfpu_tb;

architecture implementation of bfpu_tb is

    -- input
    signal clk      :   std_logic;
    signal sw       :   std_logic_vector(7 downto 0);

    -- output
    signal debug    :   std_logic_vector(7 downto 0);
    signal led      :   std_logic_vector(7 downto 0);
    
    constant clk_period : time := 10 ns;

begin

    uut : entity work.bfpu(arch)
        port map (
            clk     =>  clk,
            sw      =>  sw,
            debug   =>  debug,
            led     =>  led);

    sw      <= "00110011";

    -- Clock process definitions
    clk_process :   process
    begin
        clk <= '0';
        wait for clk_period / 2;
        clk <= '1';
        wait for clk_period / 2;
    end process;

    -- Process stim_proc
    stim_proc : process
        variable lineBuffer : line;
    begin
        write(lineBuffer, string'("Start the simulator"));
        writeline(output, lineBuffer);

        wait;
    end process;

end implementation ; -- implementation
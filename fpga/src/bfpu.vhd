-- bfpu.vhd
-- Created on: Di 26. Sep 08:27:47 CEST 2023
-- Author(s): Yannick Reiß
-- Content: Connect the entities of the processing unit.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Entity bfpu: brainfuck processing unit
entity bfpu is
    port (
        clk   : in  std_logic; -- board clock
        sw    : in  std_logic_vector(7 downto 0); -- Input for instruction ,
        debug : out std_logic_vector(7 downto 0); -- Value of currently selected logic cell.
        led   : out std_logic_vector(7 downto 0) -- Output for instruction .
    );
end entity bfpu;

-- Architecture arch of bfpu: setup and connect components
architecture arch of bfpu is

    component instructionMemory is
        port (
            instructionAddr : in  std_logic_vector(7 downto 0);
            instruction     : out std_logic_vector(2 downto 0)
        );
    end component instructionMemory;

    component alu is
        port (
            instruction : in  std_logic_vector(2 downto 0);
            old_cell    : in  std_logic_vector(7 downto 0);
            old_pointer : in  std_logic_vector(15 downto 0);
            extern_in   : in  std_logic_vector(7 downto 0);

            new_cell    : out std_logic_vector(7 downto 0);
            new_pointer : out std_logic_vector(15 downto 0);
            enable_cell : out std_logic;
            enable_ptr  : out std_logic;
            extern_out  : out std_logic_vector(7 downto 0)
        );
    end component alu;

    component ptr is
        port (
            clk        : in  std_logic;
            enable_ptr : in  std_logic;
            new_ptr    : in  std_logic_vector(15 downto 0);
            old_ptr    : out std_logic_vector(15 downto 0)
        );
    end component ptr;

    component cellblock is
        port (
            clk      : in  std_logic;
            enable   : in  std_logic;
            address  : in  std_logic_vector(15 downto 0);
            new_cell : in  std_logic_vector(7 downto 0);
            old_cell : out std_logic_vector(7 downto 0)
        );
    end component cellblock;

    component program_counter is
        port (
            clk    : in  std_logic;
            enable : in  std_logic;
            jmp    : in  std_logic;
            pc_in  : in  std_logic_vector(7 downto 0);
            pc_out : out std_logic_vector(7 downto 0)
        );
    end component program_counter;

    component branch is
        port (
            clk         : in  std_logic;
            state       : in  std_logic;
            instruction : in  std_logic_vector(2 downto 0);
            instr_addr  : in  std_logic_vector(7 downto 0);
            cell_value  : in  std_logic_vector(7 downto 0);

            skip        : out std_logic;
            jump        : out std_logic;
            pc_enable   : out std_logic;
            pc_out      : out std_logic_vector(7 downto 0)
        );
    end component branch;

    signal s_clk            : std_logic;
    signal s_in             : std_logic_vector(7 downto 0)  := (others => '0');
    signal s_out            : std_logic_vector(7 downto 0)  := (others => '0');
    signal s_led            : std_logic_vector(7 downto 0)  := (others => '0');

    signal s_instrAddr      : std_logic_vector(7 downto 0)  := "00000000";
    signal s_instruction    : std_logic_vector(2 downto 0)  := "000";

    signal s_cell_out       : std_logic_vector(7 downto 0)  := (others => '0');
    signal s_cell_in        : std_logic_vector(7 downto 0)  := (others => '0');
    signal s_ptr_out        : std_logic_vector(15 downto 0) := (others => '0');
    signal s_ptr_in         : std_logic_vector(15 downto 0) := (others => '0');

    signal s_enable_cells   : std_logic                     := '0';
    signal s_enable_ptr     : std_logic                     := '0';

    signal s_enable_pc      : std_logic                     := '1';
    signal s_jmp_pc         : std_logic                     := '0';
    signal s_jmp_addr_pc    : std_logic_vector(7 downto 0)  := "00000000";

    signal s_skip           : std_logic                     := '0';
    signal s_enable_cells_o : std_logic                     := '0';
    signal s_enable_ptr_o   : std_logic                     := '0';

    signal processor_state  : std_logic                     := '0'; -- 0: execute; 1: write back

begin

    -- clock and state logic
    s_clk                   <= clk;
    -- Process state  change state between execute and write back
    state: process (s_clk) is                                       -- runs only, when s_clk changed
    begin
        if rising_edge(s_clk) then
            processor_state <= not processor_state;
        end if;
    end process state;

    -- Process in_out  set in- and output on clk high and exec/write back
    in_out: process (s_clk) is                                      -- runs only, when s_clk changed
    begin
        if rising_edge(s_clk) then
            if processor_state = '1' then
                s_led       <= s_out;
            else
                s_in        <= sw;
            end if;
        end if;
    end process in_out;


    instrMemory: component instructionMemory
    port map (
        instructionAddr => s_instrAddr,
        instruction     => s_instruction
    );

    alu_entity: component alu
    port map (
        instruction     => s_instruction,
        old_cell        => s_cell_out,
        old_pointer     => s_ptr_out,
        extern_in       => s_in,

        new_cell        => s_cell_in,
        new_pointer     => s_ptr_in,
        enable_cell     => s_enable_cells_o,
        enable_ptr      => s_enable_ptr_o,
        extern_out      => s_out
    );

    ptr_bf: component ptr
    port map (
        clk             => s_clk,
        enable_ptr      => s_enable_ptr,
        new_ptr         => s_ptr_in,
        old_ptr         => s_ptr_out
    );

    cellblock_bf: component cellblock
    port map (
        clk             => s_clk,
        enable          => s_enable_cells,
        address         => s_ptr_out,
        new_cell        => s_cell_in,
        old_cell        => s_cell_out
    );

    pc: component program_counter
    port map (
        clk             => s_clk,
        enable          => s_enable_pc and processor_state,
        jmp             => s_jmp_pc,
        pc_in           => s_jmp_addr_pc,
        pc_out          => s_instrAddr
    );

    branch_bf: component branch
    port map (
        clk             => s_clk,
        state           => processor_state,
        instruction     => s_instruction,
        instr_addr      => s_instrAddr,
        cell_value      => s_cell_out,
        skip            => s_skip,
        jump            => s_jmp_pc,
        pc_enable       => s_enable_pc,
        pc_out          => s_jmp_addr_pc
    );

    s_enable_ptr            <= not s_skip and s_enable_ptr_o and processor_state;
    s_enable_cells          <= not s_skip and s_enable_cells_o and processor_state;
    debug                   <= s_cell_out;
    led                     <= s_led;

end architecture arch;

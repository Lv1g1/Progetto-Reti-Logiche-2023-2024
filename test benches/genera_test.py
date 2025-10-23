import random

test_bench = """
-- TB EXAMPLE PFRL 2023-2024

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity project_tb is
end project_tb;

architecture project_tb_arch of project_tb is
    constant CLOCK_PERIOD : time := 20 ns;
    signal tb_clk : std_logic := '0';
    signal tb_rst, tb_start, tb_done : std_logic;
    signal tb_add : std_logic_vector(15 downto 0);
    signal tb_k   : std_logic_vector(9 downto 0);

    signal tb_o_mem_addr, exc_o_mem_addr, init_o_mem_addr : std_logic_vector(15 downto 0);
    signal tb_o_mem_data, exc_o_mem_data, init_o_mem_data : std_logic_vector(7 downto 0);
    signal tb_i_mem_data : std_logic_vector(7 downto 0);
    signal tb_o_mem_we, tb_o_mem_en, exc_o_mem_we, exc_o_mem_en, init_o_mem_we, init_o_mem_en : std_logic;

    type ram_type is array (65535 downto 0) of std_logic_vector(7 downto 0);
    signal RAM : ram_type := (OTHERS => "00000000");

    {} -- SCENARIO DEFINITION

    signal memory_control : std_logic := '0';

    component project_reti_logiche is
        port (
                i_clk : in std_logic;
                i_rst : in std_logic;
                i_start : in std_logic;
                i_add : in std_logic_vector(15 downto 0);
                i_k   : in std_logic_vector(9 downto 0);
                
                o_done : out std_logic;
                
                o_mem_addr : out std_logic_vector(15 downto 0);
                i_mem_data : in  std_logic_vector(7 downto 0);
                o_mem_data : out std_logic_vector(7 downto 0);
                o_mem_we   : out std_logic;
                o_mem_en   : out std_logic
        );
    end component project_reti_logiche;

begin
    UUT : project_reti_logiche
    port map(
                i_clk   => tb_clk,
                i_rst   => tb_rst,
                i_start => tb_start,
                i_add   => tb_add,
                i_k     => tb_k,
                
                o_done => tb_done,
                
                o_mem_addr => exc_o_mem_addr,
                i_mem_data => tb_i_mem_data,
                o_mem_data => exc_o_mem_data,
                o_mem_we   => exc_o_mem_we,
                o_mem_en   => exc_o_mem_en
    );

    -- Clock generation
    tb_clk <= not tb_clk after CLOCK_PERIOD/2;

    -- Process related to the memory
    MEM : process (tb_clk)
    begin
        if tb_clk'event and tb_clk = '1' then
            if tb_o_mem_en = '1' then
                if tb_o_mem_we = '1' then
                    RAM(to_integer(unsigned(tb_o_mem_addr))) <= tb_o_mem_data after 1 ns;
                    tb_i_mem_data <= tb_o_mem_data after 1 ns;
                else
                    tb_i_mem_data <= RAM(to_integer(unsigned(tb_o_mem_addr))) after 1 ns;
                end if;
            end if;
        end if;
    end process;
    
    memory_signal_swapper : process(memory_control, init_o_mem_addr, init_o_mem_data,
                                    init_o_mem_en,  init_o_mem_we,   exc_o_mem_addr,
                                    exc_o_mem_data, exc_o_mem_en, exc_o_mem_we)
    begin
        -- This is necessary for the testbench to work: we swap the memory
        -- signals from the component to the testbench when needed.
    
        tb_o_mem_addr <= init_o_mem_addr;
        tb_o_mem_data <= init_o_mem_data;
        tb_o_mem_en   <= init_o_mem_en;
        tb_o_mem_we   <= init_o_mem_we;

        if memory_control = '1' then
            tb_o_mem_addr <= exc_o_mem_addr;
            tb_o_mem_data <= exc_o_mem_data;
            tb_o_mem_en   <= exc_o_mem_en;
            tb_o_mem_we   <= exc_o_mem_we;
        end if;
    end process;
    
    -- This process provides the correct scenario on the signal controlled by the TB
    create_scenario : process
    begin
        wait for 50 ns;

        -- Signal initialization and reset of the component
        tb_start <= '0';
        tb_add <= (others=>'0');
        tb_k   <= (others=>'0');
        tb_rst <= '1';
        
        -- Wait some time for the component to reset...
        wait for 50 ns;
        
        tb_rst <= '0';
        memory_control <= '0';  -- Memory controlled by the testbench
        
        wait until falling_edge(tb_clk); -- Skew the testbench transitions with respect to the clock

        -- Configure the memory        
        {} -- SCENARIO CONFIGURATION
        
        wait until falling_edge(tb_clk);

        memory_control <= '1';  -- Memory controlled by the component
        
        {} -- SCENARIO EXECUTION
        
        wait;
        
    end process;

    -- Process without sensitivity list designed to test the actual component.
    test_routine : process
    begin
        wait until tb_rst = '1';
        wait for 25 ns;
        assert tb_done = '0' report "TEST FALLITO o_done !=0 during reset" severity failure;
        wait until tb_rst = '0';

        wait until falling_edge(tb_clk);
        assert tb_done = '0' report "TEST FALLITO o_done !=0 after reset before start" severity failure;

        wait until rising_edge(tb_start);
    
        {} -- SCENARIO CHECK

        assert false report "Simulation Ended! TEST PASSATO (EXAMPLE)" severity failure;
    end process;

end architecture;

"""

NUM_SCENARI = 10
DIM_SCENARI = [1023 for i in range(NUM_SCENARI)]

scenario_definition = ""
write_scenario = ""
execution_scenario = ""
scenario_check = ""

for i in range(NUM_SCENARI):
    scenario_definition += f"""
    constant SCENARIO_LENGTH_{i} : integer := {DIM_SCENARI[i]};
    type scenario_type_{i} is array (0 to SCENARIO_LENGTH_{i}*2-1) of integer;

    signal scenario_input_{i} : scenario_type_{i} := ("""

    scenario_input = []

    for j in range(DIM_SCENARI[i]):
        scenario_input.append(random.randint(0, 255))
        
        if j == 0:
            scenario_definition += f"{scenario_input[j]}, 0"
        else:
            scenario_definition += f", {scenario_input[j]}, 0"
    
    scenario_definition += f");"

    scenario_definition += f"""
    signal scenario_full_{i}  : scenario_type_{i} := ("""
    last_valid = 0
    cred = 0
    for j, dato in enumerate(scenario_input):
        if dato != 0:
            cred = 31
            last_valid = dato
        else:
            cred = cred - 1 if cred > 0 else 0

        if j == 0:
            scenario_definition += f"{last_valid}, {cred}"
        else:
            scenario_definition += f", {last_valid}, {cred}"
    
    scenario_definition += f");"

    scenario_definition += f"""
    constant SCENARIO_ADDRESS_{i} : integer := {i*1024};
    """

    write_scenario += f"""
        for i in 0 to SCENARIO_LENGTH_{i}*2-1 loop
            init_o_mem_addr<= std_logic_vector(to_unsigned(SCENARIO_ADDRESS_{i}+i, 16));
            init_o_mem_data<= std_logic_vector(to_unsigned(scenario_input_{i}(i),8));
            init_o_mem_en  <= '1';
            init_o_mem_we  <= '1';
            wait until rising_edge(tb_clk);   
        end loop;
    """

    execution_scenario += f"""
        tb_add <= std_logic_vector(to_unsigned(SCENARIO_ADDRESS_{i}, 16));
        tb_k   <= std_logic_vector(to_unsigned(SCENARIO_LENGTH_{i}, 10));

        tb_start <= '1';

        while tb_done /= '1' loop
            wait until rising_edge(tb_clk);
        end loop;

        wait for 5 ns;

        tb_start <= '0';

        wait for 100 ns;
    """

    scenario_check += f"""
        while tb_done /= '1' loop                
            wait until rising_edge(tb_clk);
        end loop;
 
        assert tb_o_mem_en = '0' or tb_o_mem_we = '0' report "TEST FALLITO o_mem_en !=0 memory should not be written after done." severity failure;

        for i in 0 to SCENARIO_LENGTH_{i}*2-1 loop
            assert RAM(SCENARIO_ADDRESS_{i}+i) = std_logic_vector(to_unsigned(scenario_full_{i}(i),8)) report "TEST {i} FALLITO @ OFFSET=" & integer'image(i) & " expected= " & integer'image(scenario_full_{i}(i)) & " actual=" & integer'image(to_integer(unsigned(RAM(i))) severity failure;
        end loop;

        assert tb_done = '1' report "TEST {i} FALLITO o_done !=0 after reset before start" severity failure;

        wait until falling_edge(tb_done);
    """

test_bench = test_bench.format(scenario_definition, write_scenario, execution_scenario, scenario_check)

with open("project_tb.vhd", "w") as f:
    f.write(test_bench)
    f.close()
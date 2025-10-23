library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity project_reti_logiche is
    Port ( i_clk : in STD_LOGIC;
           i_rst : in STD_LOGIC;
           i_start : in STD_LOGIC;
           i_add : in STD_LOGIC_VECTOR (15 downto 0);
           i_k : in STD_LOGIC_VECTOR (9 downto 0);
           i_mem_data : in STD_LOGIC_VECTOR (7 downto 0);
           o_mem_en : out STD_LOGIC;
           o_mem_we : out STD_LOGIC;
           o_mem_addr : out STD_LOGIC_VECTOR (15 downto 0);
           o_mem_data : out STD_LOGIC_VECTOR (7 downto 0);
           o_done : out STD_LOGIC);
end project_reti_logiche;

architecture project_reti_logiche_arch of project_reti_logiche is

    component counter is
       Port (
           inc : in STD_LOGIC;
           i_clk : in STD_LOGIC;
           i_rst : in STD_LOGIC;
           index : out STD_LOGIC_VECTOR (9 downto 0)
       );
    end component;
    
    component adder is
            Port (
            i_add : in STD_LOGIC_VECTOR (15 downto 0);
            index : in STD_LOGIC_VECTOR (9 downto 0);
            addr_data : out STD_LOGIC_VECTOR (15 downto 0);
            addr_cred : out STD_LOGIC_VECTOR (15 downto 0)
        );
    end component;

    component mux_addr is
        Port (
            addr_data : in STD_LOGIC_VECTOR (15 downto 0);
            addr_cred : in STD_LOGIC_VECTOR (15 downto 0);
            sel : in STD_LOGIC;
            o_mem_addr : out STD_LOGIC_VECTOR (15 downto 0)
        );
    end component;

    component check_end is
        Port (
            index : in STD_LOGIC_VECTOR (9 downto 0);
            i_k : in STD_LOGIC_VECTOR (9 downto 0);
            end_signal : out STD_LOGIC
        );
    end component;

    component fsm is
        Port (
            i_start : in STD_LOGIC;
            i_clk : in STD_LOGIC;
            i_rst : in STD_LOGIC;
            end_signal : in STD_LOGIC;
            valid : in STD_LOGIC;
            inc : out STD_LOGIC;
            sel : out STD_LOGIC;
            o_mem_we : out STD_LOGIC;
            o_mem_en : out STD_LOGIC;
            o_done : out STD_LOGIC
        );
    end component;

    component validation is
        Port (
            i_mem_data : in STD_LOGIC_VECTOR (7 downto 0);
            valid : out STD_LOGIC
        );
    end component;
    
    component last_valid_data is
        Port (
            i_mem_data : in STD_LOGIC_VECTOR (7 downto 0);
            next_data : in STD_LOGIC;
            i_clk : in STD_LOGIC;
            i_rst : in STD_LOGIC;
            data : out STD_LOGIC_VECTOR (7 downto 0)
        );
    end component;
    
    component mux_data is
        Port (
            cred : in STD_LOGIC_VECTOR (4 downto 0);
            data : in STD_LOGIC_VECTOR (7 downto 0);
            sel : in STD_LOGIC;
            o_mem_data : out STD_LOGIC_VECTOR (7 downto 0)
        );
    end component;
    
    component credibility is
        Port (
            i_clk : in STD_LOGIC;
            i_rst : in STD_LOGIC;
            next_data : in STD_LOGIC;
            cred : in STD_LOGIC_VECTOR (4 downto 0);
            prec_cred : out STD_LOGIC_VECTOR (4 downto 0)
        );
    end component;
  
    component calc_cred is
        Port (
            valid : in STD_LOGIC;
            prec_cred : in STD_LOGIC_VECTOR (4 downto 0);
            cred : out STD_LOGIC_VECTOR (4 downto 0)
        );
    end component;
    
    signal inc : STD_LOGIC;
    signal index : STD_LOGIC_VECTOR (9 downto 0);
    signal addr_data : STD_LOGIC_VECTOR (15 downto 0);
    signal addr_cred : STD_LOGIC_VECTOR (15 downto 0);
    signal end_signal : STD_LOGIC;
    signal sel : STD_LOGIC;
    signal valid : STD_LOGIC;
    signal cred : STD_LOGIC_VECTOR (4 downto 0);
    signal prec_cred : STD_LOGIC_VECTOR (4 downto 0);
    signal data : STD_LOGIC_VECTOR (7 downto 0);
    
    signal fsm_done : STD_LOGIC;
    signal reset : STD_LOGIC;
    
    
begin
    -- or tra i_rst e fsm_done
    process(i_rst, fsm_done)
    --Combinatorio
    begin
        reset <= i_rst or fsm_done;
        o_done <= fsm_done;
    end process;


    U0: counter
        Port Map (
           inc => inc,
           i_clk => i_clk,
           i_rst => reset,
           index => index
        );
    
    U1: adder
        Port Map (
            i_add => i_add,
            index => index,
            addr_data => addr_data,
            addr_cred => addr_cred
        );

    U2: mux_addr
        Port Map (
            addr_data => addr_data,
            addr_cred => addr_cred,
            sel => sel,
            o_mem_addr => o_mem_addr
        );

    U3: check_end
        Port Map (
            index => index,
            i_k => i_k,
            end_signal => end_signal
        );

    U4: fsm
        Port Map (
            i_start => i_start,
            i_clk => i_clk,
            i_rst => i_rst,
            end_signal => end_signal,
            valid => valid,
            inc => inc,
            sel => sel,
            o_mem_we => o_mem_we,
            o_mem_en => o_mem_en,
            o_done => fsm_done
        );

    U5: validation
        Port Map (
            i_mem_data => i_mem_data,
            valid => valid
        );
    
    U6: last_valid_data
        Port Map (
            i_mem_data => i_mem_data,
            next_data => sel,
            i_clk => i_clk,
            i_rst => reset,
            data => data
        );
    
    U7: mux_data
        Port Map (
            cred => cred,
            data => data,
            sel => sel,
            o_mem_data => o_mem_data
        );
    
    U8: credibility
        Port Map (
            i_clk => i_clk,
            i_rst => reset,
            next_data => sel,
            cred => cred,
            prec_cred => prec_cred
        );
  
    U9: calc_cred
        Port Map (
            valid => valid,
            prec_cred => prec_cred,
            cred => cred
        );

end project_reti_logiche_arch;

--------------------------------------------------- ADDER ---------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity adder is
    Port ( i_add : in STD_LOGIC_VECTOR (15 downto 0);
           index : in STD_LOGIC_VECTOR (9 downto 0);
           addr_data : out STD_LOGIC_VECTOR (15 downto 0);
           addr_cred : out STD_LOGIC_VECTOR (15 downto 0));
end adder;

architecture adder_arch of adder is

begin
    process(i_add, index)
    --Combinatorio
    begin
        addr_data <= STD_LOGIC_VECTOR(unsigned(i_add) + unsigned(index & '0'));
        addr_cred <= STD_LOGIC_VECTOR(unsigned(i_add) + unsigned(index & '0') + 1);
        
    end process;

end adder_arch;

--------------------------------------------------- CALC_CRED ---------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity calc_cred is
    Port ( prec_cred : in STD_LOGIC_VECTOR (4 downto 0);
           valid : in STD_LOGIC;
           cred : out STD_LOGIC_VECTOR (4 downto 0));
end calc_cred;

architecture calc_cred_arch of calc_cred is

begin
    process(prec_cred, valid)
    --Combinatorio
    begin
        if valid = '1' then
            cred <= "11111";
        else
            if prec_cred = "00000" then
                cred <= "00000";
            else
                cred <= STD_LOGIC_VECTOR(unsigned(prec_cred) - 1);
            
            end if;
            
        end if;

    end process;

end calc_cred_arch;

--------------------------------------------------- CHECK_END ---------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity check_end is
    Port ( i_k : in STD_LOGIC_VECTOR (9 downto 0);
           index : in STD_LOGIC_VECTOR (9 downto 0);
           end_signal : out STD_LOGIC);
end check_end;

architecture check_end_arch of check_end is

begin
    process(i_k, index)
    --Combinatorio
    begin
        if i_k = index then
            end_signal <= '1';
        else
            end_signal <= '0';
        end if;
        
    end process;

end check_end_arch;

--------------------------------------------------- COUNTER ---------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity counter is
    Port ( i_clk : in STD_LOGIC;
           i_rst : in STD_LOGIC;
           inc : in STD_LOGIC;
           index : out STD_LOGIC_VECTOR (9 downto 0));
end counter;

architecture counter_arch of counter is
    signal counter : STD_LOGIC_VECTOR (9 downto 0);

begin
    process(i_clk, i_rst)
    --Sequenziale
    begin
        if i_rst = '1' then
            counter <= "0000000000";
        else
            if i_clk'event and i_clk = '1' then
                if inc = '1' then
                    counter <= STD_LOGIC_VECTOR(unsigned(counter) + 1);
                else
                    counter <= counter;
                
                end if;
                
            end if;
        
        end if;
        
        index <= counter;
  
    end process;

end counter_arch;

--------------------------------------------------- CREDIBILITY ---------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity credibility is
    Port ( i_clk : in STD_LOGIC;
           i_rst : in STD_LOGIC;
           next_data : in STD_LOGIC;
           cred : in STD_LOGIC_VECTOR (4 downto 0);
           prec_cred : out STD_LOGIC_VECTOR (4 downto 0));
end credibility;

architecture credibility_arch of credibility is
    signal value : STD_LOGIC_VECTOR (4 downto 0);

begin
    process(i_clk, i_rst)
    --Sequenziale
    begin
        if i_rst = '1' then
            value <= "00000";
        else
            if i_clk'event and i_clk = '1' then
                if next_data = '1' then
                    value <= cred;
                else
                    value <= value;
                end if;
            
            end if;
            
        end if;
        
        prec_cred <= value;
        
    end process;

end credibility_arch;

--------------------------------------------------- FSM ---------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity fsm is
    Port ( i_start : in STD_LOGIC;
           i_clk : in STD_LOGIC;
           i_rst : in STD_LOGIC;
           end_signal : in STD_LOGIC;
           valid : in STD_LOGIC;
           inc : out STD_LOGIC;
           sel : out STD_LOGIC;
           o_mem_we : out STD_LOGIC;
           o_mem_en : out STD_LOGIC;
           o_done : out STD_LOGIC);
end fsm;

architecture fsm_arch of fsm is
    type state_type is (S0_init, S1_read_data, S2_write_cred, S3_write_data, S4_end);
    signal current_state, next_state : state_type;

begin

    process(i_clk, i_rst)
    --Sequenziale (cambio stato e reset)
    begin
        if i_rst = '1' then
            current_state <= S0_init;
        
        else
            if i_clk'event and i_clk = '1' then
                current_state <= next_state;
            end if;
        end if;
           
    end process;
        
    process(current_state, i_start, end_signal, valid)
    --Combinatorio  (next_state, uscite)
    begin
        case current_state is
           
            when S0_init =>
            --Next State
                if i_start = '1' then
                    next_state <= S1_read_data;
                else
                    next_state <= S0_init;
                end if;
            
            --Uscite
                sel <= '0';
                inc <= '0';
                o_mem_we <= '0';
                o_mem_en <= '0';
                o_done <= '0';
        
            when S1_read_data =>
            --Next State
                if end_signal = '1' then
                    next_state <= S4_end;
                else
                    next_state <= S2_write_cred;
                end if;
            
            --Uscite
                sel <= '0';
                inc <= '0';
                o_mem_we <= '0';
                o_mem_en <= not end_signal;
                o_done <= '0';
                
            when S2_write_cred =>
            --Next State
                if valid = '1' then
                    next_state <= S1_read_data;
                else
                    next_state <= S3_write_data;
                end if;
              
            --Uscite
                sel <= '1';
                inc <= valid;
                o_mem_we <= '1';
                o_mem_en <= '1';
                o_done <= '0';
            
            when S3_write_data =>
            --Next State
                next_state <= S1_read_data;
            --Uscite
                sel <= '0';
                inc <= '1';
                o_mem_we <= '1';
                o_mem_en <= '1';
                o_done <= '0';
            
            when S4_end =>
            --Next State
                if i_start = '0' then
                    next_state <= S0_init;
                else
                    next_state <= S4_end;
                end if;
            --Uscite
                sel <= '0';
                inc <= '0';
                o_mem_we <= '0';
                o_mem_en <= '0';
                o_done <= '1';
                
            when others =>
            --Next State
                next_state <= S0_init; --Error
            -- Error
                sel <= '0';
                inc <= '0';
                o_mem_we <= '0';
                o_mem_en <= '0';
                o_done <= '0';
            
        end case;
            
    end process;

end fsm_arch;

--------------------------------------------------- LAST_VALID_DATA ---------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity last_valid_data is
    Port ( i_clk : in STD_LOGIC;
           i_rst : in STD_LOGIC;
           i_mem_data : in STD_LOGIC_VECTOR (7 downto 0);
           next_data : in STD_LOGIC;
           data : out STD_LOGIC_VECTOR (7 downto 0));
end last_valid_data;

architecture last_valid_data_arch of last_valid_data is
    signal value : STD_LOGIC_VECTOR (7 downto 0);

begin
    process(i_clk, i_rst)
    --Sequenziale
    begin
        if i_rst = '1' then
            value <= "00000000";
        else
            if i_clk'event and i_clk = '1' then
                if next_data = '1' then
                    if i_mem_data = "00000000" then
                        value <= value;
                    else
                        value <= i_mem_data;
                    end if;
                    
                else
                    value <= value;
                end if;
                
            end if;
        
        end if;
        
        data <= value;

    end process;

end last_valid_data_arch;

--------------------------------------------------- MUX_ADDR ---------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux_addr is
    Port ( addr_data : in STD_LOGIC_VECTOR (15 downto 0);
           addr_cred : in STD_LOGIC_VECTOR (15 downto 0);
           sel : in STD_LOGIC;
           o_mem_addr : out STD_LOGIC_VECTOR (15 downto 0));
end mux_addr;

architecture mux_addr_arch of mux_addr is

begin
    process(addr_data, addr_cred, sel)
    --Combinatorio
    begin
        if sel = '1' then
            o_mem_addr <= addr_cred;
        else
            o_mem_addr <= addr_data;
        end if;
        
    end process;

end mux_addr_arch;

--------------------------------------------------- MUX_DATA ---------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux_data is
    Port ( data : in STD_LOGIC_VECTOR (7 downto 0);
           cred : in STD_LOGIC_VECTOR (4 downto 0);
           sel : in STD_LOGIC;
           o_mem_data : out STD_LOGIC_VECTOR (7 downto 0));
end mux_data;

architecture mux_data_arch of mux_data is

begin
    process(data, cred, sel)
    --Combinatorio
    begin
        if sel = '1' then
            o_mem_data <= "000" & cred;
        else
            o_mem_data <= data;
        end if;
        
    end process;

end mux_data_arch;

--------------------------------------------------- VALIDATION ---------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity validation is
    Port ( i_mem_data : in STD_LOGIC_VECTOR (7 downto 0);
           valid : out STD_LOGIC);
end validation;

architecture validation_arch of validation is

begin
    process(i_mem_data)
    --Combiantorio
    begin
        if i_mem_data = "00000000" then
            valid <= '0';
        else
            valid <= '1';
        end if;
        
    end process;

end validation_arch;


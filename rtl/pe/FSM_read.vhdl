library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FSM_read is
        port ( 
                clk_i           : in std_logic;
                rst_i           : in std_logic;

                start           : in std_logic;
                column_done     : in std_logic;
                row_done        : in std_logic;
                stop_cond       : in std_logic;

                cb_re           : out std_logic;
                off_re          : out std_logic;
                nb_we           : out std_logic;
                col_counter     : out std_logic;
                row_counter     : out std_logic
        );
end FSM_read;

architecture Behavioral of FSM_read is
        type states_loop is (s0_idle, s1_read, s2_flush, s3_convergence, s4_done);
        signal state_next, state_reg : states_loop;
begin
        
        CLK_PROCESS: process(clk_i, rst_i)
        begin
                if (rst_i = '1') then
                        state_reg <= s0_idle;
                elsif (clk_i'event and clk_i='1') then
                        state_reg <= state_next;
                end if;
        end process;

        STATE_NEXT_LOGIC: process(state_reg, start ,column_done, row_done, stop_cond)
        begin
                state_next <= state_reg; 

                case state_reg is
                        when s0_idle            => 
                                state_next <= s1_read when start = '1' else
                                              s0_idle;
                        when s1_read            => 
                                state_next <= s2_flush when column_done = '1' else
                                              s1_read;
                        when s2_flush           => 
                                state_next <= s3_convergence when row_done = '1' else
                                              s1_read;
                        when s3_convergence     => 
                                state_next <= s4_done when stop_cond = '1' else
                                              s1_read;
                        when s4_done            => 
                                state_next <= s4_done;
                end case;
        end process;

        STIMULUS: process(state_reg)
        begin
                cb_re  <= '0'; 
                off_re <= '0'; 
                nb_we  <= '0'; 

                col_counter <= '0';

                case state_reg is
                        when s0_idle            => 
                        when s1_read            => 
                                cb_re   <= '1';
                                off_re  <= '1';
                                nb_we   <= '1';

                                col_counter <= '1';
                        when s2_flush           => 
                                nb_we       <= '1';
                                row_counter <= '1';
                        when s3_convergence     => 

                        when s4_done            => 
                end case;
        end process;

end Behavioral;

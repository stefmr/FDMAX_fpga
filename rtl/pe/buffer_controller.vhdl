library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use work.types.all;

entity buffer_controller is
        port ( 
                clk_i           : in std_logic;
                rst_i           : in std_logic;
        
                start           : in std_logic;
                stop_cond       : in std_logic;
                
                current_read    : out std_logic;
                offset_read     : out std_logic;
                newbuf_read     : out std_logic;

                -- Me falta definir una FSM mas
                current_write   : out std_logic;
                offset_write    : out std_logic;
                newbuf_write    : out std_logic
        );
end buffer_controller;

architecture rtl of buffer_controller is
        
        signal col_count : std_logic;
        signal row_count : std_logic;

        signal col_done  : std_logic;
        signal row_done  : std_logic;
begin
        
        ROW_COUNTER : entity work.counter
        generic map(N => 100)
        port map(
                clk_i           => clk_i,
                rst_i           => rst_i,
                
                in_count        => row_count,
                out_count       => open,
                out_top_v       => row_done 
        );

        COL_COUNTER : entity work.counter
        generic map(N => 100)
        port map(
                clk_i           => clk_i,
                rst_i           => rst_i,
                
                in_count        => col_count,
                out_count       => open,
                out_top_v       => col_done
        );

        FSM_READ : entity work.FSM_read
        port map(
                clk_i           => clk_i,
                rst_i           => rst_i,

                start           => start,
                column_done     => col_done,
                row_done        => row_done,
                stop_cond       => stop_cond,

                cb_re           => current_read,
                off_re          => offset_read,
                nb_we           => newbuf_write,
                col_counter     => col_count,
                row_counter     => row_count 
        );
        
end rtl;

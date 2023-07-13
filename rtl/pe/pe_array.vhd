library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use work.types.all;

entity pe_array is
        generic(
                N_PE            : natural := 10;
                PRECISION       : natural := 32
        );
        port ( 
                clk_i           : in std_logic;
                rst_i           : in std_logic;
                cb_in           : in array_t(N_PE -1 downto 0);
                off_in          : in array_t(N_PE -1 downto 0);

                complete_adds   : out array_t(N_PE - 2 downto 0);
                p_v             : out std_logic_vector(PRECISION - 1 downto 0);
                n_v             : out std_logic_vector(PRECISION - 1 downto 0)
        );
end pe_array;

architecture Behavioral of pe_array is

        signal backward_points      : array_t(N_PE - 1 downto 0);
        signal forward_points   : array_t(N_PE - 1 downto 0);

begin

        U_PE: for i in 1 to N_PE - 2 generate 

        pe_inst : entity work.pe
                generic map(PRECISION => PRECISION)
                port map(
                        clk_i           => clk_i, 
                        rst_i           => rst_i, 

                        cb_in           => cb_in(i),
                        off_in          => off_in(i),
                        r_prev          => forward_points(i - 1),
                        r_next          => backward_points(i + 1),
                        nfifo_partial   => (others => '0'),

                        case_m1         => '0',
                        case_m2         => '0',
                        case_m3         => '0',
                        case_m4         => '1',

                        case_d1         => '0',
                        case_d2         => '0',
                        case_d3         => '0',

                        final_res       => complete_adds(i),
                        incomplete_pfifo=> open,
                        partial_next_PE => forward_points(i),
                        partial_nfifo   => open,
                        partial_prev_PE => backward_points(i),
                        partial_haloadd => open,

                        -- Me queda duda de que hacer con esta senial...
                        accum_diff      => open
                );
        end generate;

        first_pe : entity work.pe
                generic map(PRECISION => PRECISION)
                port map(
                        clk_i           => clk_i, 
                        rst_i           => rst_i, 

                        cb_in           => cb_in(0),
                        off_in          => off_in(0),
                        r_prev          => (others => '0'),
                        r_next          => backward_points(1),
                        nfifo_partial   => (others => '0'),


                        case_m1         => '0',
                        case_m2         => '0',
                        case_m3         => '0',
                        case_m4         => '1',

                        case_d1         => '0',
                        case_d2         => '0',
                        case_d3         => '1',

                        final_res       => complete_adds(0),
                        incomplete_pfifo=> open,
                        partial_next_PE => forward_points(0),
                        partial_nfifo   => open,
                        partial_prev_PE => open,
                        partial_haloadd => open,

                        -- Me queda duda de que hacer con esta senial...
                        accum_diff      => open
                );

        last_pe : entity work.pe
                generic map(PRECISION => PRECISION)
                port map(
                        clk_i           => clk_i, 
                        rst_i           => rst_i, 

                        cb_in           => cb_in(N_PE - 1),
                        off_in          => off_in(N_PE - 1),
                        r_prev          => forward_points(N_PE - 1),
                        r_next          => (others => '0'),
                        nfifo_partial   => (others => '0'),

                        case_m1         => '0',
                        case_m2         => '0',
                        case_m3         => '1',
                        case_m4         => '0',

                        case_d1         => '1',
                        case_d2         => '1',
                        case_d3         => '0',


                        final_res       => open,
                        incomplete_pfifo=> p_v,
                        partial_next_PE => open,
                        partial_nfifo   => n_v,
                        partial_prev_PE => backward_points(N_PE - 1),
                        partial_haloadd => open,

                        -- Me queda duda de que hacer con esta senial...
                        accum_diff      => open
                );
end Behavioral;

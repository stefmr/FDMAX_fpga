library ieee;
library xpm;

use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity pe is
    generic(PRECISION : natural := 32);
    port(
        clk_i, rst_i    : in std_logic;

        cur_buffer_in   : in std_logic_vector(PRECISION - 1 downto 0);     
        off_buffer_in   : in std_logic_vector(PRECISION - 1 downto 0);     
        r_prev          : in std_logic_vector(PRECISION - 1 downto 0);
        r_next          : in std_logic_vector(PRECISION - 1 downto 0);
        nfifo_partial   : in std_logic_vector(PRECISION - 1 downto 0);

        final_res       : out std_logic_vector(PRECISION - 1 downto 0);     
        incomplete_pfifo: out std_logic_vector(PRECISION - 1 downto 0);     
        partial_next_PE : out std_logic_vector(PRECISION - 1 downto 0);
        partial_nfifo   : out std_logic_vector(PRECISION - 1 downto 0);
        partial_prev_PE : out std_logic_vector(PRECISION - 1 downto 0);
        partial_haloadd : out std_logic_vector(PRECISION - 1 downto 0);
        accum_diff      : out std_logic_vector(PRECISION - 1 downto 0)
    );
end pe;

architecture Behaviour of pe is
    signal rd_d         : std_logic_vector(PRECISION - 1 downto 0);
    signal rdd_d        : std_logic_vector(PRECISION - 1 downto 0);
    signal r_prev_next_d: std_logic_vector(PRECISION - 1 downto 0);
    signal r_cell_out_d : std_logic_vector(PRECISION - 1 downto 0);

    signal s11          : std_logic_vector(PRECISION - 1 downto 0);
    signal s12          : std_logic_vector(PRECISION - 1 downto 0);
    signal s21          : std_logic_vector(PRECISION - 1 downto 0);
    signal s22          : std_logic_vector(PRECISION - 1 downto 0);
    signal s31          : std_logic_vector(PRECISION - 1 downto 0);
    signal s32          : std_logic_vector(PRECISION - 1 downto 0);
    signal s41          : std_logic_vector(PRECISION - 1 downto 0);
    signal s42          : std_logic_vector(PRECISION - 1 downto 0);

    signal m11          : std_logic_vector(PRECISION - 1 downto 0);
    signal m12          : std_logic_vector(PRECISION - 1 downto 0);
    signal m21          : std_logic_vector(PRECISION - 1 downto 0);
    signal m22          : std_logic_vector(PRECISION - 1 downto 0);
    signal m31          : std_logic_vector(PRECISION - 1 downto 0);
    signal m32          : std_logic_vector(PRECISION - 1 downto 0);

    signal w_h          : std_logic_vector(PRECISION - 1 downto 0);
    signal w_s          : std_logic_vector(PRECISION - 1 downto 0);
    signal w_v          : std_logic_vector(PRECISION - 1 downto 0);
begin

    -------- DELAYS --------
    
    R_Z : entity work.delay_1
    generic map(
        WORD_WIDTH => 32
    )
    port map(
        clk         => clk_i,
        rst         => rst_i,

        s           => cur_buffer_in,
        s_delayed   => rd_d 
    );

    R_DELAY_2 : entity work.delay_1
    generic map(
        WORD_WIDTH => 32
    )
    port map(
        clk         => clk_i,
        rst         => rst_i,

        s           => rd_d,
        s_delayed   => rdd_d
    );

    R_OUT : entity work.delay_1
    generic map(
        WORD_WIDTH => 32
    )
    port map(
        clk         => clk_i,
        rst         => rst_i,

        s           => r_sum_vals,
        s_delayed   => r_sum_vals_d
    );

    R_PREV_NEXT : entity work.delay_1
    generic map(
        WORD_WIDTH => 32
    )
    port map(
        clk         => clk_i,
        rst         => rst_i,

        s           => r_pn_i,
        s_delayed   => r_pn_o 
    );
    
    R_CURRENT : entity work.delay_1
    generic map(
        WORD_WIDTH => 32
    )
    port map(
        clk         => clk_i,
        rst         => rst_i,

        s           => r_current_i,
        s_delayed   => r_current_d
    );

    R_DIFF : entity work.delay_1
    generic map(
        WORD_WIDTH => 32
    )
    port map(
        clk         => clk_i,
        rst         => rst_i,

        s           => r_diff_i,
        s_delayed   => r_diff_o
    );

    -------- MUXES --------

    process(case_m1)
    begin
        case case_m1 is
            when '0'    => ;
            when others => ;
        end case;
    end process;

    process(case_m2)
    begin
        case case_m2 is
            when '0'    => ;
            when others => ;
        end case;
    end process;

    process(case_m3)
    begin
        case case_m3 is
            when '0'    => ;
            when others => ;
        end case;
    end process;

    process(case_m4)
    begin
        case case_m4 is
            when '0'    => ;
            when others => ;
        end case;
    end process;

    -------- DEMUXES --------

    process(case_d1)
    begin
        case case_d1 is
            when '0'    => ;
            when others => ;
        end case;
    end process;

    process(case_d2)
    begin
        case case_d2 is
            when '0'    => ;
            when others => ;
        end case;
    end process;

    process(case_d3)
    begin
        case case_d3 is
            when '0'    => ;
            when others => ;
        end case;
    end process;
    
    -------- ADDERS --------

    ADD_01 : entity work.FPadd
    port map( 
        ADD_SUB => '0', 
        FP_A    => , 
        FP_B    => , 
        clk     => clk_i, 
        FP_Z    => 
    );

    ADD_02 : entity work.FPadd
    port map( 
        ADD_SUB => '0', 
        FP_A    => , 
        FP_B    => , 
        clk     => clk_i, 
        FP_Z    => 
    );

    ADD_03 : entity work.FPadd
    port map( 
        ADD_SUB => '0', 
        FP_A    => , 
        FP_B    => , 
        clk     => clk_i, 
        FP_Z    => 
    );

    ADD_04 : entity work.FPadd
    port map( 
        ADD_SUB => '0', 
        FP_A    => , 
        FP_B    => , 
        clk     => clk_i, 
        FP_Z    => 
    );

    ADD_05 : entity work.FPadd
    port map( 
        ADD_SUB => '0', 
        FP_A    => , 
        FP_B    => , 
        clk     => clk_i, 
        FP_Z    => 
    );

    ADD_06 : entity work.FPadd
    port map( 
        ADD_SUB => '0', 
        FP_A    => , 
        FP_B    => , 
        clk     => clk_i, 
        FP_Z    => 
    );

    -------- MULTIPLIERS --------

    MUL_01  : entity work.FPmul
    port map( 
       FP_A     => , 
       FP_B     => w_h, 
       clk      => clk_i, 
       FP_Z     => 
    );

    MUL_02  : entity work.FPmul
    port map( 
       FP_A     => w_s, 
       FP_B     => , 
       clk      => clk_i, 
       FP_Z     => 
    );

    MUL_03  : entity work.FPmul
    port map( 
       FP_A     => , 
       FP_B     => w_v, 
       clk      => clk_i, 
       FP_Z     => r_pn_i 
    );

end Behaviour;

library ieee;
library xpm;

use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity pe is
    generic(PRECISION : natural := 32);
    port(
        clk_i, rst_i    : in std_logic;

        cb_in   : in std_logic_vector(PRECISION - 1 downto 0);     
        off_in   : in std_logic_vector(PRECISION - 1 downto 0);     
        r_prev          : in std_logic_vector(PRECISION - 1 downto 0);
        r_next          : in std_logic_vector(PRECISION - 1 downto 0);
        nfifo_partial   : in std_logic_vector(PRECISION - 1 downto 0);



        case_m1      : in std_logic;
        case_m2      : in std_logic;
        case_m3      : in std_logic;
        case_m4      : in std_logic;

        case_d1      : in std_logic;
        case_d2      : in std_logic;
        case_d3      : in std_logic;





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
    signal r_sum_vals   : std_logic_vector(PRECISION - 1 downto 0);
    signal r_sum_vals_d : std_logic_vector(PRECISION - 1 downto 0);
    signal r_pn_i       : std_logic_vector(PRECISION - 1 downto 0);
    signal r_pn_o       : std_logic_vector(PRECISION - 1 downto 0);
    signal r_current_i  : std_logic_vector(PRECISION - 1 downto 0);
    signal r_current_o  : std_logic_vector(PRECISION - 1 downto 0);
    signal r_current_d  : std_logic_vector(PRECISION - 1 downto 0);
    signal r_diff_i     : std_logic_vector(PRECISION - 1 downto 0);
    signal r_diff_o     : std_logic_vector(PRECISION - 1 downto 0);

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
    signal s51          : std_logic_vector(PRECISION - 1 downto 0);
    signal s52          : std_logic_vector(PRECISION - 1 downto 0);
    signal s61          : std_logic_vector(PRECISION - 1 downto 0);
    signal s62          : std_logic_vector(PRECISION - 1 downto 0);

    signal m11          : std_logic_vector(PRECISION - 1 downto 0);
    signal m12          : std_logic_vector(PRECISION - 1 downto 0);
    signal m21          : std_logic_vector(PRECISION - 1 downto 0);
    signal m22          : std_logic_vector(PRECISION - 1 downto 0);
    signal m31          : std_logic_vector(PRECISION - 1 downto 0);
    signal m32          : std_logic_vector(PRECISION - 1 downto 0);

    signal w_h          : std_logic_vector(PRECISION - 1 downto 0) := (others => '0');
    signal w_s          : std_logic_vector(PRECISION - 1 downto 0) := (others => '0');
    signal w_v          : std_logic_vector(PRECISION - 1 downto 0) := (others => '0');

begin

    -------- DELAYS --------
    
    R_Z : entity work.delay_1
    generic map(
        WORD_WIDTH => PRECISION
    )
    port map(
        clk         => clk_i,
        rst         => rst_i,

        s           => cb_in,
        s_delayed   => rd_d 
    );

    R_DELAY_2 : entity work.delay_1
    generic map(
        WORD_WIDTH => PRECISION
    )
    port map(
        clk         => clk_i,
        rst         => rst_i,

        s           => rd_d,
        s_delayed   => rdd_d
    );

    R_OUT : entity work.delay_1
    generic map(
        WORD_WIDTH => PRECISION
    )
    port map(
        clk         => clk_i,
        rst         => rst_i,

        s           => r_sum_vals,
        s_delayed   => r_sum_vals_d
    );

    R_PREV_NEXT : entity work.delay_1
    generic map(
        WORD_WIDTH => PRECISION
    )
    port map(
        clk         => clk_i,
        rst         => rst_i,

        s           => r_pn_i,
        s_delayed   => r_pn_o 
    );
    
    R_CURRENT : entity work.delay_1
    generic map(
        WORD_WIDTH => PRECISION
    )
    port map(
        clk         => clk_i,
        rst         => rst_i,

        s           => r_current_i,
        s_delayed   => s31
    );

    R_DIFF : entity work.delay_1
    generic map(
        WORD_WIDTH => PRECISION
    )
    port map(
        clk         => clk_i,
        rst         => rst_i,

        s           => r_diff_i,
        s_delayed   => r_diff_o
    );

    -------- MUXES --------

    process(case_m1, rdd_d, r_sum_vals_d)
    begin
        case case_m1 is
            when '0'    => s12 <= rdd_d;
            when others => s12 <= r_sum_vals_d;
        end case;
    end process;

    process(case_m2, off_in)
    begin
        case case_m2 is
            when '0'    => s32 <= (others => '0');
            when others => s32 <= off_in;
        end case;
    end process;

    process(case_m3, r_next)
    begin
        case case_m3 is
            when '0'    => s41 <= r_next;
            when others => s41 <= (others => '0');
        end case;
    end process;

    process(case_m4, r_prev, nfifo_partial)
    begin
        case case_m4 is
            when '0'    => s42 <= r_prev;
            when others => s42 <= nfifo_partial;
        end case;
    end process;

    -------- DEMUXES --------

    process(case_d1, r_sum_vals_d)
    begin
        case case_d1 is
            when '0'    => 
                    final_res        <= r_sum_vals_d;
                    incomplete_pfifo <= (others => '0');
            when others => 
                    incomplete_pfifo <= r_sum_vals_d;
                    final_res        <= (others => '0');
        end case;
    end process;

    process(case_d2, r_pn_o)
    begin
        case case_d2 is
            when '0'    => 
                    partial_next_PE  <= r_pn_o;
                    partial_nfifo <= (others => '0');
            when others => 
                    partial_nfifo    <= r_pn_o;
                    partial_next_PE  <= (others => '0');
        end case;
    end process;

    process(case_d3, r_pn_o)
    begin
        case case_d3 is
            when '0'    => 
                    partial_prev_PE  <= r_pn_o;
                    partial_haloadd  <= (others => '0');
            when others => 
                    partial_haloadd  <= r_pn_o;
                    partial_prev_PE <= (others => '0');
        end case;
    end process;

    -------- ADDERS --------

    ADD_01 : entity work.FPadd
    port map( 
        ADD_SUB => '0', 
        FP_A    => s11, 
        FP_B    => s12, 
        clk     => clk_i, 
        FP_Z    => m11 
    );

    ADD_02 : entity work.FPadd
    port map( 
        ADD_SUB => '0', 
        FP_A    => s21, 
        FP_B    => s22, 
        clk     => clk_i, 
        FP_Z    => r_current_i
    );

    ADD_03 : entity work.FPadd
    port map( 
        ADD_SUB => '0', 
        FP_A    => s31, 
        FP_B    => s32, 
        clk     => clk_i, 
        FP_Z    => s51
    );

    ADD_04 : entity work.FPadd
    port map( 
        ADD_SUB => '0', 
        FP_A    => s41, 
        FP_B    => s42, 
        clk     => clk_i, 
        FP_Z    => s52
    );

    ADD_05 : entity work.FPadd
    port map( 
        ADD_SUB => '0', 
        FP_A    => s51, 
        FP_B    => s52, 
        clk     => clk_i, 
        FP_Z    => r_sum_vals
    );

    ADD_06 : entity work.FPadd
    port map( 
        ADD_SUB => '0', 
        FP_A    => r_diff_o, 
        FP_B    => s62, 
        clk     => clk_i, 
        FP_Z    => r_diff_i
    );

    DIFF : entity work.FPadd
    port map( 
        ADD_SUB => '1', 
        FP_A    => rdd_d, 
        FP_B    => r_sum_vals_d, 
        clk     => clk_i, 
        FP_Z    => s62
    );


    -------- MULTIPLIERS --------

    MUL_01  : entity work.FPmul
    port map( 
       FP_A     => m11, 
       FP_B     => w_h, 
       clk      => clk_i, 
       FP_Z     => s21 
    );

    MUL_02  : entity work.FPmul
    port map( 
       FP_A     => w_s, 
       FP_B     => m22, 
       clk      => clk_i, 
       FP_Z     => s22
    );

    MUL_03  : entity work.FPmul
    port map( 
       FP_A     => m31, 
       FP_B     => w_v, 
       clk      => clk_i, 
       FP_Z     => r_pn_i 
    );

    s11 <= cb_in;
    m22 <= rd_d;
    m31 <= rd_d;
    accum_diff       <= r_diff_o;

end Behaviour;

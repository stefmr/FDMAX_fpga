library ieee;
use ieee.std_logic_1164.all;

use work.types.all;

entity top_module is
        generic(FLOAT_SIZE : natural := 32);
        port(
                sysclk : in std_logic;
                rst_i : in std_logic;

                data_valid    : in std_logic;

                data_stream_i : in std_logic_vector(3*FLOAT_SIZE - 1 downto 0);
                data_stream_o : out std_logic_vector(3*FLOAT_SIZE - 1 downto 0)
        );
end top_module;

architecture Behavioral of top_module is
        signal current_write : std_logic;
        signal offset_write  : std_logic;
        signal newbuf_write  : std_logic;

        signal current_read  : std_logic;
        signal offset_read  : std_logic;
        signal newbuf_read  : std_logic;

        signal pfifo_v : std_logic_vector(FLOAT_SIZE - 1 downto 0);
        signal nfifo_v : std_logic_vector(FLOAT_SIZE - 1 downto 0);

        -- No estoy teniendo en cuenta el valor del halo adder.
        signal completed_sums : array_t(1 downto 0);

        signal cb       : std_logic_vector(3*FLOAT_SIZE - 1 downto 0);
        signal off      : std_logic_vector(3*FLOAT_SIZE - 1 downto 0);

        signal cb_in          : array_t(2 downto 0);
        signal off_in         : array_t(2 downto 0);
        signal internal_clk     : std_logic;
        signal locked_tmp       : std_logic;
begin

        CLK : entity work.clk_wiz_0
        port map(
                clk_200mhz => internal_clk,
                reset => rst_i,
                sysclk => sysclk,
                locked => locked_tmp 
                );

        PE_ARRAY_INST : entity work.pe_array
        generic map(
                N_PE => 3,
                PRECISION => FLOAT_SIZE
        )
        port map(
                clk_i => internal_clk,
                rst_i => not locked_tmp or rst_i,
                cb_in => cb_in,
                off_in => off_in,
                complete_adds => completed_sums,
                p_v => pfifo_v,
                n_v => nfifo_v
        );

        N_FIFO : entity work.elastic_array_1x64
        generic map(
                N_ARRAYS => 1,
                FLOAT_SIZE => FLOAT_SIZE
        )
        port map(
                clk_i => internal_clk,
                rst_i => not locked_tmp or rst_i,
                data_i => nfifo_v,
                re => '0',
                we => '0',
                data_o => open
        );

        P_FIFO : entity work.elastic_array_1x64
        generic map(
                N_ARRAYS => 1,
                FLOAT_SIZE => 32
        )
        port map(
                clk_i => internal_clk,
                rst_i => not locked_tmp or rst_i,
                data_i => pfifo_v,
                -- Hardcodeadisimo
                re => newbuf_write,
                we => newbuf_write,
                data_o => open
        );

        B_CONTROLLER: entity work.buffer_controller
        port map(
                clk_i => internal_clk,
                rst_i => not locked_tmp or rst_i,

                start           => data_valid,
                stop_cond       => '0',

                current_read    => current_read,
                offset_read     => offset_read,
                newbuf_read     => newbuf_read,

                current_write   => current_write,
                offset_write    => offset_write,
                newbuf_write    => newbuf_write
        );

        CURRENT_BFIFO : entity work.generic_fifo
        generic map(FLOAT_SIZE => FLOAT_SIZE)
        port map(
                clk_i => internal_clk,
                rst_i => not locked_tmp or rst_i,

                data_i  => data_stream_i,
                re      => current_read,
                we      => current_write,
                data_o  => cb
        );

        OFFSET_BFIFO : entity work.generic_fifo
        generic map(FLOAT_SIZE => FLOAT_SIZE)
        port map(
                clk_i => internal_clk,
                rst_i => not locked_tmp or rst_i,

                data_i  => data_stream_i,
                re      => offset_read,
                we      => offset_write,
                data_o  => off
        );

        NEWBUF_BFIFO : entity work.generic_fifo
        generic map(FLOAT_SIZE => FLOAT_SIZE)
        port map(
                clk_i => internal_clk,
                rst_i => not locked_tmp or rst_i,

                data_i  => (FLOAT_SIZE - 1 downto 0 => (others => '0')) & completed_sums(1) & completed_sums(0),
                re      => newbuf_read,
                we      => newbuf_write,
                data_o  => data_stream_o
        );

        cb_in <= (cb(3*FLOAT_SIZE - 1 downto 2*FLOAT_SIZE), 
                  cb(2*FLOAT_SIZE - 1 downto FLOAT_SIZE),
                  cb(FLOAT_SIZE - 1 downto 0));

        off_in <=(off(3*FLOAT_SIZE - 1 downto 2*FLOAT_SIZE), 
                  off(2*FLOAT_SIZE - 1 downto FLOAT_SIZE),
                  off(FLOAT_SIZE - 1 downto 0));

end Behavioral;

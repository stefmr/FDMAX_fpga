library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library xpm;
use xpm.vcomponents.all;


-- Generates an elastic array of size 16 x N.

entity elastic_array is 
    generic(N_ARRAYS    : natural := 1,
            FLOAT_SIZE  : natural := 32)
    port(
        clk_i, rst_i    : in std_logic;
        data_i          : in std_logic_vector(FLOAT_SIZE - 1 downto 0);

        data_o          : out std_logic_vector(FLOAT_SIZE - 1 downto 0);
    );
end entity;

architecture rtl of elastic_array is

    U_FIFO_BANK: for i in 0 to K-1 generate

        xpm_fifo_sync_inst : xpm_fifo_sync
                generic map (
                    CASCADE_HEIGHT      => 0,        -- DECIMAL
                    DOUT_RESET_VALUE    => "0",      -- String
                    ECC_MODE            => "no_ecc", -- String
                    FIFO_MEMORY_TYPE    => "auto",   -- String
                    FIFO_READ_LATENCY   => 1,        -- DECIMAL
                    FIFO_WRITE_DEPTH    => 16,       -- DECIMAL
                    FULL_RESET_VALUE    => 0,        -- DECIMAL
                    PROG_EMPTY_THRESH   => 5,        -- DECIMAL
                    PROG_FULL_THRESH    => 11,       -- DECIMAL
                    RD_DATA_COUNT_WIDTH => 5,        -- DECIMAL
                    READ_DATA_WIDTH     => FLOAT_SIZE, -- DECIMAL
                    READ_MODE           => "fwft",   -- String
                    SIM_ASSERT_CHK      => 0,        -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
                    USE_ADV_FEATURES    => "0707",   -- String
                    WAKEUP_TIME         => 0,        -- DECIMAL
                    WRITE_DATA_WIDTH    => DWIDTH,   -- DECIMAL
                    WR_DATA_COUNT_WIDTH => 5         -- DECIMAL
                )
                port map (
                    almost_empty    => open,
                    almost_full     => open,
                    data_valid      => open,
                    dbiterr         => open,
                    dout            => dout_k(i),
                    empty           => empty_k(i),
                    full            => full_k(i),
                    overflow        => open,
                    prog_empty      => open,
                    prog_full       => open,
                    rd_data_count   => debug_counter_rd(i),
                    rd_rst_busy     => open,
                    sbiterr         => open,
                    underflow       => open,
                    wr_ack          => open,
                    wr_data_count   => debug_counter_wr(i),
                    wr_rst_busy     => open,
                    din             => din,
                    injectdbiterr   => '0',
                    injectsbiterr   => '0',
                    rd_en           => re_k(i),
                    rst             => rst,
                    sleep           => '0',
                    wr_clk          => clk,
                    wr_en           => we_k(i)
                );
            end generate;

end rtl;

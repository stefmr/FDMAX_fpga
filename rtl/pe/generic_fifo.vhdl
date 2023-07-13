library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library xpm;
use xpm.vcomponents.all;

entity generic_fifo is
    generic(FLOAT_SIZE  : natural := 32);
    port(
        clk_i, rst_i    : in std_logic;
        data_i          : in std_logic_vector(3*FLOAT_SIZE - 1 downto 0);
        re              : in std_logic;
        we              : in std_logic;

        data_o          : out std_logic_vector(3*FLOAT_SIZE - 1 downto 0)
    );
end generic_fifo;

architecture rtl of generic_fifo is

begin

    xpm_fifo_sync_inst : xpm_fifo_sync
                generic map (
                    CASCADE_HEIGHT      => 0,        -- DECIMAL
                    DOUT_RESET_VALUE    => "0",      -- String
                    ECC_MODE            => "no_ecc", -- String
                    FIFO_MEMORY_TYPE    => "auto",   -- String
                    FIFO_READ_LATENCY   => 1,        -- DECIMAL
                    FIFO_WRITE_DEPTH    => 128,      -- DECIMAL
                    FULL_RESET_VALUE    => 0,        -- DECIMAL
                    PROG_EMPTY_THRESH   => 5,        -- DECIMAL
                    PROG_FULL_THRESH    => 11,       -- DECIMAL
                    RD_DATA_COUNT_WIDTH => 5,        -- DECIMAL
                    READ_DATA_WIDTH     => 3*FLOAT_SIZE, -- DECIMAL
                    READ_MODE           => "fwft",   -- String
                    SIM_ASSERT_CHK      => 0,        -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
                    USE_ADV_FEATURES    => "0707",   -- String
                    WAKEUP_TIME         => 0,        -- DECIMAL
                    WRITE_DATA_WIDTH    => 3*FLOAT_SIZE,   -- DECIMAL
                    WR_DATA_COUNT_WIDTH => 5         -- DECIMAL
                )
                port map (
                    almost_empty    => open,
                    almost_full     => open,
                    data_valid      => open,
                    dbiterr         => open,
                    dout            => data_o,
                    empty           => open,
                    full            => open,
                    overflow        => open,
                    prog_empty      => open,
                    prog_full       => open,
                    rd_data_count   => open,
                    rd_rst_busy     => open,
                    sbiterr         => open,
                    underflow       => open,
                    wr_ack          => open,
                    wr_data_count   => open,
                    wr_rst_busy     => open,
                    din             => data_i,
                    injectdbiterr   => '0',
                    injectsbiterr   => '0',
                    rd_en           => re,
                    rst             => rst_i,
                    sleep           => '0',
                    wr_clk          => clk_i,
                    wr_en           => we
                );

end rtl;

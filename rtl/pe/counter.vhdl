library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use ieee.math_real.all;


entity counter is
        generic(N : natural := 5);
        port(
        clk_i, rst_i        : in std_logic;
        in_count        : in std_logic; -- Dejo la senial prendida hasta que termine

        out_count       : out std_logic_vector(integer(ceil(log2(real(N)))) - 1 downto 0);
        out_top_v       : out std_logic
        );
end counter;

architecture rtl of counter is
        signal counter : unsigned(integer(ceil(log2(real(N)))) - 1 downto 0);
        

begin
        process(clk_i, rst_i, counter)
        begin
                if(rst_i = '1') then
                        counter <= (others => '0');
                        out_top_v <= '0';
                elsif(clk_i'event and clk_i = '1' ) then 

                        if (in_count = '1') then
                                if (counter = N - 1) then
                                        counter <= counter + 1;
                                        out_top_v <= '1';
                                elsif (counter = N) then
                                        counter <= (others => '0');
                                        out_top_v <= '0';
                                else
                                        counter <= counter + 1;
                                        out_top_v <= '0';
                                end if;
                        else
                                counter <= counter;
                        end if;

                end if;
        end process;

        out_count <= std_logic_vector(counter);

end rtl;

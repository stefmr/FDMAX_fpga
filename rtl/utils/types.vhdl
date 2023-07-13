library ieee;
use ieee.std_logic_1164.all;

package types is
        type array_t is 
                array(natural range <>) of std_logic_vector(31 downto 0);
end types;

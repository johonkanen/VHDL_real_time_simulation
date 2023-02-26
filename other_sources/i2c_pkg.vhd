library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

package i2c_pkg is

    constant clock_divider_max : integer := integer(120.0e6/400.0e3)-1;
    -- protocol
    constant start            : std_logic_vector(0 downto 0) := "0"; --?
    constant i2c_address_0x20 : std_logic_vector(6 downto 0) := "0100000";
    constant i2c_address_0x21 : std_logic_vector(6 downto 0) := "0100001";
    constant i2c_address_0x22 : std_logic_vector(6 downto 0) := "0100010";
    constant i2c_address_0x23 : std_logic_vector(6 downto 0) := "0100011";
    constant read_with_0      : std_logic := '0';
    constant write_with_1     : std_logic := '1';
    constant acknowledge      : std_logic := '0';
    constant not_acknowledge  : std_logic := '1';

    subtype read_and_write_registers is integer range 0 to 80;
    subtype read_only_registers is integer range 96 to 127;

    procedure create_i2c (
        signal counter : inout integer;
        counter_max : integer;
        signal clock_out : out std_logic );

end package i2c_pkg;

package body i2c_pkg is
------------------------------------------------------------------------
        procedure create_i2c
        (
            signal counter : inout integer;
            counter_max : integer;
            signal clock_out : out std_logic 
        ) is
        begin
            if counter > 0 then
                counter <= counter - 1;
            else
                counter <= counter_max;
            end if;

            if counter > counter_max/2 then
                clock_out <= '1';
            else
                clock_out <= '0';
            end if;
            
        end create_i2c;
    --------------------------------------------------

end package body i2c_pkg;


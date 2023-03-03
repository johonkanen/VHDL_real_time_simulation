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
------------------------------------------------------------------------
    type i2c_record is record
        clock                   : std_logic                 ;
        data                    : std_logic                 ;
        clock_counter           : integer range 0 to 2**10-1;
        bit_counter             : integer range 0 to 31;
        transmit_shift_register : std_logic_vector(31 downto 0);
        receive_shift_register  : std_logic_vector(31 downto 0);
    end record;

    constant init_i2c : i2c_record := ('1', '1', clock_divider_max, 0, (others => '0'), (others => '0'));
------------------------------------------------------------------------
    procedure create_i2c (
        signal self : inout i2c_record;
        signal clock_out : out std_logic);

    procedure create_i2c (
        signal counter : inout integer;
        counter_max : integer;
        signal clock_out : out std_logic );
------------------------------------------------------------------------
end package i2c_pkg;

package body i2c_pkg is
------------------------------------------------------------------------
    procedure create_i2c
    (
        signal self : inout i2c_record;
        signal clock_out : out std_logic
    ) is
    impure function i2c_clock_falling_edge return boolean is
    begin
        return self.clock_counter = clock_divider_max/2;
        
    end i2c_clock_falling_edge;
    --------------------------------------------------
    begin
        create_i2c(self.clock_counter, clock_divider_max, clock_out);
        if i2c_clock_falling_edge and self.bit_counter > 0 then
            self.transmit_shift_register <= self.transmit_shift_register(30 downto 0) & '0';
            self.bit_counter <= self.bit_counter - 1;
        end if;
    end create_i2c;
------------------------------------------------------------------------
    procedure create_i2c
    (
        signal counter : inout integer;
        counter_max : integer;
        signal clock_out : out std_logic 
    ) is
    --------------------------------------------------
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
    procedure write_data_to_i2c_address
    (
        signal i2c_object : out i2c_record;
        address : in integer;
        data : in std_logic_vector(7 downto 0)
    ) is
    begin
        
    end write_data_to_i2c_address;
--------------------------------------------------
    procedure read_i2c_address
    (
        signal i2c_object : out i2c_record;
        address : in integer
    ) is
    begin
        
    end read_i2c_address;
--------------------------------------------------

end package body i2c_pkg;

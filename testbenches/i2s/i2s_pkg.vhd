library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

package i2s_pkg is
------------------------------------------------------------------------
    type i2s_record is record
        bclk           : std_logic             ;
        bclk_counter   : integer range 0 to 7  ;
        fsynch         : std_logic             ;
        fsynch_counter : integer range 0 to 63 ;
        data_shift_register : signed(31 downto 0);
        i2s_data1_is_ready : boolean;
        i2s_data2_is_ready : boolean;
    end record;

    constant init_i2s : i2s_record := ('0', 7, '1', 63, (others => '0'), false, false);

    constant fsync_bclk_division : integer := 64;
------------------------------------------------------------------------
    procedure create_i2s_driver ( signal self : inout i2s_record);

    procedure create_i2s_driver (
        signal self : inout i2s_record;
        adc_serial_input : std_logic);

    function measurement_is_ready ( i2s_object : i2s_record)
        return boolean;

    function channel1_is_ready ( i2s_object : i2s_record)
        return boolean;

    function channel2_is_ready ( i2s_object : i2s_record)
        return boolean;

    function get_measurement ( i2s_object : i2s_record)
        return signed;

end package i2s_pkg;

package body i2s_pkg is

    procedure increment_and_wrap
    (
        signal counter : inout integer;
        wrap_at : integer
    ) is
    begin
        if counter > 0 then
            counter <= counter - 1;
        else
            counter <= wrap_at-1;
        end if;
    end increment_and_wrap;

    procedure create_i2s_driver
    (
        signal self : inout i2s_record
    ) is
    begin
        increment_and_wrap(self.bclk_counter, 6);
        if self.bclk_counter < 3 then
            self.bclk <= '1';
        else
            self.bclk <= '0';
        end if;
        
        if self.bclk_counter = 2 then 
            if self.fsynch_counter > 0 then
                self.fsynch_counter <= self.fsynch_counter -1;
            else
                self.fsynch_counter <= fsync_bclk_division-1;
            end if;
            if self.fsynch_counter > (fsync_bclk_division-1)/2 then
                self.fsynch <= '1';
            else
                self.fsynch <= '0';
            end if;
        end if;
        
    end create_i2s_driver;

    procedure create_i2s_driver
    (
        signal self : inout i2s_record;
        adc_serial_input : std_logic 
    ) is
    begin
        create_i2s_driver(self);
        if self.bclk_counter = 2 then
            self.data_shift_register <= self.data_shift_register(30 downto 0) & adc_serial_input;
        end if;

        if (self.fsynch_counter = 31) and (self.bclk_counter = 2) then
            self.i2s_data1_is_ready <= true;
        else
            self.i2s_data1_is_ready <= false;
        end if;
        if (self.fsynch_counter = 63) and (self.bclk_counter = 2) then
            self.i2s_data2_is_ready <= true;
        else
            self.i2s_data2_is_ready <= false;
        end if;
    end create_i2s_driver;

    function measurement_is_ready
    (
        i2s_object : i2s_record
    )
    return boolean
    is
    begin
        return i2s_object.i2s_data1_is_ready or i2s_object.i2s_data2_is_ready;
    end measurement_is_ready;

    function channel1_is_ready
    (
        i2s_object : i2s_record
    )
    return boolean 
    is
    begin
        return i2s_object.i2s_data1_is_ready;
    end channel1_is_ready;

    function channel2_is_ready
    (
        i2s_object : i2s_record
    )
    return boolean 
    is
    begin
        return i2s_object.i2s_data2_is_ready;
    end channel2_is_ready;

    function get_measurement
    (
        i2s_object : i2s_record
    )
    return signed
    is
    begin
        return i2s_object.data_shift_register;
        
    end get_measurement;

end package body i2s_pkg;

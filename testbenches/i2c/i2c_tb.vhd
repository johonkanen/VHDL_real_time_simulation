LIBRARY ieee  ; 
    USE ieee.NUMERIC_STD.all  ; 
    USE ieee.std_logic_1164.all  ; 
    use ieee.math_real.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity i2c_tb is
  generic (runner_cfg : string);
end;

architecture vunit_simulation of i2c_tb is

    constant clock_period      : time    := 8.333 ns;
    constant simtime_in_clocks : integer := 5000;
    
    signal simulator_clock     : std_logic := '0';
    signal simulation_counter  : natural   := 0;
    -----------------------------------
    -- simulation specific signals ----
    signal i2c_clock : std_logic := '1';
    signal i2c_data : std_logic := '1';

    constant clock_divider_max : integer := integer(120.0e6/400.0e3)-1;
    signal i2c_clock_counter : integer range 0 to 2**10-1 := clock_divider_max;

    signal transmit_shift_register : std_logic_vector(15 downto 0) := (others => '1');
    signal receive_shift_register  : std_logic_vector(15 downto 0) := (others => '1');

    constant start : std_logic_vector(0 downto 0) := "0"; --?
    constant i2c_address_0x20 : std_logic_vector(6 downto 0) := "0100000";
    constant i2c_address_0x21 : std_logic_vector(6 downto 0) := "0100001";
    constant i2c_address_0x22 : std_logic_vector(6 downto 0) := "0100010";
    constant i2c_address_0x23 : std_logic_vector(6 downto 0) := "0100011";

    subtype read_and_write_registers is integer range 0 to 80;
    subtype read_only_registers is integer range 96 to 127;

    -- sampled on rising edge
    signal ma12070_receive_register : std_logic_vector(15 downto 0) := (others => '0');

begin

------------------------------------------------------------------------
    simtime : process
    begin
        test_runner_setup(runner, runner_cfg);
        wait for simtime_in_clocks*clock_period;
        test_runner_cleanup(runner); -- Simulation ends here
        wait;
    end process simtime;	

    simulator_clock <= not simulator_clock after clock_period/2.0;
------------------------------------------------------------------------

    stimulus : process(simulator_clock)
    begin
        if rising_edge(simulator_clock) then
            simulation_counter <= simulation_counter + 1;
            if i2c_clock_counter > 0 then
                i2c_clock_counter <= i2c_clock_counter - 1;
            else
                i2c_clock_counter <= clock_divider_max;
            end if;

            if i2c_clock_counter > clock_divider_max/2 then
                i2c_clock <= '1';
            else
                i2c_clock <= '0';
            end if;

            if i2c_clock_counter = clock_divider_max/2 then
                transmit_shift_register <= transmit_shift_register(transmit_shift_register'left -1 downto 0) & '0';
            end if;

        end if; -- rising_edge
    end process stimulus;	
    i2c_data <= transmit_shift_register(transmit_shift_register'left);
------------------------------------------------------------------------
    ma12070 : process(i2c_clock)
        
    begin
        if rising_edge(i2c_clock) then
            ma12070_receive_register <= ma12070_receive_register(ma12070_receive_register'left - 1 downto 0) & i2c_data;
        end if; --rising_edge
    end process ma12070;	
------------------------------------------------------------------------
end vunit_simulation;

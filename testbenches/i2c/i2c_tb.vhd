LIBRARY ieee  ; 
    USE ieee.NUMERIC_STD.all  ; 
    USE ieee.std_logic_1164.all  ; 
    use ieee.math_real.all;

library vunit_lib;
context vunit_lib.vunit_context;

    use work.i2c_pkg.all;

entity i2c_tb is
  generic (runner_cfg : string);
end;

architecture vunit_simulation of i2c_tb is

    constant clock_period      : time    := 8.333 ns;
    constant simtime_in_clocks : integer := 15000;
    
    signal simulator_clock     : std_logic := '0';
    signal simulation_counter  : natural   := 0;
    -----------------------------------
    -- simulation specific signals ----

    signal i2c : i2c_record := init_i2c;

    signal i2c_clock         : std_logic                  := '1';
    signal i2c_data          : std_logic                  := '1';
    signal i2c_clock_counter : integer range 0 to 2**10-1 := clock_divider_max;

    constant start_frame : std_logic := '0';
    constant stop_frame : std_logic := '1';

    constant data_address : std_logic_vector(7 downto 0) := "00000000";
    signal a_frame : std_logic_vector(27 downto 0) := start_frame & i2c_address_0x20 & write_with_1 & acknowledge & data_address & acknowledge & "00000000" & stop_frame;

    signal transmit_shift_register : std_logic_vector(15 downto 0) := a_frame(27 downto 27-15);
    signal receive_shift_register  : std_logic_vector(15 downto 0) := (others => '1');



    signal i2c_direction_is_write_when_1 : std_logic := '1';

    -- sampled on rising edge
    signal ma12070_receive_register : std_logic_vector(15 downto 0) := (others => '0');

    -- frame : start | address | read/write | ack | data | ack | stop
    --       |           preamble           | ack | data | ack | stop

    type list_of_i2c_states is (idle, transmit_preamble, preamble_ack, data, data_ack, stop);
    signal i2c_state : list_of_i2c_states := idle;

    signal transmit_bit_counter : integer range 0 to 31 := 0;

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
    ma12070 : process(i2c_clock)
        
    begin
        if rising_edge(i2c_clock) then
            if ma12070_receive_register /= a_frame(27 downto 27-15) then
                ma12070_receive_register <= ma12070_receive_register(ma12070_receive_register'left - 1 downto 0) & i2c_data;
            end if;
        end if; --rising_edge
    end process ma12070;	
------------------------------------------------------------------------

    i2c_data <= transmit_shift_register(transmit_shift_register'left);

    stimulus : process(simulator_clock)
    --------------------------------------------------
        impure function i2c_clock_falling_edge return boolean is
        begin
            return i2c_clock_counter = clock_divider_max/2;
            
        end i2c_clock_falling_edge;
    --------------------------------------------------
    begin
        if rising_edge(simulator_clock) then
            simulation_counter <= simulation_counter + 1;

            create_i2c(i2c_clock_counter, clock_divider_max, i2c_clock);

            if i2c_clock_falling_edge then
                transmit_shift_register <= transmit_shift_register(transmit_shift_register'left -1 downto 0) & '0';
            end if;

            if i2c_clock_falling_edge then
                transmit_bit_counter <= transmit_bit_counter + 1;
            end if;

        end if; -- rising_edge
    end process stimulus;	
------------------------------------------------------------------------
end vunit_simulation;

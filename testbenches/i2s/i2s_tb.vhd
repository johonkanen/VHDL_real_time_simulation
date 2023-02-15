LIBRARY ieee  ; 
    USE ieee.NUMERIC_STD.all  ; 
    USE ieee.std_logic_1164.all  ; 
    use ieee.math_real.all;

library vunit_lib;
context vunit_lib.vunit_context;

    use work.i2s_pkg.all;

entity i2s_tb is
  generic (runner_cfg : string);
end;

architecture vunit_simulation of i2s_tb is

    constant clock_period      : time    := 1 ns;
    constant simtime_in_clocks : integer := 1000;
    
    signal simulator_clock     : std_logic := '0';
    signal simulation_counter  : natural   := 0;
    -----------------------------------
    -- simulation specific signals ----


    signal i2s : i2s_record := init_i2s;
    alias self is i2s;

    signal bclk           : std_logic             ;
    signal bclk_counter   : integer range 0 to 7  ;
    signal fsynch         : std_logic             ;
    signal fsynch_counter : integer range 0 to 63 ;

    signal measurement : integer := 0;

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
            create_i2s_driver(i2s, fsynch);

            if measurement_is_ready(i2s) then
                measurement <= to_integer(get_measurement(i2s));
            end if;

        end if; -- rising_edge
    end process stimulus;	

    bclk           <= i2s.bclk          ;
    bclk_counter   <= i2s.bclk_counter  ;
    fsynch         <= i2s.fsynch        ;
    fsynch_counter <= i2s.fsynch_counter;
------------------------------------------------------------------------
end vunit_simulation;

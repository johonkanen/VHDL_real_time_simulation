LIBRARY ieee  ; 
    USE ieee.NUMERIC_STD.all  ; 
    USE ieee.std_logic_1164.all  ; 
    use ieee.math_real.all;

library vunit_lib;
context vunit_lib.vunit_context;

    use work.fpga_interconnect_pkg.all;

entity hil_simulation_tb is
  generic (runner_cfg : string);
end;

architecture vunit_simulation of hil_simulation_tb is

    constant clock_period      : time    := 1 ns;
    constant simtime_in_clocks : integer := 100000;
    
    signal simulator_clock     : std_logic := '0';
    signal simulation_counter  : natural   := 0;
    -----------------------------------
    -- simulation specific signals ----

    signal bus_from_stimulus : fpga_interconnect_record := init_fpga_interconnect;
    signal bus_from_hil : fpga_interconnect_record := init_fpga_interconnect;
    signal voltage : integer := 0;
    signal current : integer := 0;

    signal receive_counter : integer := 0;

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
            init_bus(bus_from_stimulus);

            CASE simulation_counter is
                -- WHEN 1000 => write_data_to_address(bus_from_stimulus, 1000, 12800);
                -- WHEN 25e3 => write_data_to_address(bus_from_stimulus, 1014, 0);
                -- WHEN 45e3 => write_data_to_address(bus_from_stimulus, 1001, 15000);
                -- WHEN 60e3 => write_data_to_address(bus_from_stimulus, 1001, 0);
                WHEN others => -- do nothing
            end CASE;

        end if; -- rising_edge
    end process stimulus;	

    u_hil : entity work.hil_simulation
    port map(simulator_clock, bus_from_stimulus, bus_from_hil);
------------------------------------------------------------------------
end vunit_simulation;

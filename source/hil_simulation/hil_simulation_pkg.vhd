library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    -- use work.hil_simulation_pkg.all;
    use work.fpga_interconnect_pkg.all;
    use work.multiplier_pkg.all;
    use work.lcr_filter_model_pkg.all;
    use work.real_to_fixed_pkg.all;

entity hil_simulation is
    port (
        clk : in std_logic	;
        bus_to_hil_simulator   : in fpga_interconnect_record;
        bus_from_hil_simulator : out fpga_interconnect_record
    );
end entity hil_simulation;


architecture rtl of hil_simulation is

    constant L1_inductance : real := 1.0e-3;
    constant L2_inductance : real := 10.0e-6;
    constant L3_inductance : real := 100.0e-6;
    constant L4_inductance : real := 10.0e-6;
    constant L5_inductance : real := 10.0e-6;

    constant C1_capacitance : real := 20.0e-6;
    constant C2_capacitance : real := 10.0e-6;
    constant C3_capacitance : real := 100.0e-6;
    constant C4_capacitance : real := 2.2e-6;
    constant C5_capacitance : real := 20.0e-6;

    constant simulation_time_step : real := 2.0e-6;
    constant stoptime             : real := 30.0e-3;
    signal simulation_time        : real := 0.0;

    constant int_radix            : integer := int_word_length-1;

    ----
    constant scale_value : real := 2.0**10;

    impure function to_fixed
    (
        input_number : real
    )
    return integer
    is
    begin
        return to_fixed(input_number/scale_value, int_radix);
    end to_fixed;
    ----
    signal input_lc1  : lcr_model_record := init_lcr_filter(L2_inductance , C2_capacitance , 10.0e-3  , simulation_time_step , int_radix);
    signal input_lc2  : lcr_model_record := init_lcr_filter(L3_inductance , C3_capacitance , 0.0      , simulation_time_step , int_radix);
    signal primary_lc : lcr_model_record := init_lcr_filter(L1_inductance , C1_capacitance , 300.0e-3 , simulation_time_step , int_radix);
    signal output_lc1 : lcr_model_record := init_lcr_filter(L4_inductance , C4_capacitance , 0.0      , simulation_time_step , int_radix);
    signal output_lc2 : lcr_model_record := init_lcr_filter(L5_inductance , C5_capacitance , 0.0      , simulation_time_step , int_radix);

    signal multiplier_1 : multiplier_record := init_multiplier;
    signal multiplier_2 : multiplier_record := init_multiplier;
    signal multiplier_3 : multiplier_record := init_multiplier;
    signal multiplier_4 : multiplier_record := init_multiplier;
    signal multiplier_5 : multiplier_record := init_multiplier;
    signal output_voltage   : real := 0.0;
    signal inductor_current : real := 0.0;

    signal input_voltage : integer := to_fixed(400.0);
    signal load_current : integer := to_fixed(0.0);

    signal simulation_counter : integer range 0 to 119 := 119;


begin

    hil_simulator : process(clk)
        
    begin
        if rising_edge(clk) then
            init_bus(bus_from_hil_simulator);
            connect_read_only_data_to_address(bus_to_hil_simulator, bus_from_hil_simulator, 1000, get_inductor_current(primary_lc));
            connect_read_only_data_to_address(bus_to_hil_simulator, bus_from_hil_simulator, 1001, get_capacitor_voltage(primary_lc));

            create_multiplier(multiplier_1);
            create_multiplier(multiplier_2);
            create_multiplier(multiplier_3);
            create_multiplier(multiplier_4);
            create_multiplier(multiplier_5);

            create_lcr_filter(input_lc1  , multiplier_1 , get_inductor_current(input_lc2)    , input_voltage                      , int_radix);
            create_lcr_filter(input_lc2  , multiplier_2 , get_inductor_current(primary_lc)/2 , get_capacitor_voltage(input_lc1)   , int_radix);
            create_lcr_filter(primary_lc , multiplier_3 , get_inductor_current(output_lc1)   , get_capacitor_voltage(input_lc2)/2 , int_radix);
            create_lcr_filter(output_lc1 , multiplier_4 , get_inductor_current(output_lc2)   , get_capacitor_voltage(primary_lc)  , int_radix);
            create_lcr_filter(output_lc2 , multiplier_5 , load_current                       , get_capacitor_voltage(output_lc1)  , int_radix);

            if simulation_counter > 0 then
                simulation_counter <= simulation_counter - 1;
            else
                -- simulation_counter <= 20;
            end if;

            if simulation_counter = 1 or lcr_filter_calculation_is_ready(primary_lc) then
                request_lcr_filter_calculation(input_lc1 );
                request_lcr_filter_calculation(input_lc2 );
                request_lcr_filter_calculation(primary_lc);
                request_lcr_filter_calculation(output_lc1);
                request_lcr_filter_calculation(output_lc2);
            end if;

        end if; --rising_edge
    end process hil_simulator;	
end rtl;

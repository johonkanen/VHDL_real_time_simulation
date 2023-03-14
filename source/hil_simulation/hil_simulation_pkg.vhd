library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    use work.fpga_interconnect_pkg.all;
    use work.lcr_filter_model_pkg.all;
    use work.filtered_buck_model_pkg.all;
    use work.real_to_fixed_pkg.to_fixed;
    use work.multiplier_pkg.all;
    use work.division_pkg.all;

entity hil_simulation is
    port (
        clk : in std_logic	;
        bus_to_hil_simulator   : in fpga_interconnect_record;
        bus_from_hil_simulator : out fpga_interconnect_record
    );
end entity hil_simulation;


architecture rtl of hil_simulation is

    signal filtered_buck : filtered_buck_record := init_filtered_buck;

    signal input_voltage : integer := 0;
    signal load_current : integer := 0;

    signal simulation_counter : integer range 0 to 2047 := 1199;
    signal duty_ratio : integer range -2**15 to 2**15-1 := to_fixed(0.5, 15);

    signal div_multiplier : multiplier_record := init_multiplier;
    signal divider : division_record := init_division;
    signal div_result : int := 0;

begin

    hil_simulator : process(clk)
        
    begin
        if rising_edge(clk) then
            init_bus(bus_from_hil_simulator);
            connect_data_to_address(bus_to_hil_simulator           , bus_from_hil_simulator , 1000 , input_voltage);
            connect_data_to_address(bus_to_hil_simulator           , bus_from_hil_simulator , 1001 , load_current);
            connect_read_only_data_to_address(bus_to_hil_simulator , bus_from_hil_simulator , 1002 , get_inductor_current(filtered_buck.input_lc1)  / 2**7+32768);
            connect_read_only_data_to_address(bus_to_hil_simulator , bus_from_hil_simulator , 1003 , get_capacitor_voltage(filtered_buck.input_lc1) / 2**10+32768);
            connect_read_only_data_to_address(bus_to_hil_simulator , bus_from_hil_simulator , 1004 , get_inductor_current(filtered_buck.input_lc2)  / 2**7+32768);
            connect_read_only_data_to_address(bus_to_hil_simulator , bus_from_hil_simulator , 1005 , get_capacitor_voltage(filtered_buck.input_lc2) / 2**10+32768);
            connect_read_only_data_to_address(bus_to_hil_simulator , bus_from_hil_simulator , 1006 , get_inductor_current(filtered_buck.primary_lc)  / 2**7+32768);
            connect_read_only_data_to_address(bus_to_hil_simulator , bus_from_hil_simulator , 1007 , get_capacitor_voltage(filtered_buck.primary_lc) / 2**10+32768);
            connect_read_only_data_to_address(bus_to_hil_simulator , bus_from_hil_simulator , 1008 , get_inductor_current(filtered_buck.output_lc1)  / 2**7+32768);
            connect_read_only_data_to_address(bus_to_hil_simulator , bus_from_hil_simulator , 1009 , get_capacitor_voltage(filtered_buck.output_lc1) / 2**10+32768);
            connect_read_only_data_to_address(bus_to_hil_simulator , bus_from_hil_simulator , 1010 , get_inductor_current(filtered_buck.output_lc2)  / 2**7+32768);
            connect_read_only_data_to_address(bus_to_hil_simulator , bus_from_hil_simulator , 1011 , get_capacitor_voltage(filtered_buck.output_lc2) / 2**10+32768);
            connect_data_to_address(bus_to_hil_simulator           , bus_from_hil_simulator , 1012 , duty_ratio);

            connect_read_only_data_to_address(bus_to_hil_simulator , bus_from_hil_simulator , 1013 , div_result);

            create_multiplier(div_multiplier);
            create_division(div_multiplier, divider);


            create_filtered_buck(filtered_buck, duty_ratio, input_voltage*2**10, load_current*2**7);

            if simulation_counter > 0 then
                simulation_counter <= simulation_counter - 1;
            else
                simulation_counter <= 1119;
            end if;

            if simulation_counter = 0 then
                request_filtered_buck_calculation(filtered_buck);
                request_division(divider, get_capacitor_voltage(filtered_buck.primary_lc),get_capacitor_voltage(filtered_buck.input_lc2));
            end if;
            if division_is_ready(div_multiplier, divider) then
                div_result <= get_division_result(div_multiplier , divider , int_word_length-1)/2**11;
            end if;

        end if; --rising_edge
    end process hil_simulator;	
end rtl;

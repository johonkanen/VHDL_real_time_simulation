library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    use work.fpga_interconnect_pkg.all;
    use work.lcr_filter_model_pkg.all;
    use work.filtered_buck_model_pkg.all;
    use work.real_to_fixed_pkg.to_fixed;
    use work.multiplier_pkg.all;
    use work.division_pkg.all;
    use work.hil_simulation_pkg.all;
    use work.pi_controller_pkg.all;

entity hil_simulation is
    port (
        clk : in std_logic	;
        bus_to_hil_simulator   : in fpga_interconnect_record;
        bus_from_hil_simulator : out fpga_interconnect_record
    );
end entity hil_simulation;


architecture rtl of hil_simulation is

    signal filtered_buck : filtered_buck_record := init_filtered_buck;

    signal input_voltage : integer := 12800;
    signal load_current : integer := 0;

    signal simulation_counter : integer range 0 to 2047 := calculation_delay;
    signal duty_ratio : integer range -2**15 to 2**15-1 := to_fixed(0.5, 15);

    signal div_multiplier : multiplier_record := init_multiplier;
    signal divider : division_record := init_division;
    signal div_result : int := 0;

    signal pi_multiplier : multiplier_record    := init_multiplier;
    signal pi_controller : pi_controller_record := pi_controller_init;
    signal vpi_multiplier : multiplier_record    := init_multiplier;
    signal vpi_controller : pi_controller_record := pi_controller_init;

    signal load_resistor : int := to_fixed(1.0/3.0, 20);
    signal voltage_reference : int := 5000;

begin

    hil_simulator : process(clk)
        function scale_voltage_to_16_bit
        (
            voltage : integer
        )
        return integer
        is
        begin
            return voltage/2**10+32768;
            
        end scale_voltage_to_16_bit;

        function scale_current_to_16_bit
        (
            current : integer
        )
        return integer
        is
        begin
            return current/2**7+32768;
            
        end scale_current_to_16_bit;

        function limit_to_6000
        (
            number : integer
        )
        return integer
        is
            variable return_value : integer;
        begin
            if number > 16000 then
                return_value := 16000;
            elsif number < -16000 then
                return_value := -16000;
            else
                return_value := number;
            end if;

            return return_value;
            
        end limit_to_6000;
        
    begin
        if rising_edge(clk) then
            init_bus(bus_from_hil_simulator);
            connect_data_to_address(bus_to_hil_simulator           , bus_from_hil_simulator , 1000 , input_voltage);
            connect_data_to_address(bus_to_hil_simulator           , bus_from_hil_simulator , 1001 , load_current);
            connect_read_only_data_to_address(bus_to_hil_simulator , bus_from_hil_simulator , 1002 , scale_current_to_16_bit(get_inductor_current(filtered_buck.input_lc1)));
            connect_read_only_data_to_address(bus_to_hil_simulator , bus_from_hil_simulator , 1003 , scale_voltage_to_16_bit(get_capacitor_voltage(filtered_buck.input_lc1)));
            connect_read_only_data_to_address(bus_to_hil_simulator , bus_from_hil_simulator , 1004 , scale_current_to_16_bit(get_inductor_current(filtered_buck.input_lc2)));
            connect_read_only_data_to_address(bus_to_hil_simulator , bus_from_hil_simulator , 1005 , scale_voltage_to_16_bit(get_capacitor_voltage(filtered_buck.input_lc2)));
            connect_read_only_data_to_address(bus_to_hil_simulator , bus_from_hil_simulator , 1006 , scale_current_to_16_bit(get_inductor_current(filtered_buck.primary_lc)));
            connect_read_only_data_to_address(bus_to_hil_simulator , bus_from_hil_simulator , 1007 , scale_voltage_to_16_bit(get_capacitor_voltage(filtered_buck.primary_lc)));
            connect_read_only_data_to_address(bus_to_hil_simulator , bus_from_hil_simulator , 1008 , scale_current_to_16_bit(get_inductor_current(filtered_buck.output_lc1)));
            connect_read_only_data_to_address(bus_to_hil_simulator , bus_from_hil_simulator , 1009 , scale_voltage_to_16_bit(get_capacitor_voltage(filtered_buck.output_lc1)));
            connect_read_only_data_to_address(bus_to_hil_simulator , bus_from_hil_simulator , 1010 , scale_current_to_16_bit(get_inductor_current(filtered_buck.output_lc2)));
            connect_read_only_data_to_address(bus_to_hil_simulator , bus_from_hil_simulator , 1011 , scale_voltage_to_16_bit(get_capacitor_voltage(filtered_buck.output_lc2)));
            connect_read_only_data_to_address(bus_to_hil_simulator , bus_from_hil_simulator , 1012 , duty_ratio);
            connect_read_only_data_to_address(bus_to_hil_simulator , bus_from_hil_simulator , 1013 , div_result+32768);
            connect_data_to_address(bus_to_hil_simulator           , bus_from_hil_simulator , 1014 , voltage_reference);
            connect_read_only_data_to_address(bus_to_hil_simulator , bus_from_hil_simulator , 1015 , scale_current_to_16_bit(get_dc_link_current(filtered_buck)));

            create_multiplier(div_multiplier);
            create_division(div_multiplier, divider);

            create_pi_control_and_multiplier(vpi_controller , pi_multiplier , to_fixed(0.001 , 16) , to_fixed(0.001 , 16)   , 2**19 , -2**19);
            create_pi_controller(pi_multiplier              , pi_controller , to_fixed(15.5  , 12) , to_fixed(0.05  , 12));
            duty_ratio <= get_pi_control_output(pi_controller);

            create_filtered_buck(filtered_buck, get_pi_control_output(pi_controller) + limit_to_6000(div_result/4)*0, input_voltage*2**10, load_current * 2**7 + radix_multiply(get_capacitor_voltage(filtered_buck.output_lc2), to_fixed(1.0/100.0, 20), 26, 20));

            if simulation_counter > 0 then
                simulation_counter <= simulation_counter - 1;
            else
                simulation_counter <= calculation_delay;
            end if;

            if simulation_counter = 0 then
                request_filtered_buck_calculation(filtered_buck);
                request_division(divider, get_capacitor_voltage(filtered_buck.primary_lc)/2,get_capacitor_voltage(filtered_buck.input_lc2)/2);
                request_pi_control(pi_controller, get_pi_control_output(vpi_controller)/2**4 - get_inductor_current(filtered_buck.primary_lc)/2**11);
            end if;

            if pi_control_is_ready(pi_controller) then
                request_pi_control(vpi_controller, voltage_reference - get_capacitor_voltage(filtered_buck.primary_lc)/2**10);
            end if;
            if division_is_ready(div_multiplier, divider) then
                div_result <= get_division_result(div_multiplier , divider , int_word_length-1)/2**10;
            end if;

        end if; --rising_edge
    end process hil_simulator;	
end rtl;

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
    type filtered_buck_record is record
        input_lc1  : lcr_model_record    ;
        input_lc2  : lcr_model_record    ;
        primary_lc : lcr_model_record    ;
        output_lc1 : lcr_model_record    ;
        output_lc2 : lcr_model_record    ;
        multiplier_1 : multiplier_record ;
        multiplier_2 : multiplier_record ;
        multiplier_3 : multiplier_record ;
        multiplier_4 : multiplier_record ;
        multiplier_5 : multiplier_record ;
    end record;

    constant init_filtered_buck : filtered_buck_record :=(
        init_lcr_filter(L2_inductance , C2_capacitance , 10.0e-3  , simulation_time_step , int_radix),
        init_lcr_filter(L3_inductance , C3_capacitance , 0.0      , simulation_time_step , int_radix),
        init_lcr_filter(L1_inductance , C1_capacitance , 300.0e-3 , simulation_time_step , int_radix),
        init_lcr_filter(L4_inductance , C4_capacitance , 0.0      , simulation_time_step , int_radix),
        init_lcr_filter(L5_inductance , C5_capacitance , 0.0      , simulation_time_step , int_radix),
        init_multiplier,
        init_multiplier,
        init_multiplier,
        init_multiplier,
        init_multiplier);


    procedure create_filtered_buck
    (
        signal self : inout filtered_buck_record;
        input_voltage : integer;
        load_current : integer
    ) is
    begin
        create_multiplier(self.multiplier_1);
        create_multiplier(self.multiplier_2);
        create_multiplier(self.multiplier_3);
        create_multiplier(self.multiplier_4);
        create_multiplier(self.multiplier_5);

        create_lcr_filter(self.input_lc1  , self.multiplier_1 , get_inductor_current(self.input_lc2)    , input_voltage                           , int_radix);
        create_lcr_filter(self.input_lc2  , self.multiplier_2 , get_inductor_current(self.primary_lc)/2 , get_capacitor_voltage(self.input_lc1)   , int_radix);
        create_lcr_filter(self.primary_lc , self.multiplier_3 , get_inductor_current(self.output_lc1)   , get_capacitor_voltage(self.input_lc2)/2 , int_radix);
        create_lcr_filter(self.output_lc1 , self.multiplier_4 , get_inductor_current(self.output_lc2)   , get_capacitor_voltage(self.primary_lc)  , int_radix);
        create_lcr_filter(self.output_lc2 , self.multiplier_5 , load_current                            , get_capacitor_voltage(self.output_lc1)  , int_radix);
        
    end create_filtered_buck;

    procedure request_filtered_buck_calculation
    (
        signal filtered_buck : out filtered_buck_record
    ) is
    begin
        request_lcr_filter_calculation(filtered_buck.input_lc1 );
        request_lcr_filter_calculation(filtered_buck.input_lc2 );
        request_lcr_filter_calculation(filtered_buck.primary_lc);
        request_lcr_filter_calculation(filtered_buck.output_lc1);
        request_lcr_filter_calculation(filtered_buck.output_lc2);
        
    end request_filtered_buck_calculation;

    signal m : filtered_buck_record := init_filtered_buck;

    signal output_voltage   : real := 0.0;
    signal inductor_current : real := 0.0;

    signal input_voltage : integer := 0;
    signal load_current : integer := 0;

    signal simulation_counter : integer range 0 to 119 := 119;
    signal duty_ratio : integer := 2**14;

begin

    hil_simulator : process(clk)
        
    begin
        if rising_edge(clk) then
            init_bus(bus_from_hil_simulator);
            connect_data_to_address(bus_to_hil_simulator           , bus_from_hil_simulator , 1000 , input_voltage);
            connect_data_to_address(bus_to_hil_simulator           , bus_from_hil_simulator , 1001 , load_current);
            connect_read_only_data_to_address(bus_to_hil_simulator , bus_from_hil_simulator , 1002 , get_inductor_current(m.input_lc1)  / 2**7+32768);
            connect_read_only_data_to_address(bus_to_hil_simulator , bus_from_hil_simulator , 1003 , get_capacitor_voltage(m.input_lc1) / 2**10+32768);
            connect_read_only_data_to_address(bus_to_hil_simulator , bus_from_hil_simulator , 1004 , get_inductor_current(m.input_lc2)  / 2**7+32768);
            connect_read_only_data_to_address(bus_to_hil_simulator , bus_from_hil_simulator , 1005 , get_capacitor_voltage(m.input_lc2) / 2**10+32768);
            connect_read_only_data_to_address(bus_to_hil_simulator , bus_from_hil_simulator , 1006 , get_inductor_current(m.primary_lc)  / 2**7+32768);
            connect_read_only_data_to_address(bus_to_hil_simulator , bus_from_hil_simulator , 1007 , get_capacitor_voltage(m.primary_lc) / 2**10+32768);
            connect_read_only_data_to_address(bus_to_hil_simulator , bus_from_hil_simulator , 1008 , get_inductor_current(m.output_lc1)  / 2**7+32768);
            connect_read_only_data_to_address(bus_to_hil_simulator , bus_from_hil_simulator , 1009 , get_capacitor_voltage(m.output_lc1) / 2**10+32768);
            connect_read_only_data_to_address(bus_to_hil_simulator , bus_from_hil_simulator , 1010 , get_inductor_current(m.output_lc2)  / 2**7+32768);
            connect_read_only_data_to_address(bus_to_hil_simulator , bus_from_hil_simulator , 1011 , get_capacitor_voltage(m.output_lc2) / 2**10+32768);

            create_filtered_buck(m, input_voltage*2**10, load_current*2**7);

            if simulation_counter > 0 then
                simulation_counter <= simulation_counter - 1;
            else
                simulation_counter <= 119;
            end if;

            if simulation_counter = 0 then
                request_filtered_buck_calculation(m );
            end if;

        end if; --rising_edge
    end process hil_simulator;	
end rtl;

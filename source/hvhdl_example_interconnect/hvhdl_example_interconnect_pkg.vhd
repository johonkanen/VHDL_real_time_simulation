library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    use work.communications_pkg.all;

package hvhdl_example_interconnect_pkg is

    type hvhdl_example_interconnect_FPGA_input_group is record
        communications_FPGA_in : communications_FPGA_input_group;
        adc_data : std_logic;
    end record;
    
    type hvhdl_example_interconnect_FPGA_output_group is record
        communications_FPGA_out : communications_FPGA_output_group;
        bclk      : std_logic;
        fsync     : std_logic;
    end record;
    
end package hvhdl_example_interconnect_pkg;
------------------------------------------------------------------------
------------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    use work.hvhdl_example_interconnect_pkg.all;
    use work.communications_pkg.all;
    use work.fpga_interconnect_pkg.all;
    use work.first_order_filter_pkg.all;
    use work.example_filter_entity_pkg.all;
    use work.i2s_pkg.all;

entity hvhdl_example_interconnect is
    port (
        system_clock : in std_logic;
        hvhdl_example_interconnect_FPGA_in  : in hvhdl_example_interconnect_FPGA_input_group;
        hvhdl_example_interconnect_FPGA_out : out hvhdl_example_interconnect_FPGA_output_group
    );
end hvhdl_example_interconnect;

architecture rtl of hvhdl_example_interconnect is

    use work.example_project_addresses_pkg.all;

    signal i     : integer range 0 to 2**16-1 := 1199;

    signal communications_clocks   : communications_clock_group;
    signal communications_data_in  : communications_data_input_group;
    signal communications_data_out : communications_data_output_group;

    signal floating_point_filter_in : example_filter_input_record := init_example_filter_input;
    signal fixed_point_filter_in    : example_filter_input_record := init_example_filter_input;

    alias bus_from_master is communications_data_out.bus_out;
    alias bus_to_master   is communications_data_in.bus_in;

    signal bus_from_floating_point_filter : fpga_interconnect_record := init_fpga_interconnect;
    signal bus_from_fixed_point_filter    : fpga_interconnect_record := init_fpga_interconnect;
    signal bus_from_interconnect          : fpga_interconnect_record := init_fpga_interconnect;

    signal data_in_example_interconnect : integer range 0 to 2**16-1 := 44252;

    signal bus_from_sigma_delta : fpga_interconnect_record := init_fpga_interconnect;
    constant filter_time_constant : real := 0.001;

    signal i2s : i2s_record := init_i2s;
    signal channel1_measurement : signed(31 downto 0);
    signal channel2_measurement : signed(31 downto 0);

    signal bus_from_hil : fpga_interconnect_record := init_fpga_interconnect;

begin

    hvhdl_example_interconnect_FPGA_out.bclk <= i2s.bclk;
    hvhdl_example_interconnect_FPGA_out.fsync <= i2s.fsynch;

    create_noisy_sine : process(system_clock)
    begin
        if rising_edge(system_clock) then

            init_example_filter(floating_point_filter_in);
            init_example_filter(fixed_point_filter_in);

            init_bus(bus_from_interconnect);
            connect_read_only_data_to_address(bus_from_master , bus_from_interconnect , 10e3   , to_integer(channel1_measurement(15 downto 0)) +32767);
            connect_read_only_data_to_address(bus_from_master , bus_from_interconnect , 10e3+1 , to_integer(channel2_measurement(15 downto 0)) +32767);

            connect_data_to_address(bus_from_master           , bus_from_interconnect , example_interconnect_data_address , data_in_example_interconnect);

            if i > 0 then
                i <= (i - 1);
            else
                i <= 1199;
            end if;

            create_i2s_driver(i2s, hvhdl_example_interconnect_FPGA_in.adc_data);

            if channel1_is_ready(i2s) then 
                channel1_measurement <= get_measurement(i2s);
            end if;

            if channel2_is_ready(i2s) then 
                channel2_measurement <= get_measurement(i2s);
            end if;

            if channel1_is_ready(i2s) then
                request_example_filter(floating_point_filter_in, to_integer(channel1_measurement(15 downto 0)));
                request_example_filter(fixed_point_filter_in, to_integer(channel1_measurement(15 downto 0)));
            end if;

        end if; --rising_edge
    end process;	
---------------
--     u_floating_point_filter : entity work.example_filter_entity(float)
--         generic map(filter_time_constant => filter_time_constant)
--         port map(system_clock, floating_point_filter_in, bus_from_master, bus_from_floating_point_filter);
--
-- ---------------
--     u_fixed_point_filter : entity work.example_filter_entity(fixed_point)
--         generic map(filter_time_constant => filter_time_constant)
--         port map(system_clock, fixed_point_filter_in, bus_from_master, bus_from_fixed_point_filter);

------------------------------------------------------------------------
    u_hil : entity work.hil_simulation
    port map(system_clock, bus_from_master, bus_from_hil);
------------------------------------------------------------------------
    combine_buses : process(system_clock)
    begin
        if rising_edge(system_clock) then
            bus_to_master <= bus_from_interconnect and bus_from_floating_point_filter and bus_from_fixed_point_filter and bus_from_sigma_delta and bus_from_hil;
        end if; --rising_edge
    end process combine_buses;	

--------------
    communications_clocks <= (clock => system_clock);
    u_communications : entity work.communications
    port map(
        communications_clocks,
        hvhdl_example_interconnect_FPGA_in.communications_FPGA_in,
        hvhdl_example_interconnect_FPGA_out.communications_FPGA_out,
        communications_data_in ,
        communications_data_out);
------------------------------------------------------------------------
end rtl;

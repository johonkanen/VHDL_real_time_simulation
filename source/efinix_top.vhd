library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    use work.i2s_pkg.all;

entity efinix_top is
    port (
        clock_120mhz  : in std_logic;
        uart_rx       : in std_logic;
        uart_tx       : out std_logic;

        sdm_clock_out : out std_logic;
        sdm_data_in   : in std_logic;

        bclk  : out std_logic;
        fsync : out std_logic
    );
end entity efinix_top;

architecture rtl of efinix_top is

    signal i2s : i2s_record := init_i2s;


begin

    bclk <= i2s.bclk;
    fsync <= i2s.fsynch;

    test_i2s : process(clock_120mhz)
    begin
        if rising_edge(clock_120mhz) then
            create_i2s_driver(i2s);
        end if; --rising_edge
    end process test_i2s;	

--------------------------------------------------
    u_hvhdl_example : entity work.hvhdl_example_interconnect
    port map(
        system_clock => clock_120mhz,
        hvhdl_example_interconnect_FPGA_in.communications_FPGA_in.uart_rx   => uart_rx,
        hvhdl_example_interconnect_FPGA_in.sdm_data => sdm_data_in,
        hvhdl_example_interconnect_FPGA_out.communications_FPGA_out.uart_tx => uart_tx,
        hvhdl_example_interconnect_FPGA_out.sdm_clock => sdm_clock_out);


end rtl;

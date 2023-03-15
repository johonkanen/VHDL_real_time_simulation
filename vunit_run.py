#!/usr/bin/env python3

from pathlib import Path
from vunit import VUnit

# ROOT
ROOT = Path(__file__).resolve().parent
VU = VUnit.from_argv()

float_library = VU.add_library("float_library")
float_library.add_source_files(ROOT / "source/hVHDL_floating_point/float_type_definitions/float_word_length_24_bit_pkg.vhd")
float_library.add_source_files(ROOT / "source" / "hVHDL_floating_point" / "float_type_definitions/float_type_definitions_pkg.vhd")
float_library.add_source_files(ROOT / "source" / "hVHDL_floating_point" / "float_arithmetic_operations/*.vhd")

i2s_library = VU.add_library("i2s_library")
i2s_library.add_source_files(ROOT / "testbenches/i2s/i2s_pkg.vhd")
i2s_library.add_source_files(ROOT / "testbenches/i2s/i2s_tb.vhd")

math_library_26x26 = VU.add_library("math_library_26x26")

math_library_26x26.add_source_files(ROOT / "source/hVHDL_dynamic_model_verification_library/hVHDL_math_library/real_to_fixed/real_to_fixed_pkg.vhd            ")
math_library_26x26.add_source_files(ROOT / "source/hVHDL_math_library/multiplier/configuration/multiply_with_1_input_and_output_registers_pkg.vhd")
math_library_26x26.add_source_files(ROOT / "source/hVHDL_dynamic_model_verification_library/hVHDL_math_library/multiplier/multiplier_base_types_26bit_pkg.vhd ")
math_library_26x26.add_source_files(ROOT / "source/hVHDL_dynamic_model_verification_library/hVHDL_math_library/multiplier/multiplier_pkg.vhd                  ")
math_library_26x26.add_source_files(ROOT / "source/hVHDL_math_library/division/division_internal_pkg.vhd")
math_library_26x26.add_source_files(ROOT / "source/hVHDL_math_library/division/division_pkg.vhd")
math_library_26x26.add_source_files(ROOT / "source/hVHDL_math_library/division/division_pkg_body.vhd")
math_library_26x26.add_source_files(ROOT / "source/hVHDL_math_library/pi_controller/pi_controller_pkg.vhd")


math_library_26x26.add_source_files(ROOT / "source/hVHDL_dynamic_model_verification_library/state_variable/state_variable_pkg.vhd                             ")
math_library_26x26.add_source_files(ROOT / "source/hVHDL_dynamic_model_verification_library/lcr_filter_model/lcr_filter_model_pkg.vhd                         ")
math_library_26x26.add_source_files(ROOT / "source/hVHDL_dynamic_model_verification_library/buck_simulation_model/filtered_buck_model_pkg.vhd")
math_library_26x26.add_source_files(ROOT / "source/hVHDL_fpga_interconnect/interconnect_configuration/data_15_address_15_bit_pkg.vhd")
math_library_26x26.add_source_files(ROOT / "source/hVHDL_fpga_interconnect/fpga_interconnect_pkg.vhd")
math_library_26x26.add_source_files(ROOT / "source/hil_simulation/hil_simulation_test_pkg.vhd")
math_library_26x26.add_source_files(ROOT / "source/hil_simulation/hil_simulation.vhd")
#26x26 testbenches
math_library_26x26.add_source_files(ROOT / "source/hVHDL_dynamic_model_verification_library" / "simulator_utilities/write_pkg.vhd")
math_library_26x26.add_source_files(ROOT / "testbenches/hil_simulation/hil_simulation_tb.vhd")

VU.main()

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

i2c_library = VU.add_library("i2c_library")
i2c_library.add_source_files(ROOT / "other_sources/i2c_pkg.vhd")
i2c_library.add_source_files(ROOT / "testbenches/i2c/i2c_tb.vhd")

math_library_26x26 = VU.add_library("math_library_26x26")
math_library_26x26.add_source_files(ROOT / "source/hVHDL_dynamic_model_verification_library" / "hVHDL_math_library/real_to_fixed/real_to_fixed_pkg.vhd")
math_library_26x26.add_source_files(ROOT / "source/hVHDL_dynamic_model_verification_library" / "simulator_utilities/write_pkg.vhd")
math_library_26x26.add_source_files(ROOT / "source/hVHDL_dynamic_model_verification_library" / "hVHDL_math_library/multiplier/multiplier_base_types_26bit_pkg.vhd")
math_library_26x26.add_source_files(ROOT / "source/hVHDL_dynamic_model_verification_library" / "hVHDL_math_library/multiplier/multiplier_pkg.vhd")
math_library_26x26.add_source_files(ROOT / "source/hVHDL_dynamic_model_verification_library" / "state_variable/state_variable_pkg.vhd")
math_library_26x26.add_source_files(ROOT / "source/hVHDL_dynamic_model_verification_library" / "lcr_filter_model/lcr_filter_model_pkg.vhd")
#26x26 testbenches
math_library_26x26.add_source_files(ROOT / "source/hVHDL_dynamic_model_verification_library" / "testbenches/buck/buck_with_input_and_output_filters_tb.vhd")
math_library_26x26.add_source_files(ROOT / "source/hVHDL_dynamic_model_verification_library" / "testbenches/converter_models/cascaded_lcr_filters_tb.vhd")
math_library_26x26.add_source_files(ROOT / "source/hVHDL_dynamic_model_verification_library" / "testbenches/buck/buck_converter_tb.vhd")
math_library_26x26.add_source_files(ROOT / "source/hVHDL_dynamic_model_verification_library" / "testbenches/buck/filtered_buck_synthesizable_tb.vhd")

VU.main()

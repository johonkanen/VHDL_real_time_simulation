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

filter_library = VU.add_library("filter_library")
filter_library.add_source_files(ROOT / "source/hVHDL_math_library/multiplier/multiplier_base_types_18bit_pkg.vhd")
filter_library.add_source_files(ROOT / "source/hVHDL_math_library/multiplier/multiplier_pkg.vhd")
filter_library.add_source_files(ROOT / "testbenches/iir_filter_pkg.vhd")
filter_library.add_source_files(ROOT / "testbenches/filter_simulation.vhd")

i2s_library = VU.add_library("i2s_library")
i2s_library.add_source_files(ROOT / "testbenches/i2s/i2s_pkg.vhd")
i2s_library.add_source_files(ROOT / "testbenches/i2s/i2s_tb.vhd")

i2c_library = VU.add_library("i2c_library")
i2c_library.add_source_files(ROOT / "testbenches/i2c/i2c_tb.vhd")

VU.main()

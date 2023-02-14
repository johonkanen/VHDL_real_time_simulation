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
filter_library.add_source_files(ROOT / "testbenches/test_first_order_filter_tb.vhd")

i2s_library = VU.add_library("i2s_library")
i2s_library.add_source_files(ROOT / "testbenches/i2s/i2s_pkg.vhd")
i2s_library.add_source_files(ROOT / "testbenches/i2s/i2s_tb.vhd")

test_library = VU.add_library("test_library")
test_library.add_source_files(ROOT / "testbenches/test_real_to_signed_conversion_tb.vhd")

# float_library.add_source_files(ROOT / "source/hVHDL_floating_point" / "normalizer / normalizer_configuration / normalizer_with_4_stage_pipe_pkg.vhd")
# float_library.add_source_files(ROOT / "source/hVHDL_floating_point" / "normalizer / *.vhd")
# float_library.add_source_files(ROOT / "source/hVHDL_floating_point" / "normalizer / simulate_normalizer      / *.vhd")
#
# float_library.add_source_files(ROOT / "source/hVHDL_floating_point" / "denormalizer / denormalizer_configuration / denormalizer_with_4_stage_pipe_pkg.vhd")
# float_library.add_source_files(ROOT / "source/hVHDL_floating_point" / "denormalizer / *.vhd")
# float_library.add_source_files(ROOT / "source/hVHDL_floating_point" / "denormalizer / denormalizer_simulation    / *.vhd")
#
# float_library.add_source_files(ROOT / "source/hVHDL_floating_point" / "float_to_real_conversions" / "*.vhd")
# float_library.add_source_files(ROOT / "source/hVHDL_floating_point" / "float_to_real_conversions  / float_to_real_simulation" / "*.vhd")
#
# float_library.add_source_files(ROOT / "source/hVHDL_floating_point" / "float_adder / *.vhd")
# float_library.add_source_files(ROOT / "source/hVHDL_floating_point" / "float_adder / adder_simulation / *.vhd")
#
# float_library.add_source_files(ROOT / "source/hVHDL_floating_point" / "float_multiplier / *.vhd")
# float_library.add_source_files(ROOT / "source/hVHDL_floating_point" / "float_multiplier / float_multiplier_simulation / *.vhd")
#
# float_library.add_source_files(ROOT / "source/hVHDL_floating_point" / "float_alu / *.vhd")
# float_library.add_source_files(ROOT / "source/hVHDL_floating_point" / "float_alu / float_alu_simulation / *.vhd")
#
# float_library.add_source_files(ROOT / "source/hVHDL_floating_point" / "float_first_order_filter / *.vhd")
# float_library.add_source_files(ROOT / "source/hVHDL_floating_point" / "float_first_order_filter / simulate_float_filter / *.vhd")
#
#
# float_library.add_source_files(ROOT / "source/hVHDL_floating_point" / "float_to_integer_converter / float_to_integer_simulation / *.vhd")
#
VU.main()

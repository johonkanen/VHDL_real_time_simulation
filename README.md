To clone with all submodules use

git clone --recurse-submodules -j8 https://github.com/hVHDL/hVHDL_example_project.git

This is a test project that uses the main features of [hVHDL](https://github.com/hVHDL) libraries. The test project creates a noisy sine wave that is then filtered using fixed and floating point filters that are written in using hVHDL modules. Running the test_app.py reads and writes registers in the FPGA and prints out the results to the console and additionally requests a 200 000 data point stream from the FPGA that is then plotted using pyplot.

<p align="center">
  <img width="550px" src="doc/test_app_run.png"/></a>
</p>

There is an in-depth [explanation](https://hvhdl.readthedocs.io/en/latest/hvhdl_example_project/hvhdl_example_project.html) which goes through the VHDL source code of the design.

In order to build with efinix, go to the efinix build folder <path_to_example_project>/efinix_titanium_build, then run
> efx_run.py hvhdl_example_build.xml --output_dir ./output

Note, efinix build tools require running <efinix_efinity_folder>\bin\setup.bat before launching the build. Alternatively, you can open the hvhdl_exmpla_build.xml with the efinity ide and press build

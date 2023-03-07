import os
import sys
import time

abs_path = os.path.dirname(os.path.realpath(__file__))
sys.path.append(abs_path + '/fpga_uart_pc_software/')

from uart_communication_functions import *

uart = uart_link("COM23", 5e6)

number_of_datapoints_to_stream = 30000
print("run a transient test")

voltage_gain = 400/12800;

uart.request_data_stream_from_address(1007, number_of_datapoints_to_stream)
uart.write_data_to_address(1000, 2000);
time.sleep(0.03)
uart.write_data_to_address(1001, 10000);
time.sleep(0.03)
uart.write_data_to_address(1001, 0);
time.sleep(0.03)

transient_data = uart.get_streamed_data(number_of_datapoints_to_stream)
pyplot.plot((transient_data-32768)*voltage_gain)
pyplot.show()
uart.write_data_to_address(1000, 0);


pyplot.show()

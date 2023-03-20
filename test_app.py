import os
import sys
import time

abs_path = os.path.dirname(os.path.realpath(__file__))
sys.path.append(abs_path + '/fpga_uart_pc_software/')

from uart_communication_functions import *

uart = uart_link("COM9", 5e6)

number_of_datapoints_to_stream = int(150e3)
print("run a transient test")

voltage_gain = 400/12800;
voltage_to_fixed_point = 12800/400;

def exitation():
    time.sleep(0.025)
    uart.write_data_to_address(1000, 15000);
    time.sleep(0.075)
    uart.write_data_to_address(1014, 2000) 
    time.sleep(0.075)
    uart.write_data_to_address(1014, 7000);
    time.sleep(0.1)
    uart.write_data_to_address(1001, 2500);
    time.sleep(0.1)
    uart.write_data_to_address(1000, 12800);
    time.sleep(0.1)
    uart.write_data_to_address(1001, 0);
    time.sleep(0.1)

def get_voltage(address):

    uart.request_data_stream_from_address(address, number_of_datapoints_to_stream)
    exitation()
    return (uart.get_streamed_data(number_of_datapoints_to_stream)-32768)*voltage_gain

def get_data(address):

    uart.request_data_stream_from_address(address, number_of_datapoints_to_stream)
    exitation()
    return (uart.get_streamed_data(number_of_datapoints_to_stream))

def get_current(address):
    return get_voltage(address)/8.0

pyplot.subplot(3, 1, 1)
pyplot.plot(get_voltage(1007))
pyplot.plot(get_voltage(1005))
pyplot.plot(get_voltage(1011))
pyplot.legend(['primary lc voltage', 'bridge input voltage', 'output voltage'])
pyplot.subplot(3, 1, 2)
# pyplot.plot(get_current(1004))
# pyplot.plot(get_current(1006))
pyplot.plot((-32768 + get_data(1013))/32768)
pyplot.legend(['input_voltage/output_voltage -feedforward term'])
pyplot.subplot(3, 1, 3)
pyplot.plot(get_data(1012)/32768)
pyplot.legend(['duty ratio'])
pyplot.show()

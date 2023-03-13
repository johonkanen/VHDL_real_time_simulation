import os
import sys
import time

abs_path = os.path.dirname(os.path.realpath(__file__))
sys.path.append(abs_path + '/fpga_uart_pc_software/')

from uart_communication_functions import *

uart = uart_link("COM23", 5e6)

number_of_datapoints_to_stream = int(150e3)
print("run a transient test")

voltage_gain = 400/12800;
voltage_to_fixed_point = 12800/400;

def get_voltage(address):

    uart.request_data_stream_from_address(address, number_of_datapoints_to_stream)
    time.sleep(0.025)
    uart.write_data_to_address(1012, 20000) 
    time.sleep(0.1)
    uart.write_data_to_address(1001, 2000);
    time.sleep(0.1)
    uart.write_data_to_address(1001, 0);
    time.sleep(0.1)
    uart.write_data_to_address(1012, 65536-20000)
    return (uart.get_streamed_data(number_of_datapoints_to_stream)-32768)*voltage_gain

def get_current(address):
    return get_voltage(address)/8.0

pyplot.subplot(2, 2, 1)
pyplot.plot(get_voltage(1003))
pyplot.plot(get_voltage(1005))
pyplot.legend(['input emi 1 voltage', 'input emi 2 voltage']) 
pyplot.subplot(2, 2, 3)
pyplot.plot(get_voltage(1007))
pyplot.plot(get_voltage(1009))
pyplot.plot(get_voltage(1011))
pyplot.legend(['primary lc voltage', 'output emi 1 voltage', 'output emi 2 voltage'])
pyplot.subplot(2, 2, 2)
pyplot.plot(get_current(1002))
pyplot.plot(get_current(1004))
pyplot.legend(['input emi 1 current', 'input emi 2 current']) 
pyplot.subplot(2, 2, 4)
pyplot.plot(get_current(1006))
pyplot.plot(get_current(1008))
pyplot.plot(get_current(1010))
pyplot.legend(['primary lc current', 'output emi 1 current', 'output emi 2 current'])
pyplot.show()

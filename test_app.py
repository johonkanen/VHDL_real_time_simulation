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

    # uart.write_data_to_address(1000, 12800);
    # uart.write_data_to_address(1001, 0);
    # time.sleep(0.1)
    # uart.write_data_to_address(1012, int(25000))
    # time.sleep(0.1)
    # uart.write_data_to_address(1014, int(1500))

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

pyplot.subplot(4, 1, 1)
pyplot.plot(get_voltage(1007))
pyplot.subplot(4, 1, 2)
pyplot.plot(get_current(1004))
pyplot.plot(get_current(1006))
pyplot.plot(get_current(1015))
pyplot.subplot(4, 1, 3)
pyplot.plot(get_data(1012))
pyplot.plot(-32768 + get_data(1013))
pyplot.subplot(4, 1, 4)
pyplot.plot(get_voltage(1005))
# pyplot.plot(get_voltage(1005))
# pyplot.legend(['input emi 1 voltage', 'input emi 2 voltage']) 
# pyplot.subplot(2, 2, 3)
# pyplot.plot(get_voltage(1007))
# pyplot.plot(get_voltage(1009))
# pyplot.plot(get_voltage(1011))
# pyplot.legend(['primary lc voltage', 'output emi 1 voltage', 'output emi 2 voltage'])
# pyplot.subplot(2, 2, 2)
# pyplot.plot(get_current(1002))
# pyplot.plot(get_current(1004))
# pyplot.legend(['input emi 1 current', 'input emi 2 current']) 
# pyplot.subplot(2, 2, 4)
# pyplot.plot(get_current(1006))
# pyplot.plot(get_current(1008))
# pyplot.plot(get_current(1010))
# pyplot.legend(['primary lc current', 'output emi 1 current', 'output emi 2 current'])
pyplot.show()

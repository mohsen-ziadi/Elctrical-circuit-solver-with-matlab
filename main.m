clear, clc, close all  
filename = 'input.txt';
node_voltages = nodeVoltageMethod(filename)
filename = input('Enter directory/name of the input file including extension (''.txt''): ', 's');
node_voltages = nodeVoltageMethod(filename)

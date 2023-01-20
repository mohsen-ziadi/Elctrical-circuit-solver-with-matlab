function nodeVoltages = nodeVoltageMethod(filename)

fileID = fopen(filename);   
assert(fileID ~= -1, 'Could not open file ''%s''', filename)   
input_data = textscan(fileID, '%s %d %d %f');               
closed = fclose(fileID);       
assert(closed ~= -1, 'Could not close file %d: ''%s''', fileID, filename) 

element_names = input_data{1};      
first_nodes = input_data{2}(:);     
second_nodes = input_data{3}(:);    
values = input_data{4}(:);          

is_voltage = startsWith(element_names, 'V');
is_current = startsWith(element_names, 'I');
is_resistance = startsWith(element_names, 'R');


assert(all(is_voltage | is_current | is_resistance), 'Unidentified element names exist at ''%s''', filename)
assert(all(values(is_resistance) >= 0), 'Negative resistance values exist at ''%s''', filename)

m = nnz(is_voltage);            
n = max(second_nodes);          

G = zeros(n);       
for node = 1:n      
    G(node, node) = sum(1 ./ values((first_nodes == node | second_nodes == node) & is_resistance));
end
for r_ind = find(is_resistance).'
    R_first_nodes = first_nodes(r_ind);
    R_second_nodes = second_nodes(r_ind);
    if R_first_nodes > 0 && R_second_nodes > 0      
        G(R_first_nodes, R_second_nodes) = G(R_first_nodes, R_second_nodes) - 1/values(r_ind);
        G(R_second_nodes, R_first_nodes) = G(R_second_nodes, R_first_nodes) - 1/values(r_ind);
    end    
end

B = zeros(n,m);
voltage_no = 1;
for v_ind = find(is_voltage).'  
    if first_nodes(v_ind) > 0   
        B(first_nodes(v_ind), voltage_no) = -1; 
    end         
    if second_nodes(v_ind) > 0
        B(second_nodes(v_ind), voltage_no) = 1;     
    end     
    voltage_no = voltage_no + 1;    
end                                 

C = B.';       

D = zeros(m);  

A = [G, B; C, D];  


i = zeros(n,1);     
for node = 1:n      
    i(node) = sum(values(second_nodes == node & is_current)) - sum(values(first_nodes == node & is_current));
end                 

e = values(is_voltage);

z = [i; e];         

x = A \ z;              
nodeVoltages = x(1:n);  
                        
end
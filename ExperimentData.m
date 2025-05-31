serialPort = 'COM3';   % Make sure it matches your Arduino port
baudRate = 9600;
outputFile = 'flow_distance_data.txt';

s = serialport(serialPort, baudRate);
configureTerminator(s, "LF"); % Arduino ends lines with '\n'

fileID = fopen(outputFile, 'w');
fprintf(fileID, 'Time(s)\tFlow(L/min)\tFlow(mL/s)\tTotal(mL)\tNrPulses\tDistance(cm)\n');
disp('Logging data from Arduino... Press Ctrl+C to stop when the water in the tank has completly drained.');

while true
    try
        dataLine = readline(s);
        data = str2double(strsplit(strtrim(dataLine), '\t'));
        
        if numel(data) == 6 && all(~isnan(data)) % also checks that data contains only numbers
            % Save to file
            fprintf(fileID, '%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\n', data);
            % Display to console
            disp(data);
        end
    catch ME
        warning('Error reading data: %s', ME.message);
        break;
    end
end

fclose(fileID);
clear s;
disp('Logging stopped.');

data = readmatrix('flow_distance_data.txt');
% Column headers: "Time(s)\tFlow(L/min)\tFlow(mL/s)\tTotal(mL)\t NrPulses\t Distance(cm)"

time = data(:, 1); % seconds
flow = data(:, 2); % L/min
pulseCount = data(:, 5);
distance = data(:, 6); % cm
volume_f = data(:, 4); % mL

initialH = 2;   % Initial water height from ultrasonic sensor (cm)
tankH = 18;     % Total tank height (cm)
R_tank = 3;   % Tank radius (cm)
R_tube = 0.5;   % Outflow tube radius (cm)
A_tank = pi * R_tank^2;  % cm^2
A_tube = pi * R_tube^2;  % cm^2

flow_rate = [];
calibration_fact = [];
calibration_fact2 = [];
volume_u = [];
totalPulses = sum(pulseCount);

flow_rate(1) = (A_tank * (distance(1) - initialH)) / 1000 * 60 / (time(1)); % converted to L/min
calibration_fact(1) = pulseCount(1) / (A_tank * (distance(1) - initialH) * 60 /1000);
calibration_fact2(1) = pulseCount(1) / (time(1) * flow(1));
for i=1:(length(distance) - 1)
    dh = distance(i+1) - distance(i);
    dt = time(i+1) - time(i);
    flow_rate(end+1) = (A_tank * dh / dt) / 1000 * 60; % flow rate measured with ultrasonic sensor
    calibration_fact(end+1) = pulseCount(i+1) / (A_tank * dh * 60 /1000); % calibration factor per time step from ultrasonic
    calibration_fact2(end+1) = pulseCount(i+1) / (time(i+1) * flow(i+1)); % calibration factor per time step from flow sensor
end

for i=1:length(distance)
    volume_u(end+1) = A_tank * (tankH + initialH - distance(i)); % volume from ultrasonic sensor cm^3
end

final_time = time(end);
outflow_v = ((flow_rate / 60 * 1000) ./ A_tube) / 100;  % m/s

avg_flow_rate = A_tank * tankH / final_time / 1000 * 60; % L/min
calibration_factor = totalPulses / (avg_flow_rate * final_time); % pulses/sec per (L/min)
fprintf('The calculated calibration factor is: %.3f\n', calibration_factor);

figure;
plot(time, flow_rate);
xlabel('Time (s)');
ylabel('Flow Rate (L/min)');
title('Measured flow rate VS Actual flow rate over time');
grid on;
hold on;
plot(time, flow);
legend('Flow sensor measured', 'Ultrasonic measured'); % actual flow rate is found from the ultrasonic sensor
hold off;
saveas(gcf, 'flow_rate_plot.png');

figure;
plot(time, volume_u);
xlabel('Time (s)');
ylabel('Volume (cm^3)');
title('Volume in tank over time from 2 measurements');
grid on;
hold on;
plot(time, volume_f);
legend('Volume ultrasonic sensor', 'Volume flow sensor');
hold off;
saveas(gcf, 'volume_plot.png');

% Calibration Factor Statistics Plot
cf1 = calibration_fact(:);
cf1(isnan(cf1)) = [];
n = length(cf1);
x = 1:n;
mean_cf1 = mean(cf1);
std_cf1 = std(cf1);

cf2 = calibration_fact2(:);
cf2(isnan(cf2)) = [];
mean_cf2 = mean(cf2);
std_cf2 = std(cf2);

figure;
subplot(1, 2, 1);
fill([x, fliplr(x)], [mean_cf1 + std_cf1 * ones(1, n), fliplr(mean_cf1 - std_cf1 * ones(1, n))], [1 0.6 0.6], 'EdgeColor', 'none');
hold on;
plot(x, cf1, 'bo', 'DisplayName', 'Individual CF');
plot(x, mean_cf1 * ones(1, n), 'r--', 'LineWidth', 1.5, 'DisplayName', 'Mean');
xlabel('Dataset');
ylabel('Calibration Factor (pulses/sec per L/min)');
title('Calibration Factor (Ultrasonic)');
grid on;
legend;
hold off;

subplot(1, 2, 2);
fill([x, fliplr(x)], [mean_cf2 + std_cf2 * ones(1, n), fliplr(mean_cf2 - std_cf2 * ones(1, n))], [1 0.6 0.6], 'EdgeColor', 'none');
hold on;
plot(x, cf2, 'bo', 'DisplayName', 'Individual CF');
plot(x, mean_cf2 * ones(1, n), 'r--', 'LineWidth', 1.5, 'DisplayName', 'Mean');
xlabel('Dataset');
title('Calibration Factor (Flow Sensor)');
grid on;
legend;
hold off;
saveas(gcf, 'calibration_comparison_plot.png');

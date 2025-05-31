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
volume_u = [];
totalPulses = sum(pulseCount);

flow_rate(1) = (A_tank * (distance(1) - initialH)) / 1000 * 60 / (time(1)); % converted to L/min
calibration_fact(1) = pulseCount(1) / (A_tank * (distance(1) - initialH));
for i=1:(length(distance) - 1)
    dh = distance(i+1) - distance(i);
    dt = time(i+1) - time(i);
    flow_rate(end+1) = (A_tank * dh / dt) / 1000 * 60; % flow rate measured with ultrasonic sensor
    calibration_fact(end+1) = pulseCount(i+1) / (A_tank * dh * 60 /1000); % calibration factor per time step
end

for i=1:length(distance)
    volume_u(end+1) = A_tank * (tankH + initialH - distance(i)); % volume from ultrasonic sensor cm^3
end

final_time = time(end);
outflow_v = ((flow_rate / 60 * 1000) ./ A_tube) / 100;  % m/s

avg_flow_rate = A_tank * tankH / final_time / 1000 * 60; % L/min
calibration_factor = totalPulses / (avg_flow_rate * final_time); % pulses/sec per (L/min)
fprintf('The calculated calibration factor is: %.3f\n', calibration_factor);

fprintf('The total energy according to the volume measured by the ultrasonic sensor is: %.3f\n', volume_u(end) / 10^6 * 100 * 1000 * 9.81);
fprintf('The total energy according to the volume measured by the flow sensor is: %.3f\n', volume_f(end) / 10^6 * 100 * 1000 * 9.81);

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

figure;
plot(time, outflow_v);
xlabel('Time (s)');
ylabel('Outflow velocity (m/s)');
title('Outflow velocity over time');
saveas(gcf, 'outflow_velocity_plot.png');

figure;
plot(time, calibration_fact);
xlabel('Time (s)');
ylabel('Calibration Factor (pulses per L/min)');
title('Instantaneous Calibration Factor Over Time');
grid on;
saveas(gcf, 'calibration_plot.png');

cf = calibration_fact(:);                 
cf(isnan(cf)) = [];                       % remove NaNs if any
n = length(cf);
x = 1:n;                                  % dataset indices

mean_cf = mean(cf);
std_cf = std(cf);
fprintf('The mean of the insatantanoues calibration factor is: %.3f\n', mean_cf);
figure;
hold on;
% Shaded area ±1 std
fill([x, fliplr(x)], ...
     [mean_cf + std_cf * ones(1, n), fliplr(mean_cf - std_cf * ones(1, n))], ...
     [1 0.6 0.6], 'EdgeColor', 'none');  % red-pink fill
plot(x, cf, 'bo', 'DisplayName', 'Individual CF');
plot(x, mean_cf * ones(1, n), 'r--', 'LineWidth', 1.5, 'DisplayName', 'Mean');
xlabel('Dataset');
ylabel('Calibration Factor (pulses/sec per L/min)');
title('Measured Calibration Factors with Mean ± Std Dev');
legend('Location', 'best');
grid on;
hold off;
saveas(gcf, 'calibration_distribution_plot.png');

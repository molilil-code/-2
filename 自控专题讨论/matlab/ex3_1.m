clc;
clear;
close all;

s = tf('s');

% 开环系统
G = 1/(s*(s+2));

% 根轨迹
figure;
rlocus(G);

grid on;

title('基础根轨迹图');
xlabel('Real Axis');
ylabel('Imaginary Axis');
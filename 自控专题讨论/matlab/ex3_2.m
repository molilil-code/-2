clc;
clear;
close all;

s = tf('s');

% 图2等效开环系统
G2 = s/(s^2 + 2*s + 20);

figure;
rlocus(G2);

sgrid;
grid on;

axis([-8 1 -6 6])

title('测速反馈参数根轨迹图');
xlabel('Real Axis');
ylabel('Imaginary Axis');
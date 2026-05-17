clc;
clear;
close all;

s = tf('s');

T = 20/(s^2 + 6.33*s + 20);

figure;
step(T);

grid on;
hold on;

info = stepinfo(T);

% 峰值点
plot(info.PeakTime,info.Peak,'ro','MarkerSize',5);

text(info.PeakTime,info.Peak,...
    ['Peak=',num2str(info.Peak)]);

title('基础方案单位阶跃响应');
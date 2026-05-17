clc;
clear;
close all;

s = tf('s');

K1 = 20;
K2 = 0.2165;

T = 20/(s^2 + (2 + K1*K2)*s + 20);

t = 0:0.01:10;

% 改成列向量
r = t';

% 系统输出
y = lsim(T,r,t);

% 误差
e = r - y;

figure;

plot(t,e,'LineWidth',1.5);

grid on;

title('斜坡输入下的跟踪误差');
xlabel('Time (s)');
ylabel('e(t)');
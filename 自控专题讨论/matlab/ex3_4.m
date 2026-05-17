clc;
clear;
close all;

s = tf('s');

%% ========= 基础方案 =========

K1 = 20;
K2 = 0.2165;

G_base = 20/(s*(s+6.33));

T_base = feedback(G_base,1);

%% ========= 超前-滞后校正方案 =========

% 校正器参数
z1 = 2;
p1 = 8;

z2 = 0.2;
p2 = 0.057;

Kc = 8;     % 可后续调整

Gc = Kc * ((s+z1)*(s+z2))/((s+p1)*(s+p2));

% 校正后开环
G_comp = Gc * G_base;

% 校正后闭环
T_comp = feedback(G_comp,1);

%% ========= 阶跃响应对比 =========

figure;

step(T_base,'b',T_comp,'r',5);

grid on;

legend('基础方案','超前-滞后校正方案');

title('超前-滞后校正阶跃响应对比图');

xlabel('时间 (s)');
ylabel('输出');

%% ========= 输出性能指标 =========

disp('基础方案性能指标：');
stepinfo(T_base)

disp('校正方案性能指标：');
stepinfo(T_comp)
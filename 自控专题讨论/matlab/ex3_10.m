clc;
clear;
close all;

%% 参数设置
K1 = 20;
K2 = 0.2165;

dt = 0.001;
t = 0:dt:6;

r = 1;   % 单位阶跃输入

%% 不同非线性工况
cases = {
    '理想线性系统',              0,   0,   0;
    '仅加入死区 d=1.0',          1.0, 0,   0;
    '死区 + 粘性摩擦',           1.0, 1.5, 0;
    '死区 + 粘性摩擦 + 库仑摩擦', 1.0, 1.5, 0.8;
};

figure;
hold on;

for i = 1:size(cases,1)

    name = cases{i,1};
    d    = cases{i,2};   % 死区宽度
    B    = cases{i,3};   % 粘性摩擦系数
    Fc   = cases{i,4};   % 库仑摩擦系数

    y = 0;       % 位移
    v = 0;       % 速度
    y_data = zeros(size(t));

    for k = 1:length(t)

        % 误差
        e = r - y;

        % 控制器输出
        uc = K1 * e;

        % 死区非线性
        if abs(uc) < d
            u = 0;
        elseif uc >= d
            u = uc - d;
        else
            u = uc + d;
        end

        % 摩擦力
        if abs(v) < 1e-6
            Ff = 0;
        else
            Ff = B * v + Fc * sign(v);
        end

        % 被控对象 1/[s(s+2)]
        % y'' + 2y' = u - K2*y' - Ff
        dy = v;
        dv = -2*v - K2*v + u - Ff;

        % 欧拉积分
        y = y + dy * dt;
        v = v + dv * dt;

        y_data(k) = y;
    end

    plot(t, y_data, 'LineWidth', 2, 'DisplayName', name);

end

grid on;
xlabel('时间 t / s');
ylabel('输出响应 y(t)');
title('图3-10 死区非线性响应对比图');
legend('Location','best');
xlim([0 6]);
ylim([0 1.5]);

set(gca,'FontSize',12);
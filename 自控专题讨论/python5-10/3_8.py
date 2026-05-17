import numpy as np
import matplotlib.pyplot as plt

# 中文字体
plt.rcParams['font.sans-serif'] = ['Noto Sans CJK JP', 'SimHei', 'Microsoft YaHei']
plt.rcParams['axes.unicode_minus'] = False

# =========================
# 系统参数
# =========================

K = 20
a = 6.32

# 控制器增益
Kp = 20

# 饱和值
umax_list = [2, 5, 10]

# 时间
dt = 0.001
t = np.arange(0, 4, dt)

# 单位阶跃输入
r = 1

# =========================
# 绘图
# =========================

plt.figure(figsize=(10,6), dpi=200)

for umax in umax_list:

    # 状态变量
    x1 = 0
    x2 = 0

    y_history = []

    for _ in t:

        # 输出
        y = x1

        # 误差
        e = r - y

        # 理论控制器输出
        uc = Kp * e

        # 饱和
        u = np.clip(uc, -umax, umax)

        # 状态方程
        dx1 = x2

        dx2 = -a*x2 - 20*x1 + 20*u

        # 欧拉积分
        x1 += dx1 * dt
        x2 += dx2 * dt

        y_history.append(y)

    plt.plot(t, y_history,
             linewidth=2,
             label=f'$u_{{max}}={umax}$V')

# =========================
# 美化
# =========================

plt.grid(True, linestyle='--', alpha=0.45)

plt.title('图3-8 执行器饱和阶跃响应对比图', fontsize=16)

plt.xlabel('时间 t / s', fontsize=12)

plt.ylabel('输出响应 y(t)', fontsize=12)

plt.legend(fontsize=11)

plt.xlim(0,4)

plt.ylim(0,1.5)

plt.tight_layout()

plt.savefig('图3-8_执行器饱和阶跃响应对比图.png', dpi=300)

plt.show()
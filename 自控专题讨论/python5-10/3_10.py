import numpy as np
import matplotlib.pyplot as plt

plt.rcParams['font.sans-serif'] = ['SimHei', 'Microsoft YaHei', 'Noto Sans CJK JP']
plt.rcParams['axes.unicode_minus'] = False

# =====================
# 系统参数
# =====================
K1 = 20
K2 = 0.2165

dt = 0.001
t = np.arange(0, 6, dt)

r = 1.0

# =====================
# 死区函数
# =====================
def dead_zone(u, d):
    if abs(u) < d:
        return 0.0
    elif u >= d:
        return u - d
    else:
        return u + d

# =====================
# 仿真函数
# =====================
def simulate(dead_width=0.0, B=0.0, Fc=0.0):
    y = 0.0
    v = 0.0

    y_list = []

    for _ in t:
        # 误差
        e = r - y

        # 控制器输出：教材中的 K1
        uc = K1 * e

        # 执行机构死区
        u = dead_zone(uc, dead_width)

        # 摩擦项
        if abs(v) < 1e-6:
            friction = 0.0
        else:
            friction = B * v + Fc * np.sign(v)

        u=u-friction
        # 被控对象：1 / [s(s+2)]
        # y'' + 2y' = u - K2*v - friction
        # 测速反馈 K2*s 等价于增加速度负反馈
        dy = v
        dv = -6.32*v +   20*u - 20*y 

        y += dy * dt
        v += dv * dt

        y_list.append(y)

    return np.array(y_list)

# =====================
# 不同非线性情况
# =====================
cases = [
    ('理想线性系统', 0.0, 0.0, 0.0),
    ('仅加入死区 d=1.0', 1.0, 0.0, 0.0),
    ('死区 + 粘性摩擦', 1.0, 1.5, 0.0),
    ('死区 + 粘性摩擦 + 库仑摩擦', 1.0, 1.5, 0.8)
]

plt.figure(figsize=(10, 6), dpi=200)

for name, d, B, Fc in cases:
    y = simulate(d, B, Fc)
    plt.plot(t, y, linewidth=2, label=name)

plt.grid(True, linestyle='--', alpha=0.45)

plt.title('图3-10 死区非线性响应对比图', fontsize=16)
plt.xlabel('时间 t / s', fontsize=12)
plt.ylabel('输出响应 y(t)', fontsize=12)

plt.legend(fontsize=10)
plt.xlim(0, 6)
plt.ylim(0, 1.7)

plt.tight_layout()
plt.savefig('图3-10_死区非线性响应对比图_修正版.png', dpi=300)
plt.show()
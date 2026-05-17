import numpy as np
import matplotlib.pyplot as plt
from scipy import signal

plt.rcParams['font.sans-serif'] = ['Noto Sans CJK JP', 'SimHei', 'Microsoft YaHei']
plt.rcParams['axes.unicode_minus'] = False

# =====================
# 1. 时间与真实输出信号
# =====================
t = np.linspace(0, 5, 3000)

# 真实输出，可理解为理想焊接头位置信号
y_true = 1 - np.exp(-2.2 * t)

# 传感器噪声：随机噪声 + 高频周期噪声
np.random.seed(2)
noise = 0.06 * np.random.randn(len(t)) + 0.04 * np.sin(90 * t)

# 含噪测量信号
y_measured = y_true + noise

# 控制器近似：u = Kp(r - y_m)
Kp = 8
r = np.ones_like(t)

# 不滤波时控制信号
u_raw = Kp * (r - y_measured)

# =====================
# 2. 不同低通滤波时间常数
# =====================
Tf_list = [0.01, 0.05, 0.10]

filtered_signals = {}
control_signals = {}

for Tf in Tf_list:
    F = signal.TransferFunction([1], [Tf, 1])
    _, y_f, _ = signal.lsim(F, U=y_measured, T=t)

    filtered_signals[Tf] = y_f
    control_signals[Tf] = Kp * (r - y_f)

# =====================
# 3. 绘图：单图
# =====================
fig, ax = plt.subplots(1, 1, figsize=(6.6, 5.5), dpi=200)

ax.plot(t, y_measured, linewidth=0.5, alpha=0.18, label='含噪测量信号')
ax.plot(t, y_true, linewidth=1.6, label='真实输出信号')

filter_colors = ['#e41a1c', '#377eb8', '#4daf4a']
for Tf, color in zip(Tf_list, filter_colors):
    ax.plot(t, filtered_signals[Tf], linewidth=1.4, color=color,
            label=f'低通滤波 $T_f={Tf}$s')

ax.set_title('传感器噪声低通滤波效果')
ax.set_xlabel('时间 t / s')
ax.set_ylabel('测量输出 $y_m(t)$')
ax.grid(True, linestyle='--', alpha=0.45)
ax.legend(fontsize=9)

plt.title('图3-9 传感器噪声低通滤波对比图', fontsize=16)
plt.tight_layout()
plt.savefig('图3-9_传感器噪声低通滤波对比图_高级版.png', dpi=300)
plt.show()
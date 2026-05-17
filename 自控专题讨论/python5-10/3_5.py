import numpy as np
import matplotlib.pyplot as plt
from scipy import signal

# 设置中文字体
plt.rcParams['font.sans-serif'] = ['Noto Sans CJK JP', 'SimHei', 'Microsoft YaHei']
plt.rcParams['axes.unicode_minus'] = False

# =====================
# 1. 系统参数
# =====================
K1 = 20
K2 = 0.2165

a = 2 + K1 * K2

# 扰动到输出偏差传递函数：
# Cd(s) / D(s) = 1 / [s^2 + (2+K1K2)s + K1]
num = [1]
den = [1, a, K1]

sys_d = signal.TransferFunction(num, den)

# =====================
# 2. 时间与扰动输入
# =====================
t = np.linspace(0, 8, 1600)

D0 = 1.0
A = 1.0
omega = 3.0

d_step = D0 * np.ones_like(t)      # 阶跃扰动
d_ramp = D0 * t                    # 斜坡扰动
d_sin = A * np.sin(omega * t)      # 正弦扰动

# =====================
# 3. 仿真响应
# =====================
_, y_step, _ = signal.lsim(sys_d, U=d_step, T=t)
_, y_ramp, _ = signal.lsim(sys_d, U=d_ramp, T=t)
_, y_sin, _ = signal.lsim(sys_d, U=d_sin, T=t)

# =====================
# 4. 绘图
# =====================
plt.figure(figsize=(10, 5.6), dpi=200)

plt.plot(t, y_step, linewidth=2.2, label='阶跃扰动')
plt.plot(t, y_ramp, linewidth=2.2, label='斜坡扰动')
plt.plot(t, y_sin, linewidth=2.2, label='正弦扰动')

plt.axhline(0, linewidth=1.0, linestyle='--')
plt.grid(True, linestyle='--', alpha=0.45)
plt.xlim(0, 3)
plt.ylim(-0.1, 0.15)

plt.title('图5 不同扰动输入下输出响应对比图', fontsize=15)
plt.xlabel('时间 t / s', fontsize=12)
plt.ylabel('输出偏差 $C_d(t)$', fontsize=12)

plt.legend(fontsize=11, loc='upper left')

plt.tight_layout()
plt.savefig('图5_不同扰动输入下输出响应对比图.png', dpi=300)
plt.show()
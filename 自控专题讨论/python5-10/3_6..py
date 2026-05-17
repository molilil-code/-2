import numpy as np
import matplotlib.pyplot as plt

# 中文字体
plt.rcParams['font.sans-serif'] = ['Noto Sans CJK JP', 'SimHei', 'Microsoft YaHei']
plt.rcParams['axes.unicode_minus'] = False

# 基础参数
K1_base = 20
K2_base = 0.2165

# 参数摄动组合
cases = [
    (20, 0.2165, '标称参数'),
    (16, 0.2165, 'K1 -20%'),
    (24, 0.2165, 'K1 +20%'),
    (20, 0.1732, 'K2 -20%'),
    (20, 0.2598, 'K2 +20%'),
    (24, 0.1732, 'K1 +20%, K2 -20%'),
    (16, 0.2598, 'K1 -20%, K2 +20%')
]

plt.figure(figsize=(8, 6), dpi=200)

for K1, K2, label in cases:
    # 特征方程：s^2 + (2+K1K2)s + K1 = 0
    coeff = [1, 2 + K1*K2, K1]
    poles = np.roots(coeff)

    plt.scatter(np.real(poles), np.imag(poles), s=70, label=label)

# 坐标轴
plt.axhline(0, color='black', linewidth=1)
plt.axvline(0, color='black', linewidth=1)

# 阻尼比 ζ=0.707 参考线，约为 ±45°
x = np.linspace(-6, 0, 200)
plt.plot(x, -x, 'k--', linewidth=1, alpha=0.6)
plt.plot(x, x, 'k--', linewidth=1, alpha=0.6)

# 调节时间约束 σ=1.47
plt.axvline(-1.47, color='gray', linestyle='--', linewidth=1.2)

plt.grid(True, linestyle='--', alpha=0.45)

plt.title('图3-6 参数摄动极点分布图', fontsize=15)
plt.xlabel('实轴 Re(s)', fontsize=12)
plt.ylabel('虚轴 Im(s)', fontsize=12)

plt.xlim(-6, 1)
plt.ylim(-5, 5)

plt.legend(fontsize=8, loc='best')

plt.tight_layout()
plt.savefig('图3-6_参数摄动极点分布图.png', dpi=300)
plt.show()
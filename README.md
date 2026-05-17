## Change Notes

- 1_5 的理论框图把饱和、摩擦、噪声放在同一图中，仿真则分别单独处理。原 1_5 分析不包含低通滤波、测量噪声和扰动，仅分析三种非线性单独作用。
- 3_3 稳态误差分析采用斜坡输入，并拆分为两幅图。
- 3_8 与 3_10 采用方案一参数：K1 = 20，K2 = 0.2165。
- 仿真结果与原报告结论可能不一致，详见 `饱和环节3_8.md` 与 `死区非线性3_10.md`，注意修改。

# Control System Study Notes

This repository contains MATLAB and Python scripts, figures, and notes for a control systems study topic. It includes simulations for saturation, sensor noise filtering, dead-zone and friction nonlinearities, and parameter robustness.

## Contents

- `matlab/`: MATLAB scripts for root locus, step response, and tracking error.
- `python5-10/`: Python scripts used for plots and simulations (if applicable).
- `result/`: Generated figures or outputs.
- `理论框图/`: Block diagram assets.
- `3_8.py`, `3_9.py`, `3_10.py`: Python simulation scripts for figures.
- `3-11综合性能指标对比表.md`: Summary table of performance metrics.
- `死区非线性3_10.md`, `饱和环节3_8.md`: Notes for specific figures.
- `自动焊接头控制系统根轨迹法设计与综合分析_文字插图占位版.pdf`: Reference document.

## Requirements

- Python 3.10+ with `numpy`, `matplotlib`, and `scipy` installed
- MATLAB (for scripts in `matlab/`)

## Run (Python)

From the repo root:

```
python 3_8.py
python 3_9.py
python 3_10.py
```

Figures are saved to the current directory or `result/` depending on the script.

## Notes

- Some scripts include nonlinearity models (dead-zone, friction) and actuator saturation.
- Adjust parameters inside each script to match your report settings.


# The logistic road to chaos

[![The logistic road to chaos by tecer](https://img.youtube.com/vi/ZzALMv_4SjA/0.jpg)](https://www.youtube.com/watch?v=ZzALMv_4SjA)

A 128b intro for the Atari ST/E in 640x200 color mode.

It shows a plot of the [logistic map](https://en.wikipedia.org/wiki/Logistic_map) by iterating `x_{n+1} = r*x_n*(1-x_n)` a few times and then plotting `x_n` for a number of iterations. The parameter values of `r` are varied from `r=2.8` to `r=4`, showing the period doubling cascade, some of the "windows" and the chaotic regime.

The challenge is to compute all that without the possibility of floating point operations on the CPU (and no FPU!).
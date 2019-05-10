import numpy as np

def trigger_downsample(x, r, phase):
    for i in range(phase + r, len(x), r):
        if i == phase + r:
            y = np.sum(x[(i-r):i])
        else:
            y = np.append(y, np.sum(x[(i-r):i]))
    return y
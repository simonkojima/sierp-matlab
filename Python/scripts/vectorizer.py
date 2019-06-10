import numpy as np

Data = np.array([[[1,2,3,4,5],[6,7,8,9,10],[11,12,13,14,15]],[[1,2,3,4,5],[6,7,8,9,10],[11,12,13,14,15]]])
Data = Data.transpose((1,2,0))
#print(Data.shape)

temp = [0]*Data.shape[2]
for i in range(Data.shape[2]):
    temp[i] = np.array([]);
    for j in range(Data.shape[0]):
        temp[i] = np.append(temp[i],Data[j,:,i])
        
vec = temp[0]
for i in range(1,Data.shape[2]):
    vec = np.vstack((vec,temp[i]));
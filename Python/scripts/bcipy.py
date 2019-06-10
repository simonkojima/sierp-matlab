import numpy as np

def trigger_downsample(x, r, phase):
    for i in range(phase + r, len(x), r):
        if i == phase + r:
            y = np.sum(x[(i-r):i])
        else:
            y = np.append(y, np.sum(x[(i-r):i]))
    return y

def CSP(Vt,Vnt):
    Ra = np.zeros((Vt.shape[0],Vt.shape[0],Vt.shape[2]))
    Rb = np.zeros((Vnt.shape[0],Vnt.shape[0],Vnt.shape[2]))
    
    for i in range(Vt.shape[2]):
        Ra[:,:,i] = np.dot(Vt[:,:,i],Vt[:,:,i].transpose())/np.trace(np.dot(Vt[:,:,i],Vt[:,:,i].transpose()))
        Rb[:,:,i] = np.dot(Vnt[:,:,i],Vnt[:,:,i].transpose())/np.trace(np.dot(Vnt[:,:,i],Vnt[:,:,i].transpose()))
    
    Ra = np.mean(Ra,axis=2)
    Rb = np.mean(Rb,axis=2)
    
    Rc = Ra + Rb
    
    Lambda,Bc = np.linalg.eig(Rc)
    Lambda = np.diag(Lambda)
    
    W = np.dot(np.sqrt(np.linalg.inv(Lambda)),Bc.transpose())
    
    Sa = np.dot(W,Ra)
    Sa = np.dot(Ra,np.linalg.inv(W))
    
    U,S,V = np.linalg.svd(Sa)
    
    H = np.dot(V.transpose(),W)
    
    return H

def Vectorizer(Data):
    temp = [0]*Data.shape[2]
    for i in range(Data.shape[2]):
        temp[i] = np.array([]);
        for j in range(Data.shape[0]):
            temp[i] = np.append(temp[i],Data[j,:,i])
            
    vec = temp[0]
    for i in range(1,Data.shape[2]):
        vec = np.vstack((vec,temp[i]));
    return vec
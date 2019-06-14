import pickle
import numpy as np
import bcipy as bci
from scipy import io
from sklearn.discriminant_analysis import LinearDiscriminantAnalysis

Directory = "/home/simon/Documents/MATLAB/20181206_B33_Stream/"
SaveFileName = ["LowStream","MidStream","HighStream"]


with open(Directory+SaveFileName[0],'rb') as web:
        LoadData = pickle.load(web)
Stream = [LoadData["EpochData"]]

with open(Directory+SaveFileName[1],'rb') as web:
        LoadData = pickle.load(web)
Stream.append(LoadData["EpochData"])

with open(Directory+SaveFileName[2],'rb') as web:
        LoadData = pickle.load(web)
Stream.append(LoadData["EpochData"])

NumStream = len(Stream)

#
#   Stream[AttendedStreamNumber][Deviant][Ch][Time][Epoch]
#

SimulatingFile = "20181206_B33_Stream_0001_Processed.mat"
CorrectClass = 3

SelectedTrigger = np.array([2, 8, 32])

TimeRange = np.array([-0.1, 0.5])
BaseLineRange = np.array([-0.05, 0])

SimulatingRange = np.array([10])

temp = [0,1,2,0,1]

H = [0]*NumStream
for Deviant in range(NumStream):
    Target = Stream[Deviant][Deviant]
    NonTarget = np.concatenate([Stream[temp[Deviant+1]][Deviant][:,:,:],Stream[temp[Deviant+2]][Deviant][:,:,:]],2)
    H[Deviant] = bci.CSP(Target,NonTarget)
del temp


CSPData = [0]*NumStream
for Attended in range(NumStream):
    CSPData[Attended] = [0]*NumStream
    for Deviant in range(NumStream):
        CSPData[Attended][Deviant] = np.zeros(Stream[Attended][Deviant].shape)
        for i in range(Stream[Attended][Deviant].shape[2]):
            CSPData[Attended][Deviant][:,:,i] = np.dot(H[Deviant],Stream[Attended][Deviant][:,:,i])

#for i in range(3):
    #print(CSPData[i][2].shape)
    #print((bci.Vectorizer(CSPData[i][2])).shape)

TrainingDataX = [0]*NumStream
TrainingDataY = [0]*NumStream
for Deviant in range(NumStream):
    TrainingDataX[Deviant] = bci.Vectorizer(CSPData[0][Deviant])
    for Attended in range(1,NumStream):
        TrainingDataX[Deviant] = np.vstack((TrainingDataX[Deviant],bci.Vectorizer(CSPData[Attended][Deviant])))
        
for Deviant in range(NumStream):
    for Attended in range(NumStream):
        if Deviant == Attended:
            if Attended == 0:
                TrainingDataY[Deviant] = np.ones((bci.Vectorizer(CSPData[Attended][Deviant])).shape[0])
            else:
                TrainingDataY[Deviant] = np.append(TrainingDataY[Deviant],np.ones((bci.Vectorizer(CSPData[Attended][Deviant])).shape[0]))
        else:
            if Attended == 0:
                TrainingDataY[Deviant] = np.zeros((bci.Vectorizer(CSPData[Attended][Deviant])).shape[0])
            else:
                TrainingDataY[Deviant] = np.append(TrainingDataY[Deviant],np.zeros((bci.Vectorizer(CSPData[Attended][Deviant])).shape[0]))

#print(TrainingDataX[2].shape)
#print(TrainingDataY[2].shape)

clf = [0]*NumStream
for Deviant in range(NumStream):
    clf[Deviant] = LinearDiscriminantAnalysis()
    clf[Deviant].fit(TrainingDataX[Deviant],TrainingDataY[Deviant])

matdata = io.loadmat(Directory + SimulatingFile, squeeze_me=True)
        
Data = matdata["Data"]
Fs = matdata["Fs"]
Trigger = matdata["Trigger"]
Label = matdata["Label"]

for i in range(Trigger.shape[0]):
    if Trigger[i] != 0:
        FirstTrigger = np.array([i])
        break
    
EpochData = [0]*NumStream
BaseLine = [0]*NumStream
for i in range((FirstTrigger-Fs)[0],Data.shape[1],(SimulatingRange*Fs)[0]):
    #print(i)
    
    IntervalData = Data[:,(i-Fs):((i+(SimulatingRange*Fs)[0])+Fs)]
    IntervalTrigger = np.hstack((np.hstack((np.zeros(Fs),Trigger[i:(i+(SimulatingRange*Fs)[0])])),np.zeros(Fs)))
    
    for j in range(NumStream):
        EpochData[j] = bci.Epoch(IntervalData,IntervalTrigger,TimeRange,SelectedTrigger[j],Fs)
        BaseLine[j] = bci.BaseLine(IntervalData,IntervalTrigger,BaseLineRange,SelectedTrigger[j],Fs)
        EpochData[j] = EpochData[j] - BaseLine[j]
        
    FilteredEpochData = [0]*NumStream
    Res = [0]*NumStream
    Score = [0]*NumStream
    for j in range(NumStream):
        FilteredEpochData[j] = np.zeros(EpochData[j].shape)
        for k in range(EpochData[j].shape[2]):
            FilteredEpochData[j][:,:,k] = np.dot(H[j],EpochData[j][:,:,k])
            
        FeatureVector = bci.Vectorizer(FilteredEpochData[j])
        
        if FilteredEpochData[j].shape[2] > 1:
            Res[j] = clf[j].predict_proba([FeatureVector[0,:]])
            for k in range(1,FilteredEpochData[j].shape[2]):
                Res[j] = np.vstack((Res[j],clf[j].predict_proba([FeatureVector[k,:]])))
        else:
            Res[j] = clf[j].predict_proba([FeatureVector])
            
        Score[j] = np.mean(Res[j][:,1],axis=0)
        I = np.argmax(Score,axis=0)
        #I.append(np.argmax(Score,axis=0))
    
    #print(Score)
    print(str(I+1))
    
















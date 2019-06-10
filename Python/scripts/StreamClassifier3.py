import pickle
import numpy as np
import bcipy as bci

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

SelectedTrigger = np.array([2, 4, 8])

TimeRange = np.array([-0.1, 0.5])
BaseLineRange = np.array([-0.05, 0])

SimulatingRange = np.array([0,10])

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

for Deviant in range(NumStream):
    TrainingDataX = bci.Vectorizer(CSPData[0][0])
    for Attended in range(NumStream):
        #TrainingDataX = bci.Vectorizer(CSPData[Attended][Deviant])
        TrainingDataX = np.vstack((TrainingDataX,bci.Vectorizer(CSPData[Attended][Deviant])))



























import mne
import numpy as np
from mne.io import read_raw_brainvision

Directory = "c:/Users/KOJIMA/Documents/MATLAB/20181206_B33_Stream/"
PreFileName = Directory + "20181206_B33_Stream_"

vhdr_file = PreFileName + "0001.vhdr"

raw = read_raw_brainvision(vhdr_file)
#info = raw.info
Label = raw.ch_names
Ns = raw.n_times
Time = raw.times
Fs = raw.info['sfreq']
eeg = raw.get_data()

events = mne.events_from_annotations(raw)[0]
events = events[1:-1,:]

Ns = eeg.shape[1]

Trigger = np.zeros(Ns)
for i in range(events.shape[0]):
    Trigger[events[i,0]] = events[i,2]

#del info,raw

#print type(raw)
#for x in dir(raw):
#  print(x)
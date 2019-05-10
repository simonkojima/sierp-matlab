close all
clearvars

%chanlocs = struct('labels', {'fp1' 'fp2' 'af7' 'af3' 'afz' 'af4' 'af8' 'f7'});
chanlocs = struct('labels', {'fp1' 'fp2' 'af7' 'af3' 'afz' 'af4' 'af8' 'f7' 'f5' 'f3' 'f1' 'fz' 'f2' 'f4' 'f6' 'f8' 'ft9' 'ft7' 'fc5' 'fc3' 'fc1' 'fcz' 'fc2' 'fc4' 'fc6' 'ft8' 'ft10' 't7' 'c5' 'c3' 'c1' 'cz' 'c2' 'c4' 'c6' 't8' 'tp9' 'tp7' 'cp5' 'cp3' 'cp1' 'cpz' 'cp2' 'cp4' 'cp6' 'tp8' 'tp10' 'p7' 'p5' 'p3' 'p1' 'pz' 'p2' 'p4' 'p6' 'p8' 'po7' 'po3' 'poz' 'po4' 'po8' 'o1' 'oz' 'o2'});
pop_chanedit(chanlocs);
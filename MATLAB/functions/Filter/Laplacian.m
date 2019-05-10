function lap = Laplacian(Data)

% 1 2 3
%   4
% 5 6 7

% F3 Fz F4
%    Cz
% P5 Pz P6

% 2*F3 - Fz
% 4*Fz - F3 - F4 - Cz
% 2*F4 - Fz
% 3*Cz - Fz - Pz
% 2*P5 - Pz
% 4*Pz - Cz - P5 - P6
% 2*P6 - Pz

[NumSumple,NumCh] = size(Data);
lap = [];

if NumCh ~= 7
   fprintf('Error : Check your Channnel\n') ;
   lap = zeros(size(Data));
   return
end

lap(:,1) = 2.*Data(:,1) - Data(:,2);
lap(:,2) = 4.*Data(:,2) - Data(:,1) - Data(:,3) - Data(:,4);
lap(:,3) = 2.*Data(:,3) - Data(:,2);
lap(:,4) = 3.*Data(:,4) - Data(:,2) - Data(:,6);
lap(:,5) = 2.*Data(:,5) - Data(:,6);
lap(:,6) = 4.*Data(:,6) - Data(:,4) - Data(:,5) - Data(:,7);
lap(:,7) = 2.*Data(:,7) - Data(:,6);

end
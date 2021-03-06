
% Plot TP02 data 
% load TP02_final_2003.txt; TP02_03 = TP02_final_2003; clear TP02_final_2003
% load TP02_final_2004.txt; TP02_04 = TP02_final_2004; clear TP02_final_2004
% load TP02_final_2005.txt; TP02_05 = TP02_final_2005; clear TP02_final_2005
% load TP02_final_2006.txt; TP02_06 = TP02_final_2006; clear TP02_final_2006
% load TP02_final_2007.txt; TP02_07 = TP02_final_2007; clear TP02_final_2007

load TP02_final_2003.dat; TP02_03 = TP02_final_2003; clear TP02_final_2003
load TP02_final_2004.dat; TP02_04 = TP02_final_2004; clear TP02_final_2004
load TP02_final_2005.dat; TP02_05 = TP02_final_2005; clear TP02_final_2005
load TP02_final_2006.dat; TP02_06 = TP02_final_2006; clear TP02_final_2006
load TP02_final_2007.dat; TP02_07 = TP02_final_2007; clear TP02_final_2007

close all;

figure(7);  hold on; plot(TP02_03(:,7),'b');plot(TP02_04(:,7),'r');plot(TP02_05(:,7),'g');plot(TP02_06(:,7),'c');plot(TP02_07(:,7),'m');
figure(8);  hold on; plot(TP02_03(:,8),'b');plot(TP02_04(:,8),'r');plot(TP02_05(:,8),'g');plot(TP02_06(:,8),'c');plot(TP02_07(:,8),'m');
figure(9);  hold on; plot(TP02_03(:,9),'b');plot(TP02_04(:,9),'r');plot(TP02_05(:,9),'g');plot(TP02_06(:,9),'c');plot(TP02_07(:,9),'m');
figure(10); hold on; plot(TP02_03(:,10),'b');plot(TP02_04(:,10),'r');plot(TP02_05(:,10),'g');plot(TP02_06(:,10),'c');plot(TP02_07(:,10),'m');
figure(11); hold on; plot(TP02_03(:,11),'b');plot(TP02_04(:,11),'r');plot(TP02_05(:,11),'g');plot(TP02_06(:,11),'c');plot(TP02_07(:,11),'m');
figure(12); clf; hold on; plot(TP02_03(:,12),'b');plot(TP02_04(:,12),'r');plot(TP02_05(:,12),'g');plot(TP02_06(:,12),'c');plot(TP02_07(:,12),'m');
figure(13); clf; hold on; plot(TP02_03(:,13),'b');plot(TP02_04(:,13),'r');plot(TP02_05(:,13),'g');plot(TP02_06(:,13),'c');plot(TP02_07(:,13),'m');
figure(14); hold on; plot(TP02_03(:,14),'b');plot(TP02_04(:,14),'r');plot(TP02_05(:,14),'g');plot(TP02_06(:,14),'c');plot(TP02_07(:,14),'m');
figure(15); hold on; plot(TP02_03(:,15),'b');plot(TP02_04(:,15),'r');plot(TP02_05(:,15),'g');plot(TP02_06(:,15),'c');plot(TP02_07(:,15),'m');
figure(16); hold on; plot(TP02_03(:,16),'b');plot(TP02_04(:,16),'r');plot(TP02_05(:,16),'g');plot(TP02_06(:,16),'c');plot(TP02_07(:,16),'m');
figure(17); hold on; plot(TP02_03(:,17),'b');plot(TP02_04(:,17),'r');plot(TP02_05(:,17),'g');plot(TP02_06(:,17),'c');plot(TP02_07(:,17),'m');
figure(18); hold on; plot(TP02_03(:,18),'b');plot(TP02_04(:,18),'r');plot(TP02_05(:,18),'g');plot(TP02_06(:,18),'c');plot(TP02_07(:,18),'m');
figure(19); hold on; plot(TP02_03(:,19),'b');plot(TP02_04(:,19),'r');plot(TP02_05(:,19),'g');plot(TP02_06(:,19),'c');plot(TP02_07(:,19),'m');
figure(20); hold on; plot(TP02_03(:,20),'b');plot(TP02_04(:,20),'r');plot(TP02_05(:,20),'g');plot(TP02_06(:,20),'c');plot(TP02_07(:,20),'m');
figure(21); hold on; plot(TP02_03(:,21),'b');plot(TP02_04(:,21),'r');plot(TP02_05(:,21),'g');plot(TP02_06(:,21),'c');plot(TP02_07(:,21),'m');
figure(22); hold on; plot(TP02_03(:,22),'b');plot(TP02_04(:,22),'r');plot(TP02_05(:,22),'g');plot(TP02_06(:,22),'c');plot(TP02_07(:,22),'m');
figure(23); hold on; plot(TP02_03(:,23),'b');plot(TP02_04(:,23),'r');plot(TP02_05(:,23),'g');plot(TP02_06(:,23),'c');plot(TP02_07(:,23),'m');
figure(24); hold on; plot(TP02_03(:,24),'b');plot(TP02_04(:,24),'r');plot(TP02_05(:,24),'g');plot(TP02_06(:,24),'c');plot(TP02_07(:,24),'m');
figure(25); hold on; plot(TP02_03(:,25),'b');plot(TP02_04(:,25),'r');plot(TP02_05(:,25),'g');plot(TP02_06(:,25),'c');plot(TP02_07(:,25),'m');
figure(26); hold on; plot(TP02_03(:,26),'b');plot(TP02_04(:,26),'r');plot(TP02_05(:,26),'g');plot(TP02_06(:,26),'c');plot(TP02_07(:,26),'m');
figure(27); hold on; plot(TP02_03(:,27),'b');plot(TP02_04(:,27),'r');plot(TP02_05(:,27),'g');plot(TP02_06(:,27),'c');plot(TP02_07(:,27),'m');
figure(28); hold on; plot(TP02_03(:,28),'b');plot(TP02_04(:,28),'r');plot(TP02_05(:,28),'g');plot(TP02_06(:,28),'c');plot(TP02_07(:,28),'m');
figure(29); hold on; plot(TP02_03(:,29),'b');plot(TP02_04(:,29),'r');plot(TP02_05(:,29),'g');plot(TP02_06(:,29),'c');plot(TP02_07(:,29),'m');
figure(30); hold on; plot(TP02_03(:,30),'b');plot(TP02_04(:,30),'r');plot(TP02_05(:,30),'g');plot(TP02_06(:,30),'c');plot(TP02_07(:,30),'m');
figure(31); hold on; plot(TP02_03(:,31),'b');plot(TP02_04(:,31),'r');plot(TP02_05(:,31),'g');plot(TP02_06(:,31),'c');plot(TP02_07(:,31),'m');
figure(32); hold on; plot(TP02_03(:,32),'b');plot(TP02_04(:,32),'r');plot(TP02_05(:,32),'g');plot(TP02_06(:,32),'c');plot(TP02_07(:,32),'m');
figure(33); hold on; plot(TP02_03(:,33),'b');plot(TP02_04(:,33),'r');plot(TP02_05(:,33),'g');plot(TP02_06(:,33),'c');plot(TP02_07(:,33),'m');
figure(34); hold on; plot(TP02_03(:,34),'b');plot(TP02_04(:,34),'r');plot(TP02_05(:,34),'g');plot(TP02_06(:,34),'c');plot(TP02_07(:,34),'m');
figure(35); hold on; plot(TP02_03(:,35),'b');plot(TP02_04(:,35),'r');plot(TP02_05(:,35),'g');plot(TP02_06(:,35),'c');plot(TP02_07(:,35),'m');
figure(36); hold on; plot(TP02_03(:,36),'b');plot(TP02_04(:,36),'r');plot(TP02_05(:,36),'g');plot(TP02_06(:,36),'c');plot(TP02_07(:,36),'m');
figure(37); hold on; plot(TP02_03(:,37),'b');plot(TP02_04(:,37),'r');plot(TP02_05(:,37),'g');plot(TP02_06(:,37),'c');plot(TP02_07(:,37),'m');
figure(38); hold on; plot(TP02_03(:,38),'b');plot(TP02_04(:,38),'r');plot(TP02_05(:,38),'g');plot(TP02_06(:,38),'c');plot(TP02_07(:,38),'m');
figure(39); hold on; plot(TP02_03(:,39),'b');plot(TP02_04(:,39),'r');plot(TP02_05(:,39),'g');plot(TP02_06(:,39),'c');plot(TP02_07(:,39),'m');
figure(40); hold on; plot(TP02_03(:,40),'b');plot(TP02_04(:,40),'r');plot(TP02_05(:,40),'g');plot(TP02_06(:,40),'c');plot(TP02_07(:,40),'m');
figure(41); hold on; plot(TP02_03(:,41),'b');plot(TP02_04(:,41),'r');plot(TP02_05(:,41),'g');plot(TP02_06(:,41),'c');plot(TP02_07(:,41),'m');
figure(42); hold on; plot(TP02_03(:,42),'b');plot(TP02_04(:,42),'r');plot(TP02_05(:,42),'g');plot(TP02_06(:,42),'c');plot(TP02_07(:,42),'m');
figure(43); hold on; plot(TP02_03(:,43),'b');plot(TP02_04(:,43),'r');plot(TP02_05(:,43),'g');plot(TP02_06(:,43),'c');plot(TP02_07(:,43),'m');
figure(44); hold on; plot(TP02_03(:,44),'b');plot(TP02_04(:,44),'r');plot(TP02_05(:,44),'g');plot(TP02_06(:,44),'c');plot(TP02_07(:,44),'m');
figure(45); hold on; plot(TP02_03(:,45),'b');plot(TP02_04(:,45),'r');plot(TP02_05(:,45),'g');plot(TP02_06(:,45),'c');plot(TP02_07(:,45),'m');
figure(46); hold on; plot(TP02_03(:,46),'b');plot(TP02_04(:,46),'r');plot(TP02_05(:,46),'g');plot(TP02_06(:,46),'c');plot(TP02_07(:,46),'m');
figure(47); hold on; plot(TP02_03(:,47),'b');plot(TP02_04(:,47),'r');plot(TP02_05(:,47),'g');plot(TP02_06(:,47),'c');plot(TP02_07(:,47),'m');
figure(48); hold on; plot(TP02_03(:,48),'b');plot(TP02_04(:,48),'r');plot(TP02_05(:,48),'g');plot(TP02_06(:,48),'c');plot(TP02_07(:,48),'m');
figure(49); hold on; plot(TP02_03(:,49),'b');plot(TP02_04(:,49),'r');plot(TP02_05(:,49),'g');plot(TP02_06(:,49),'c');plot(TP02_07(:,49),'m');
figure(50); hold on; plot(TP02_03(:,50),'b');plot(TP02_04(:,50),'r');plot(TP02_05(:,50),'g');plot(TP02_06(:,50),'c');plot(TP02_07(:,50),'m');
figure(51); hold on; plot(TP02_03(:,51),'b');plot(TP02_04(:,51),'r');plot(TP02_05(:,51),'g');plot(TP02_06(:,51),'c');plot(TP02_07(:,51),'m');
figure(52); hold on; plot(TP02_03(:,52),'b');plot(TP02_04(:,52),'r');plot(TP02_05(:,52),'g');plot(TP02_06(:,52),'c');plot(TP02_07(:,52),'m');
figure(53); hold on; plot(TP02_03(:,53),'b');plot(TP02_04(:,53),'r');plot(TP02_05(:,53),'g');plot(TP02_06(:,53),'c');plot(TP02_07(:,53),'m');
figure(54); hold on; plot(TP02_03(:,54),'b');plot(TP02_04(:,54),'r');plot(TP02_05(:,54),'g');plot(TP02_06(:,54),'c');plot(TP02_07(:,54),'m');
figure(55); hold on; plot(TP02_03(:,55),'b');plot(TP02_04(:,55),'r');plot(TP02_05(:,55),'g');plot(TP02_06(:,55),'c');plot(TP02_07(:,55),'m');
figure(56); hold on; plot(TP02_03(:,56),'b');plot(TP02_04(:,56),'r');plot(TP02_05(:,56),'g');plot(TP02_06(:,56),'c');plot(TP02_07(:,56),'m');
figure(57); hold on; plot(TP02_03(:,57),'b');plot(TP02_04(:,57),'r');plot(TP02_05(:,57),'g');plot(TP02_06(:,57),'c');plot(TP02_07(:,57),'m');
figure(58); hold on; plot(TP02_03(:,58),'b');plot(TP02_04(:,58),'r');plot(TP02_05(:,58),'g');plot(TP02_06(:,58),'c');plot(TP02_07(:,58),'m');
figure(59); hold on; plot(TP02_03(:,59),'b');plot(TP02_04(:,59),'r');plot(TP02_05(:,59),'g');plot(TP02_06(:,59),'c');plot(TP02_07(:,59),'m');

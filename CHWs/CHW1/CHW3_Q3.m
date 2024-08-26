clc;
clear;
close all;
N_send = 500; % number of signals to be sent
SNR = -15; % Signal-to-Noise Ratio
t = linspace(0, 0.001,505e4); % We should change the vlaue of sampling
fc1 = 99e6; % binary 1
fc2 = 101e6; % binary 0
MiddlePoint = 2525e3; % The diagnosing point
N_IsNotReceived = 0; % number of signals not received correctly
%Designed with cutoff frequencies of 100 MHz and 102 MHz
BandPassFilter1 = designfilt('bandpassfir','FilterOrder',2000, ...
         'CutoffFrequency1',100e6,'CutoffFrequency2',102e6, ...
         'SampleRate',505e7);
     fvtool(BandPassFilter1); %Visualize the frequency response of the designed filters
%Designed with cutoff frequencies of 98 MHz and 100 MHz     
BandPassFilter2 = designfilt('bandpassfir','FilterOrder',2000, ...
         'CutoffFrequency1',98e6,'CutoffFrequency2',100e6, ...
         'SampleRate',505e7);
     fvtool(BandPassFilter2); 
for i = 1:N_send
    m = randi([0,1],1,1);
    if ( m == 0)
        x = cos(2*pi*fc2*t);
    else
        x = cos(2*pi*fc1*t);
    end

    x_l = awgn( x , SNR); %Add white Gaussian noise
%{    
    figure;
    plot(t,x_l);
    title("After Channel");
%}
    x_0 = fftfilt(BandPassFilter1,x_l);
    x_1 = fftfilt(BandPassFilter2,x_l);
%{    
    figure;
    subplot(2, 2, 1)
    plot(t,x_0);
    title("after 101MHz filter");
    subplot(2, 2, 2)
    plot(t,x_1);
    title("after 99MHz filter");
    subplot(2, 2, 3)
    plot(t,envelope(x_0));
    title("enve x_0");
    subplot(2, 2, 4)
    plot(t,envelope(x_1));
    title("enve x_1");
%}
    disp("mean(enve(x_0)) = ") ;
    disp(mean(envelope(x_0)));
    disp("mean(enve(x_1)) = ") ;
    disp(mean(envelope(x_1)));
    e0 = envelope(x_0);
    e1 = envelope(x_1);
    if(e0(MiddlePoint)>e1(MiddlePoint))
        m_received = 0;
    else
        m_received = 1;
    end
    if(m_received == m)
         disp("received");
    else
         disp(" not received");
        N_IsNotReceived = N_IsNotReceived +1;
    end
end
figure;
subplot(1, 2, 1)
plot(t,x_l);
title("x_1");
subplot(1, 2, 2)
plot(t,x_0);
title("x_0");
bitErrorRate = N_IsNotReceived/N_send;
disp( "SNR = ");
disp(SNR);
disp("bit Error Rate = ");
disp(bitErrorRate);
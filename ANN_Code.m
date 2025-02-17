% Solve an Input-Output Fitting problem with a Neural Network
% Script generated by Neural Fitting app
% Created 27-Apr-2022 14:45:20
%
% This script assumes these variables are defined:
%
%   input - input data.
%   output - target data.
i =1;
for index =1:1:100
    load ([ 'ResultsHPC=' num2str(index)])
    input (1,i:1:i+12) = hrms ;
    input (2,i) = W1(1);
    input (2,i +1) = W1(2);
    input (2 , i +2) = W1(3);
    input (2 , i +3) = W1(4);
    input (2 , i +4) = W1(5);
    input (2 , i +5) = W1(6);
    input (2 , i +6) = W1(7);
    input (2 , i +7) = W1(8);
    input (2 , i +8) = W1(9);
    input (2 , i +9) = W1(10);
    input (2 , i +10) = W1(11);
    input (2 , i +11) = W1(12);
    input (2 , i +12) = W1(13);
    i = i +13;
    end
    save ( 'Input_W','input','-v7.3')

i =1;
for index =1:1:100
    load (['ResultsHPC=' num2str(index)])
    output (1 , i ) = preD(1);
    output (1 , i +1) = preD(2);
    output (1 , i +2) = preD(3);
    output (1 , i +3) = preD(4);
    output (1 , i +4) = preD(5);
    output (1 , i +5) = preD(6);
    output (1 , i +6) = preD(7);
    output (1 , i +7) = preD(8);
    output (1 , i +8) = preD(9);
    output (1 , i +9) = preD(10);
    output (1 , i +10) = preD(11);
    output (1 , i +11) = preD(12);
    output (1 , i +12) = preD(13);
    output (2 , i ) = sepD(1);
    output (2 , i +1) = sepD(2);
    output (2 , i +2) = sepD(3);
    output (2 , i +3) = sepD(4);
    output (2 , i +4) = sepD(5);
    output (2 , i +5) = sepD(6);
    output (2 , i +6) = sepD(7);
    output (2 , i +7) = sepD(8);
    output (2 , i +8) = sepD(9);
    output (2 , i +9) = sepD(10);
    output (2 , i +10) = sepD(11);
    output (2 , i +11) = sepD(12);
    output (2 , i +12) = sepD(13);
    output (3 , i ) = Contact_ratio(1);
    output (3 , i +1) = Contact_ratio(2);
    output (3 , i +2) = Contact_ratio(3);
    output (3 , i +3) = Contact_ratio(4);
    output (3 , i +4) = Contact_ratio(5);
    output (3 , i +5) = Contact_ratio(6);
    output (3 , i +6) = Contact_ratio(7);
    output (3 , i +7) = Contact_ratio(8);
    output (3 , i +8) = Contact_ratio(9);
    output (3 , i +9) = Contact_ratio(10);
    output (3 , i +10) = Contact_ratio(11);
    output (3 , i +11) = Contact_ratio(12);
    output (3 , i +12) = Contact_ratio(13);
    i = i +13;
    end
    save ( 'Output _W', 'output' , '-v7.3')
x = input;
t = output;

% Choose a Training Function
% For a list of all training functions type: help nntrain
% 'trainlm' is usually fastest.
% 'trainbr' takes longer but may be better for challenging problems.
% 'trainscg' uses less memory. Suitable in low memory situations.
trainFcn = 'trainlm';  % Levenberg-Marquardt backpropagation.

% Create a Fitting Network
hiddenLayerSize = 10;
net = fitnet(hiddenLayerSize,trainFcn);

% Setup Division of Data for Training, Validation, Testing
net.divideParam.trainRatio = 70/100;
net.divideParam.valRatio = 15/100;
net.divideParam.testRatio = 15/100;

% Train the Network
[net,tr] = train(net,x,t);

% Test the Network
y = net(x);
e = gsubtract(t,y);
performance = perform(net,t,y)

% View the Network
view(net)

% Plots
% Uncomment these lines to enable various plots.
%figure, plotperform(tr)
%figure, plottrainstate(tr)
%figure, ploterrhist(e)
%figure, plotregression(t,y)
%figure, plotfit(net,x,t)

% Save the trained network
save('Trained_Net', 'net');

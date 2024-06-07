% Initialize variables to store data from all files
X_all = []; % Features
y_all = []; % Response variables (Contact ratio, Pressure, Separation)

% Iterate over each file
for i = 1:500
    % Load data from the file
    file_name = ['ResultsHPC=' num2str(i) '.mat'];
    load(file_name);
    
    % Concatenate features and response variables
    X = [H, E, pr, qr];
    y = [Contact_ratio, Pressure, Separation];
    
    % Append data to X_all and y_all
    X_all = [X_all; X];
    y_all = [y_all; y];
end

% Split the combined data into training and testing sets (80% train, 20% test)
rng(1); % For reproducibility
cv = cvpartition(size(X_all, 1), 'Holdout', 0.2);
idxTrain = training(cv); % Logical indices for the training set
idxTest = test(cv); % Logical indices for the test set

% Prepare the data
X_train = X_all(idxTrain,:)'; % Features for training (transpose for network compatibility)
X_test = X_all(idxTest,:)'; % Features for testing (transpose for network compatibility)

% Select response variables using logical indices for training and testing sets
y_train = y_all(idxTrain,:); % Response variables for training
y_test = y_all(idxTest,:); % Response variables for testing

% Define the architecture of the neural network
hiddenLayerSize = 10; % Number of neurons in the hidden layer

% Create a feedforward neural network with multiple outputs
net = feedforwardnet(hiddenLayerSize);

% Set up the training parameters
net.trainParam.showWindow = false; % Do not show training window
net.trainParam.showCommandLine = true; % Show training progress in command line

% Train the neural network
net = train(net, X_train, y_train');

% Predict the response for the test data
yPred = net(X_test);

% Predict the response for the test data
yPred_contact_ratio = yPred(1,:);
yPred_pressure = yPred(2,:);
yPred_separation = yPred(3,:);

% Evaluate the performance of the model
RMSE_contact_ratio = sqrt(mean((yPred_contact_ratio - y_test(:,1)').^2));
MAE_contact_ratio = mean(abs(yPred_contact_ratio - y_test(:,1)'));

RMSE_pressure = sqrt(mean((yPred_pressure - y_test(:,2)').^2));
MAE_pressure = mean(abs(yPred_pressure - y_test(:,2)'));
 
RMSE_separation = sqrt(mean((yPred_separation - y_test(:,3)').^2));
MAE_separation = mean(abs(yPred_separation - y_test(:,3)'));
 
disp(['Contact Ratio - RMSE: ' num2str(RMSE_contact_ratio) ', MAE: ' num2str(MAE_contact_ratio)]);
disp(['Pressure - RMSE: ' num2str(RMSE_pressure) ', MAE: ' num2str(MAE_pressure)]);
disp(['Separation - RMSE: ' num2str(RMSE_separation) ', MAE: ' num2str(MAE_separation)]);

% Plot the actual vs. predicted values
figure;
subplot(1,3,1);
scatter(y_test(:,1), yPred_contact_ratio);
hold on;
plot(y_test(:,1), y_test(:,1), 'r--'); % Diagonal line for perfect predictions
hold off;
xlabel('Actual Contact Ratio');
ylabel('Predicted Contact Ratio');
title('Contact Ratio: Actual vs. Predicted');

subplot(1,3,2);
scatter(y_test(:,2), yPred_pressure);
hold on;
plot(y_test(:,2), y_test(:,2), 'r--'); % Diagonal line for perfect predictions
hold off;
xlabel('Actual Pressure');
ylabel('Predicted Pressure');
title('Pressure: Actual vs. Predicted');

subplot(1,3,3);
scatter(y_test(:,3), yPred_separation);
hold on;
plot(y_test(:,3), y_test(:,3), 'r--'); % Diagonal line for perfect predictions
hold off;
xlabel('Actual Separation');
ylabel('Predicted Separation');
title('Separation: Actual vs. Predicted');

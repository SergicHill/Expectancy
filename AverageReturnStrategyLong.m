% Author: Serguey
% This version: November 2015
% Key concept:
% Input:
% 		 data - output of the file LoadData.m, this dataset has the following content [TimeIndex, BidPr, BidQty, AskPr, AskQty,...]
% 		 StartIndex - stand for TimeIndex from which the dataset data is used
%		 LatencyMilSec  - stand for latency in Milli Seconds
%		 TimeExcOpenOrdCloseMilSec - time interval between Open order is executed and Close Order is given, in Milli Seconds
%									 see also ReturnStrategyLong() for additional details and explanations
%		 Threshold_Long - stands for the parameter, which initiates the order of a long position
%						  the Open order is given when baqRatio > Threshold_Long, and baqRatio = Bid_Quantity/(Ask_Quantity + Bid_Quantity)

% Output:
%		ExpectedReturnStrLong - stands for expected return of the simple trading strategy: Buy when  baqRatio > Threshold_Long and hold for time interval
%								TimeExcOpenOrdCloseMilSec + LatencyMilSec, then close the position (Close order).


function [ ExpectedReturnStrLong, N ] = AverageReturnStrategyLong( data, StartIndex, LatencyMilSec, TimeExcOpenOrdCloseMilSec, Threshold_Long)


	% Open file to keep the intermedeate results
	fileID = fopen('AverageReturnStrategyLong.txt','w');
	fprintf(fileID,'%4s, %4s, %8s,  %8s,  %5s,  %12s, %5s \n','S_t','S_T','S_T/S_t-1', 'Sum','N' ,'sum/N','t');	
	% Open file to keep the final results
	fileResults = fopen('Summary_AverageReturnStrategyLong.txt','w');
	fprintf(fileResults,'%24s,%24s,%24s \n', 'ExpectedReturnStrLong', 'N', 'sum');


	Length = length(data);
	t = StartIndex;
	sum = 0;  	% computes sum of net returns
	N = 0;  	% Number of transactions
	
	% Loop over the data, compute the actual returns and find their average, which according to Law of Large Numbers converges to expected returns
	while t < (Length-1);
		BidQty = data(t,3);
		AskQty =  data(t,5);
		baqRatio = BidQty/(BidQty + AskQty);
		
		% if True, place an Open order, otherwise skip
		if (baqRatio > Threshold_Long) 
			%Get the buying and selling stock prices
			data_tmp = data(t:end,: );
			[ S_t, S_T, TimeIndex_t,dTimeMilSec_t, TimeIndex_T,dTimeMilSec_T, HoldingTimeMilSec ] = ReturnStrategyLong(data_tmp, LatencyMilSec, TimeExcOpenOrdCloseMilSec);
			% S_t - Buy one stock at ask price, 
			% S_T - Sell one stock at bid price	

			%To compute the expected return by the Law of Large Numbers we need to avoid overlapping time intervals [t,T]
			t = tmp_t + TimeIndex_T + 1;
			
			if ~isnan(S_T)
				sum = sum + (S_T/S_t-1); % increase sum of aggregate returns
				N = N + 1; % increase the number of transactions by one
			else
				% in the case S_T is NaN then we reach the end of the dataset and finish calculations and close the files
				ExpectedReturnStrLong = sum/N;
				ExpectedReturnStrLongPerTime = ExpectedReturnStrLong*(10^6)/(LatencyMilSec+TimeExcOpenOrdCloseMilSec);
				fprintf(fileResults,'%24.20f, %24.2f, %24.2f, \n', ExpectedReturnStrLong, N, sum);
			
				fclose(fileID);
				fclose(fileResults);
				return;
			end
			fprintf(fileID,'%5.2f, %6.2f, %10.5f,  %10.5f,  %8d, %24.20f, %10d \n',S_t, S_T,  S_T/S_t-1, sum, N ,sum/N,t);
		end
		
		t = t + 1;
	end
	
	%Finish calculations and close the files
	ExpectedReturnStrLong=sum/N;
	ExpectedReturnStrLongPerTime = ExpectedReturnStrLong*(10^6)/(LatencyMilSec+TimeExcOpenOrdCloseMilSec);
	
	fprintf(fileResults,'%10.2f, %5d, %10.2f, \n', ExpectedReturnStrLong, N, sum);
	fclose(fileID);
	fclose(fileResults);

end
% Author: Serguey
% This version: November 2015
% Key concept:
% There is latency time between the time when an Order is given  and the time when the Order become Executed
% This function computes the Stock prices at two time moments given two input parameters: 1) the latency time between Open order and its execution
% and 2) the time between execution of Open order and the order to Close.
% It assumes the simples strategy: buy according to open order and hold for the time period TimeExcOpenOrdCloseMilSec, then give close order
% This is Long Position: Buy at ask price and sell at Bid price
%
% Input: 
%			data_tmp - data matrix with the following columns [TimeIndex, BidPr, BidQty, AskPr, AskQty,...]
%					   Important: the data_tmp starts at the time when the Open Order is given
% 			LatencyMilSec -  latency time measured in MilliSeconds
% 			TimeExcOpenOrdCloseMilSec  - time interval (in MilSec) between execution of Open Order and giving the Close Order

%							Time Frame of the Concept and Input
% -------|<---LatencyMilSec--->|<-----------TimeExcOpenOrdCloseMilSec---------------->|<---LatencyMilSec--->|--------------> time
%		 |                     |													  |						|
%		Open Order =start  Open Order Executed =OpenExcMilSec					Close Order				Close Execution=CloseExcMilSec

% In the following abbreviations, the Ord - stands for Order; and Exc - stands for execution


function [ S_t, S_T, TimeIndex_t,dTimeMilSec_t, TimeIndex_T,dTimeMilSec_T, HoldingTimeMilSec ] = ReturnStrategyLong(data_tmp, LatencyMilSec, TimeExcOpenOrdCloseMilSec)
	
	% HoldingTimeMilSec - time interval (in MilSec) between Execution of the Open Order and Execution of Close Order
	HoldingTimeMilSec = TimeExcOpenOrdCloseMilSec + LatencyMilSec;
	% start - time in MilSec when the given dataset (i.e. data_tmp) begin 
	start=data_tmp(1,1);
	
	%Time in MilSec when the open order is executed	
	OpenExcMilSec = start + LatencyMilSec;


	S_t = NaN;
	% Try to find the exact stock price when the order is executed
	for t = 1 : (length(data_tmp)-1);
		if  data_tmp(t,1) == OpenExcMilSec  
				S_t = data_tmp(t, 4); % Buy at ask price
				%
				TimeIndex_t = t; % TimeIndex of Open execution, - a row index in the data_tmp
				dTimeMilSec_t = data_tmp(t,1)-start; % time interval (in MilSec) between order execution and order openning, should be equal LatencyMilSec
				break
		elseif (data_tmp(t,1) < OpenExcMilSec )&&( OpenExcMilSec <= data_tmp(t + 1,1))
				S_t = data_tmp(t + 1, 4); % Buy at ask price at the TimeIndex t+1 that is feasible for execution given LatencyMilSec constraint
				TimeIndex_t = t + 1; % TimeIndex of execution
				dTimeMilSec_t = data_tmp(t+1,1) - start; % time interval (in MilSec) between order execution and order  openning, should exceed LatencyMilSec
				break
		end
	end
	
	OpenExcMilSec=data_tmp(TimeIndex_t,1);
		% Time in MilSec when the Close Order is executed
	CloseExcMilSec = OpenExcMilSec + TimeExcOpenOrdCloseMilSec + LatencyMilSec;
	if data_tmp(TimeIndex_t,1)> CloseExcMilSec
		fprintf(' data_tmp(TimeIndex_t,1) = %d > CloseExcMilSec= %d  \n', data_tmp(TimeIndex_t,1),CloseExcMilSec );
		return;
	end
	% Stock price at the time when the close order is executed
	S_T = NaN;
	TimeIndex_T = NaN;
	%fprintf(' TimeIndex_t = %d, Length= %d  \n', TimeIndex_t,(length(data_tmp)-1) );
	
	if(CloseExcMilSec > data_tmp(end,1))
		fprintf(' CloseExcMilSec = %d > Max Time possible= %d  \n', CloseExcMilSec,data_tmp(end,1) );
		dTimeMilSec_T=NaN;
		TimeIndex_T=NaN;
		S_T = NaN;
		return;
	end
	
% The  close  order is executed at CloseExcMilSec
	for t = TimeIndex_t : (length(data_tmp)-1)

		%if t>(length(data_tmp)-100)
		%	fprintf('Line 60: t = %d, Length= %d, CloseExcMilSec=%d data_tmp(end,1)=%d, diff=%d  \n', t,(length(data_tmp)-1), CloseExcMilSec, data_tmp(t,1), data_tmp(t,1)-CloseExcMilSec );
		%end 
		if data_tmp(t,1) == CloseExcMilSec
			S_T = data_tmp(t, 2); % Sell at Bid price	
			TimeIndex_T = t; % TimeIndex of Close execution, - a row index in the data_tmp
			dTimeMilSec_T = data_tmp(t,1)-start; % time in MilSec when the close order is executed
			return;
			break
		elseif (data_tmp(t,1) < CloseExcMilSec )&&( CloseExcMilSec <= data_tmp(t + 1,1) )
			S_T = data_tmp(t + 1, 2); % Sell at Bid price	
			TimeIndex_T = t + 1; % TimeIndex of Close execution, - a row index in the data_tmp
			dTimeMilSec_T = data_tmp(t+1,1) - start;  % time in MilSec when the close order is executed
			return;
			break
		end
	end	

	if(isnan(S_t) || isnan(S_T))
	disp('TimeIndex_T=')
	disp(TimeIndex_T)
		fprintf('S_t= %24.20f,  S_T= %24.20f, TimeIndex_t=%d, TimeIndex_T= %d  \n',S_t,S_T, TimeIndex_t,TimeIndex_T );
		error('Error: Either S_t or S_T is NaN.');
	end

end
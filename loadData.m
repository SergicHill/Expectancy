%% params
decisionLatency = 20; % tickwrite data timestamps in milliseconds
predictionHorizon = 1000 * 60 * 100; %1 minute

tsCol = 1;
bidPxCol = 2;
bidQtyCol = 3;
askPxCol = 4;
askQtyCol = 5;
tradePxCol = 6;
tradeQtyCol = 7;
bidMktTurnCol = 8;
askMktTurnCol = 9;

%added cols
wdwTradePxCol = 10;
wdwTotalVolCol = 11;

%% load data    
quotes = dlmread('C:\Users\SK\Documents\oDesk\KapitalTrading\Data\Data\ZQ-quote.csv',',');
trades = dlmread('C:\Users\SK\Documents\oDesk\KapitalTrading\Data\Data\ZQ-trade.csv',',');

%% Pre-process and merge quotes and trades into single matrix

%use most recent quote for duplicate timestamps
quotesNew = quotes;
duplicateRows = quotesNew(1:end-1,1) == quotesNew(2:end,1);
quotesNew(duplicateRows,:) = [];

%add up total qty at traded price for duplicate timestamp
tradesNew = zeros(0);
tradesNew(end+1,:) = trades(1,:);

for t = 2 : length(trades)
	if trades(t,1) == tradesNew(end,1) && trades(t,2) == tradesNew(end,2)
		tradesNew(end,3) = tradesNew(end,3) + trades(t,3);
	else
		tradesNew(end+1,:) = trades(t,:);
	end
end

%second pass for mixed prices at same timestamp
idxsToRemove = [];

for t = 1 : length(tradesNew) - 1
	idx = t+1;
	while tradesNew(idx,1) == tradesNew(t,1)
		if tradesNew(idx,2) == tradesNew(t,2)
			tradesNew(t,3) = tradesNew(t,3) + tradesNew(idx,3);
			idxsToRemove(end+1) = idx;
		end
		
		idx = idx+1;
	end
end

tradesNew(idxsToRemove,:) = [];

%merge into single matrix
data = mergeByTime(quotesNew,tradesNew,false,true); % trades are NaN when do not occur at a timestamp

%% Add total trade columns

%add new cols
data(:,wdwTradePxCol) = NaN;
data(:,wdwTotalVolCol) = NaN;

%insert book snapshot decisionLatency before each trade if there isn't one
%calculate total qty traded @ price in decisionLatency leading up to each trade
rowsToAdd = [];
len = length(data);
for t = 0 : len - 1
	row = data(len - t,:);
	
	if ~isnan(row(tradePxCol)) %this is a trade
		% loop backwards and duplicate last book decisionLatency before each
		% trade, if one isn't there already
		first = true;
		shift = 0;
		refTs = row(tsCol) - decisionLatency; %timestamp we want a book at
		
		totalVolume = row(tradeQtyCol);
		tradePx = row(tradePxCol);
		
		while first || refRow(tsCol) > refTs
			if ~first
				if ~isnan(refRow(tradePxCol)) && refRow(tradePxCol) == tradePx
					%trade at same price, add to totalVolume
					totalVolume = totalVolume + refRow(tradeQtyCol);
				end
			end
			
			first = false; %do-while behavior
			
			shift = shift + 1;
			
			if (len - t - shift) <= 0
				break;
			end
			
			refRow = data(len - t - shift,:);
		end
		
		%insert book snapshot, add totalVolume at price info
		if refRow(tsCol) == refTs && isnan(refRow(wdwTradePxCol))
			%row exists at expected timestamp and does not have data populated yet
			data(len - t - shift, wdwTradePxCol) = tradePx;
			data(len - t - shift, wdwTotalVolCol) = totalVolume;
		else
			%duplicate book from this row but with refTs
			newRow = refRow;
			newRow(tsCol) = refTs;
			newRow([tradePxCol tradeQtyCol]) = NaN;
			newRow(wdwTradePxCol) = tradePx;
			newRow(wdwTotalVolCol) = totalVolume;
			rowsToAdd(end+1,:) = newRow;
		end
	end
end

if ~isempty(rowsToAdd)
	data = [data; rowsToAdd];
	data = sortrows(data,tsCol);
end
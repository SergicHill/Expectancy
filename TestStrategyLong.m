function [ ExpectedReturnStrLong] = TestStrategyLong(data, Nstart, Nfinish)

	for k=Nstart: Nfinish
		disp(k)
		[ ExpectedReturnStrLong, N ] = AverageReturnStrategyLong( data, 1, 1780, 1000000*k, 0.5)
		disp(ExpectedReturnStrLong)
		
		if ExpectedReturnStrLong > 0
			return;
		end
	
	end
	disp('Expected return was negative for all cases under consideration')
end
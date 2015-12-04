function [ mergedMat ] = mergeByTime( mat1, mat2, nanMissingMat1s, nanMissingMat2s)

mat1Cols = size(mat1,2) - 1;
mat2Cols = size(mat2,2) - 1;

% add filler columns
mat1 = [mat1 NaN(length(mat1),mat2Cols)];
mat2 = [mat2(:,1) NaN(length(mat2),mat1Cols) mat2(:,[2:end])];

% sort on timestamp (first col)
mergedMat = [mat1; mat2];
[~,sortIdx] = sort(mergedMat(:,1));
mergedMat = mergedMat(sortIdx,:);

% interpolate gaps with last known value
[rCnt,cCnt] = size(mergedMat);

for i = 2 : rCnt
    nanCols = isnan(mergedMat(i,:));
    
    if sum(nanCols) > 0
        if nargin > 2
           % optionally do not duplicate for NaN vals
           if nanMissingMat1s
               nanCols(2:2+mat1Cols-1) = 0;
           end
           
           if nanMissingMat2s
               nanCols(2+mat1Cols:2+mat1Cols+mat2Cols-1) = 0;
           end
        end
        
        % check for duplicate timestamp
        if i < rCnt && mergedMat(i+1,1) == mergedMat(i,1) && sum(isnan(mergedMat(i+1,nanCols))) == 0
            mergedMat(i,nanCols) = mergedMat(i+1,nanCols);
        else
            mergedMat(i,nanCols) = mergedMat(i-1,nanCols);
        end
    end
end

%remove duplicate timestamp rows (values should be identical)
duplicateRows = mergedMat(1:end-1,1) == mergedMat(2:end,1);
mergedMat(duplicateRows,:) = [];

end
% x = double with potential for NaN
% cols = vector with columns of interest (for example, [3:10] for
% covariates only

function median_replace_df = median_replace(x, cols)
    
    % Make local copy of double
    df = x;
    
    % Find the NaN across all columns of double
    for ii = 1:length(cols)
        
        % Getting number of colum
        col_of_interest = cols(ii);
        
        % Checking in larger double
        na_present = isnan(df(:, col_of_interest));
        
        % Getting median
        m = median(df(:, col_of_interest), 'omitnan');
        
        % Replacing NaN's with median
        for jj = 1:length(na_present)
            
            if na_present(jj) == 1
                df(jj,col_of_interest) = m;
            end
            
        end
        
    end
    
    median_replace_df = df;
    
end
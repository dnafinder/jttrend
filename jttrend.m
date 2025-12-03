function STATS = jttrend(x,varargin)
% JTTREND: Perform the Jonckheere-Terpstra test on trend.
% There are situations in which treatments are ordered in some
% way, for example the increasing dosages of a drug. In these
% cases a test with the more specific alternative hypothesis that
% the population medians are ordered in a particular direction
% may be required. For example, the alternative hypothesis
% could be as follows: population median1 <= population
% median2 <= population median3. This is a one-tail test, and
% reversing the inequalities gives an analogous test in the
% opposite tail. Here, the Jonckheere-Terpstra test can be
% used.
% Bewick V., Cheek L., Ball J. Statistics review 10: further nonparametric
% methods. Critical Care 2004, 8: 196-199
%
% Assumptions:
% - Data must be at least ordinal
% - Groups must be selected in a meaningful order i.e. ordered
% If you do not choose to enter your own group scores then scores are
% allocated uniformly (1 ... k) in order of selection of the k groups.
%
% Syntax:
%     STATS = jttrend(x)
%     STATS = jttrend(x, score)
%     STATS = jttrend(x, score, 'Display', DISPLAY)
%
%     Inputs:
%           X - N-by-2 data matrix:
%               X(:,1) = observations
%               X(:,2) = integer group labels
%               Group labels must be consecutive integers 1,2,...,k without gaps.
%
%           SCORE - optional vector specifying the order of the groups (a
%                   permutation of 1:k). If omitted or empty, the natural
%                   order 1:k is used.
%
%           'Display' - logical flag (true/false), default true.
%                      If true, prints the pairwise U statistics and the
%                      Jonckheere-Terpstra summary table.
%                      If false, only returns STATS without printing.
%
%     Outputs:
%           STATS - structure with fields:
%               STATS.Uxy_pairs : table of pairwise comparisons
%                                 (Comparison, Nx, Ny, Uxy)
%               STATS.Uxy_sum   : scalar, sum of all Uxy
%               STATS.JT        : Jonckheere-Terpstra statistic (normalised)
%               STATS.pvalue    : one-tailed p-value (right tail)
%               STATS.tail      : 'right'
%
%   Example:
% Mice were inoculated with cell lines, CMT 64 to 181, which had been
% selected for their increasing metastatic potential. The number of lung
% metastases found in each mouse after inoculation are quoted below:
%
%                                 Sample
%                   ---------------------------------
%                      64   167  170  175  181
%                   ---------------------------------
%                      0    0    2    0    2
%                      0    0    3    3    4
%                      1    5    6    5    6
%                      1    7    9    6    6
%                      2    8    10   10   6
%                      2    11   11   19   7
%                      4    13   11   56   18
%                      9    23   12   100  39    
%                           25   21   132  60
%                           97
%                   ---------------------------------
%
%       Data matrix must be:
%    d=[0 0 1 1 2 2 4 9 0 0 5 7 8 11 13 23 25 97 2 3 6 9 10 11 11 12 21 ...
%       0 3 5 6 10 19 56 100 132 2 4 6 6 6 7 18 39 60];
%    g=[ones(1,8) 2.*ones(1,10) 3.*ones(1,9) 4.*ones(1,9) 5.*ones(1,9)];
%    x=[d' g'];
%
%           Calling on Matlab the function: STATS = jttrend(x)
% (in this case, the groups are automatically scored from 1 to 5)
%
%           Answer is:
%
% JONCKHEERE-TERPSTRA TEST FOR NON PARAMETRIC TREND ANALYSIS
% --------------------------------------------------------------------------------
%     Comparison    Nx    Ny    Uxy 
%     __________    __    __    ____
% 
%     '1-2'          8    10      63
%     '1-3'          8     9    65.5
%     '1-4'          8     9      61
%     '1-5'          8     9    63.5
%     '2-3'         10     9      41
%     '2-4'         10     9    49.5
%     '2-5'         10     9    41.5
%     '3-4'          9     9    45.5
%     '3-5'          9     9      39
%     '4-5'          9     9    35.5
% 
% --------------------------------------------------------------------------------
%  
% JONCKHEERE-TERPSTRA STATISTICS
% --------------------------------------------------------------------------------
%     Uxy_sum      JT      one_tailed_p_values
%     _______    ______    ___________________
% 
%     505        2.0116    0.022129           
% We have shown a statistically significant trend for increasing number of
% metastases across these malignant cell lines in this order.
%
%           Created by Giuseppe Cardillo
%           giuseppe.cardillo.75@gmail.com
%
% To cite this file, this would be an appropriate format:
% Cardillo G. (2008) Jonckheere-Terpstra test: A nonparametric test for trend.
% http://www.mathworks.com/matlabcentral/fileexchange/22159

% Input Error handling
p = inputParser;
addRequired(p,'x',@(y) validateattributes(y,{'numeric'}, ...
    {'real','finite','nonnan','nonempty','ncols',2}));
addOptional(p,'score',[],@(s) isempty(s) || ...
    (isnumeric(s) && isvector(s) && all(isreal(s(:))) && ...
     all(isfinite(s(:))) && ~all(isnan(s(:))) && ...
     all(s(:)>0) && all(fix(s(:))==s(:))));
addParameter(p,'Display',true, ...
    @(d) (islogical(d) || (isnumeric(d) && isscalar(d) && (d==0 || d==1))));
parse(p,x,varargin{:});
x       = p.Results.x;
score   = p.Results.score;
Display = logical(p.Results.Display);
clear p

% Check that group labels are integers and consecutive 1..k
assert(all(x(:,2) == fix(x(:,2))), ...
    'jttrend:InvalidGroupLabels', ...
    'All elements of column 2 must be whole numbers (integer group labels).');

groups = x(:,2);
ug     = unique(groups);
k      = numel(ug); % number of groups

assert(min(ug)==1 && max(ug)==k && k==max(groups), ...
    'jttrend:ConsecutiveGroups', ...
    'Group labels in column 2 must be consecutive integers from 1 to k without gaps.');

% Check/define score (ordering of groups)
if isempty(score) % default order
    score = 1:k;
else
    score = score(:).'; % ensure row vector
    assert(numel(score)==k, ...
        'jttrend:InvalidScoreLength', ...
        'Length of score must match the number of groups (k).');
    assert(all(ismember(score,1:k)), ...
        'jttrend:InvalidScoreValues', ...
        'score must contain integers between 1 and k.');
    assert(numel(unique(score))==k, ...
        'jttrend:ScoreNotPermutation', ...
        'score must be a permutation of 1:k (each group used exactly once).');
end

% Elements for each group
ni = crosstab(groups); % group sizes
N  = sum(ni);          % total observations

% Build-up the matrix of observations
X = NaN(max(ni),k);
for I = 1:k
    g = score(I);
    X(1:ni(g),I) = x(x(:,2)==g,1);
end

% Vector and variable preallocation
A  = cell(0.5*k*(k-1),4);
G  = 1;
tr = repmat('-',1,80); % divisor for display

if Display
    disp('JONCKHEERE-TERPSTRA TEST FOR NON PARAMETRIC TREND ANALYSIS')
    disp(tr)
end

for I = 1:k-1
    gI  = score(I);
    nIx = ni(gI);
    Uxy = zeros(1,nIx);
    for J = I+1:k
        gJ = score(J);
        % For each element of the I-th group, count how many elements
        % of the J-th group are greater (or equal, with weight 0.5).
        for F = 1:nIx
            xi = X(F,I);
            Uxy(F) = sum(X(:,J) >  xi) + ...
                     0.5*sum(X(:,J) == xi);
        end
        A{G,1} = sprintf('%i-%i',I,J);
        A{G,2} = ni(gI);
        A{G,3} = ni(gJ);
        A{G,4} = sum(Uxy);
        G = G+1;
    end
end

Tpairs = cell2table(A,'VariableNames',{'Comparison','Nx','Ny','Uxy'});
if Display
    disp(Tpairs)
end

Ut  = sum(cellfun(@double,A(:,4)));
N2  = N^2;
ni2 = ni.^2;
clear A

% Compute the Jonckheere-Terpstra statistic
num   = Ut - (N2 - sum(ni2))/4;
denom = sqrt((N2*(2*N+3) - sum(ni2.*(2.*ni+3)))/72);
JT    = abs(num/denom);

% One-tailed p-value from standard normal approximation (right tail)
p = 1 - normcdf(JT);

Tstats = table(Ut,JT,p,'VariableNames',{'Uxy_sum','JT','one_tailed_p_values'});

if Display
    disp(tr); 
    disp(' ')
    disp('JONCKHEERE-TERPSTRA STATISTICS')
    disp(tr)
    disp(Tstats)
end

% Build output structure
STATS = struct();
STATS.Uxy_pairs = Tpairs;
STATS.Uxy_sum   = Ut;
STATS.JT        = JT;
STATS.pvalue    = p;
STATS.tail      = 'right';
end

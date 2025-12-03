[![Open in MATLAB Online](https://www.mathworks.com/images/responsive/global/open-in-matlab-online.svg)](https://matlab.mathworks.com/open/github/v1?repo=dnafinder/jttrend&file=jttrend.m)

# jttrend

## 📘 Overview
jttrend is a MATLAB function that performs the Jonckheere–Terpstra test for trend across ordered groups. It is used when:

- you have k independent groups,
- the groups are ordered in a meaningful way (e.g., increasing doses of a drug, increasing severity levels),
- and you want to test for a monotonic trend in the medians (or distributions) across these ordered groups.

The null hypothesis H₀ typically states that there is no systematic trend across groups, while the alternative hypothesis H₁ posits that medians (or distributions) are ordered in a specific direction, e.g.:

median₁ ≤ median₂ ≤ … ≤ medianₖ

This is a **one-tailed** test; reversing the inequalities yields an analogous test in the opposite tail. jttrend implements the Jonckheere–Terpstra statistic and returns both the test statistic and the one-sided p-value from its normal approximation.

## ✨ Features
- Handles data in a simple N-by-2 format: [observation, groupLabel]
- Assumes groups are coded as consecutive integers 1, 2, …, k (no gaps)
- Accepts an optional **score** vector to define the **ordered sequence** of groups for the trend:
  - by default, group order is 1, 2, …, k
  - user can specify a permutation of 1:k to reflect a particular ordering
- Computes:
  - Pairwise U-statistics for all group pairs (i, j) with i < j
  - The global Jonckheere–Terpstra statistic (JT)
  - One-sided p-value (right tail) from the normal approximation
- Returns a **structured output** (STATS) suitable for further analysis and reporting
- Optional **Display** flag to control console output:
  - Display = true (default): prints detailed pairwise and summary tables
  - Display = false: suppresses printing and returns only STATS

## 📥 Installation
1. Download or clone the repository:
   https://github.com/dnafinder/jttrend

2. Add the folder containing jttrend.m to your MATLAB path:
      addpath('path_to_jttrend_folder')

3. Verify that MATLAB can see the function:
      which jttrend

If MATLAB returns the path to jttrend.m, the installation is successful.

## ⚙️ Requirements
- MATLAB (any recent version)
- Statistics and Machine Learning Toolbox (required for:
  - crosstab
  - normcdf
  - basic statistical operations)

No additional toolboxes are required beyond the above.

## 📈 Usage

Basic call with default group order:

    % x is an N-by-2 matrix:
    %   x(:,1) = observations
    %   x(:,2) = group labels (1,2,...,k)
    STATS = jttrend(x);

Use an explicit ordering of groups via a score vector:

    % Suppose groups are coded 1,2,3,4,5 but you want the trend
    % to be tested in the order [1, 3, 2, 4, 5]
    score = [1 3 2 4 5];
    STATS = jttrend(x, score);

Suppress output to the Command Window (silent mode):

    STATS = jttrend(x, [], 'Display', false);

In this case you only get the STATS structure and no printed tables.

## 🔢 Inputs

jttrend(x)  
jttrend(x, score)  
jttrend(x, score, 'Display', DISPLAY)

- x  
  - Type: numeric matrix (N×2)  
  - Description:
    - x(:,1) = observations (at least ordinal)
    - x(:,2) = integer group labels
  - Requirements:
    - Group labels must be consecutive integers from 1 to k without gaps (1,2,…,k).

- score (optional)  
  - Type: numeric vector of positive integers  
  - Description:
    - Specifies the **ordering** of the groups in the trend test.
    - Must be a permutation of 1:k, where k is the number of distinct groups.
  - Default:
    - If omitted or empty, score = 1:k (natural order of group labels).

- 'Display' (Name–Value, optional)  
  - Type: logical or numeric scalar (0/1)  
  - Default: true  
  - Description:
    - Controls printing to the Command Window.
      - true  → prints both pairwise U-statistics and final JT summary.
      - false → no printing; only the STATS structure is returned.

## 📤 Outputs

jttrend returns a single structured output:

    STATS = jttrend(...);

Fields of STATS:

- STATS.Uxy_pairs  
  - Type: table  
  - Columns:
    - Comparison : string labels of pairwise comparisons, e.g. '1-2', '1-3', …
    - Nx         : group size of the first group in the pair
    - Ny         : group size of the second group in the pair
    - Uxy        : U-statistic for the pair (i, j), summarising “wins” of
                   group j over group i in terms of the ordering of the data

- STATS.Uxy_sum  
  - Type: scalar  
  - Description: sum of all pairwise Uxy values, denoted Ut in the original function.

- STATS.JT  
  - Type: scalar  
  - Description: Jonckheere–Terpstra statistic normalised via its mean and variance, approximated by a standard normal distribution under H₀.

- STATS.pvalue  
  - Type: scalar  
  - Description: one-tailed (right-tail) p-value from the normal approximation; small values imply evidence for a monotonic increase (according to the specified score ordering).

- STATS.tail  
  - Type: char (string)  
  - Value: 'right'  
  - Description: indicates that the test is one-sided and uses the upper tail of the normal distribution.

## 🧠 Interpretation

- The test evaluates a **monotonic trend** across ordered groups.
- A large positive JT indicates that observations tend to increase as you move along the sequence of groups defined by the score vector.
- The p-value (one-tailed) quantifies evidence against the null hypothesis of no trend:
  - p small (e.g. < 0.05) suggests a statistically significant increasing trend.
  - p large suggests insufficient evidence to claim a monotonic trend.

The pairwise table STATS.Uxy_pairs can be inspected to understand contributions of each pair of groups to the overall trend.

## 📌 Example

Using the example reported in the function help:

Mice were inoculated with cell lines CMT 64, 167, 170, 175, and 181, which had been selected for their increasing metastatic potential. The number of lung metastases found in each mouse after inoculation are:

    % Data (metastases counts)
    d = [0 0 1 1 2 2 4 9 0 0 5 7 8 11 13 23 25 97 ...
         2 3 6 9 10 11 11 12 21 0 3 5 6 10 19 56 100 132 ...
         2 4 6 6 6 7 18 39 60];

    % Group labels (cell lines 64, 167, 170, 175, 181 coded as 1..5)
    g = [ones(1,8) ...
         2.*ones(1,10) ...
         3.*ones(1,9) ...
         4.*ones(1,9) ...
         5.*ones(1,9)];

    x = [d' g'];

Call jttrend with the default order (1 to 5):

    STATS = jttrend(x);

Typical printed output:

    JONCKHEERE-TERPSTRA TEST FOR NON PARAMETRIC TREND ANALYSIS
    --------------------------------------------------------------------------------
        Comparison    Nx    Ny    Uxy 
        __________    __    __    ____
     
        '1-2'          8    10      63
        '1-3'          8     9    65.5
        '1-4'          8     9      61
        '1-5'          8     9    63.5
        '2-3'         10     9      41
        '2-4'         10     9    49.5
        '2-5'         10     9    41.5
        '3-4'          9     9    45.5
        '3-5'          9     9      39
        '4-5'          9     9    35.5
     
    --------------------------------------------------------------------------------
     
    JONCKHEERE-TERPSTRA STATISTICS
    --------------------------------------------------------------------------------
        Uxy_sum      JT      one_tailed_p_values
        _______    ______    ___________________
     
        505        2.0116    0.022129

In this example, there is evidence of a statistically significant trend for increasing number of metastases across these malignant cell lines in the specified order.

## 🧾 Citation

If you use jttrend in research, analysis, or publications, please cite:

Cardillo G. (2008). Jonckheere–Terpstra test: A nonparametric test for trend.  
Available at: https://github.com/dnafinder/jttrend

## 👤 Author

Giuseppe Cardillo  
Email: giuseppe.cardillo.75@gmail.com  
GitHub: https://github.com/dnafinder

## 📄 License

The code is provided as-is, without any explicit warranty.  
Please refer to the repository for licensing details if a LICENSE file is present.  
jttrend is distributed under the terms specified in the LICENSE file:
https://github.com/dnafinder/jttrend

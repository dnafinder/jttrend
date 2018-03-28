# jttrend
Perform the Jonckheere-Terpstra test on trend.<br/>
There are situations in which treatments are ordered in some
way, for example the increasing dosages of a drug. In these
cases a test with the more specific alternative hypothesis that
the population medians are ordered in a particular direction
may be required. For example, the alternative hypothesis
could be as follows: population median1 <= population
median2 <= population median3. This is a one-tail test, and
reversing the inequalities gives an analagous test in the
opposite tail. Here, the Jonckheere-Terpstra test can be
used.
Bewick V., Cheek L., Ball J. Statistics review 10: further nonparametric
methods. Critical Care 2004, 8: 196-199

Assumptions:
- Data must be at least ordinal
- Groups must be selected in a meaningful order i.e. ordered
If you do not choose to enter your own group scores then scores are
allocated uniformly (1 ... n) in order of selection of the n groups.

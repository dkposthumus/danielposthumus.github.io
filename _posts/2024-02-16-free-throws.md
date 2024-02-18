---
title: 'Free Throw Bias in the NBA'
date: 2024-02-16
permalink: /posts/2024/02/free_throw/
tags:
    - economics
    - basketball
---
Disgruntled twitter heads are constantly claiming NBA officiating is in dire straits, with their team of choice the victim of a league-wide conspiracy. Beyond the sports-enthused's paranoia, there does appear to be a fair consensus there's such a thing as 'superstar' calls, a pattern of superstar players getting favorable calls. Is there indeed a bias favoring big-market teamsin the association? I'll apply some preliminary econometric techniques, including posterior analytical derivation, to test the hypothesis that there *is* a bias in favor of big-market teams.

Let's start by simply comparing the distributions of teams' free throw attempts (FTAs) differential--a positive differential indicating team $t$ attempted more free throws than their opponent, while a negative one indicates team $t$ attempted fewer free throws than their opponent. The graph below compares the distributions of the FTA differences for the 2023-2024 NBA season, including *only* the top 10 teams by average free throw differential.
![distribution of fta diff]({{ site.url }}{{ site.baseurl }}//images/blog-free-throw/fta_diff_dist.png)
Clearly, some teams get more free throws than others; using FTA difference means that we have controlled for game-specific effects, such as who the officials are or whether a game is particularly physical or soft. Nonetheless, this approach doesn't take into account *team*-specific effects.

Teams can play a certain way to earn more or fewer free throws--they can be more physically dominant in the paint (where shooting fouls are likelier to occur) or they could rarely venture into the point and settle for jump shots (which are less likely to result in free throws). Employing with the same dataset plotted above, I ran a simple OLS regression, with the fta_diff as the dependent variable, and a series of covariates, with the following specification for game $i$ and team $t$:

$$
\mathbf{Y}_{it} = \beta_1 \mathbf{X}_{it} + \mu_t + \beta_0 + \epsilon_{it}
$$

Where $\mu_t$ is the team fixed-effects term. The coefficients attached to the series of dummy variables for each team may be interpreted as estimates for $\mu_t$. I've plotted those estimates below:
![team fixed effects sizes]({{ site.url }}{{ site.baseurl }}//images/blog-free-throw/team_fe_size.png)
Clearly, three teams get the largest 'bonus', other factors being controlled for: the Los Angeles Lakers,  the New York Knicks, and the Philadelphia 76ers. Unsurprisingly, these are three very significant big-market teams--the Knicks are the 2nd-most valuable NBA franchise, the Lakers the 3rd, and the Sixers the 9th, [as of December 2023](https://www.nbcdfw.com/news/sports/nba/listing-the-most-valuable-nba-franchises-after-mark-cuban-sells-stake-of-mavericks/3399123/).

Let's conclude by employing Bayesian econometrics to derive the posterior curve for each of these teams; these curves suggest possible estimates of the 'true' value of a team's free throw attempts. We combine the knowledge given to us by our priors--in this case, the *total* distribution of free throw difference. Because of the nature of the data about free throw difference, I fit it to a normal curve: 1) free throw difference will always be centered on 0, for a complete dataset of teams and games, 2) free throw differences closer to 0 are much likelier than free throw differences away from 0, and 3) free throw difference will follow a *unimodal* (rather than binomial, for example) distribution. Here I've ploted the total distribution, the fitted normal curve, and the means for my three teams of interest:
![team fixed effects sizes]({{ site.url }}{{ site.baseurl }}//images/blog-free-throw/total_hist.png)
The fitted normal curve represents my prior information about the distribution of free throw attempt differences. Next, I estimate the posterior curve yielded by Bayes' Theorem:
$$
P(\theta | \text{prior}) = \frac{P(\text{prior} | \theta) P(\theta)}{P(\text{prior})}
$$
Next, I use the normal likelihood estimator to find the likelihood estimates and posteriors for the Lakers, Knicks, and Sixers.
![team fixed effects sizes]({{ site.url }}{{ site.baseurl }}//images/blog-free-throw/posterior_lal.png)
![team fixed effects sizes]({{ site.url }}{{ site.baseurl }}//images/blog-free-throw/posterior_nyk.png)
![team fixed effects sizes]({{ site.url }}{{ site.baseurl }}//images/blog-free-throw/posterior_phi.png)
Now let's plot a distribution of the samples from each of these posterior curves (I took 5,000 samples from each):
![team fixed effects sizes]({{ site.url }}{{ site.baseurl }}//images/blog-free-throw/posterior_total_hist.png)
Clearly, the Lakers' distribution of free throw attempt differences skews more heavily to the right than the Knicks of Sixers.

*Data is taken from [Basketball Reference](https://www.basketball-reference.com/).*

[Code and Data](https://github.com/dkposthumus/danielposthumus.github.io/tree/master/_posts/free_throw_2024)
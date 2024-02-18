---
title: 'Free Throw Bias in the NBA'
date: 2024-02-18
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
Where $\theta$ is our outcome of interest--the free throw attempt difference for a particular team. Next, I use the normal likelihood estimator to find the likelihood estimates and posteriors for the Lakers, Knicks, and Sixers.
![team fixed effects sizes]({{ site.url }}{{ site.baseurl }}//images/blog-free-throw/posterior_lal.png)
![team fixed effects sizes]({{ site.url }}{{ site.baseurl }}//images/blog-free-throw/posterior_nyk.png)
![team fixed effects sizes]({{ site.url }}{{ site.baseurl }}//images/blog-free-throw/posterior_phi.png)
These curves are interesting, but they largely tell us something we already knew or at the very least suspected: the Lakers, Knicks, and Sixers all receive a much greater advantage in free throw attempts than the rest of the league, and the distribution of their observed values dominates the prior (hence the steepness of the posterior curves).Another way to visualize the posterior curves is to sample repeatedly from them and to plot the distributions for these samples. Thus, I sample from the posterior 5,000 times to create the following histograms:
![team fixed effects sizes]({{ site.url }}{{ site.baseurl }}//images/blog-free-throw/posterior_total_hist.png)
Clearly, the Lakers' distribution of free throw attempt differences skews more heavily to the right than the Knicks of Sixers, both of which are centered around means significantly to the right of 0, the league average. Again, this is nothing particularly revelatory.

However, using the posterior curves crafted above, we can conduct [analysis](https://stephens999.github.io/fiveMinuteStats/summarize_interpret_posterior.html) such as finding the posterior probability or we can find Bayesian confidence intervals. For this analysis, let's focus on the Lakers, who appear to receive the most significant advantage in free throw attempts. 

Let's begin with calculating the posterior probability that $\theta_{\text{lal}} > 0$, since 0 is the center of the league's total distribution of $\theta$. The probability, as we might expect from the graphs above, is 100%. What about greater than one standard deviation above 0? The probability of that is merely 0.12%, and the probability of it being greater than two standard deviations above 0 is 0%. Finally, the posterior probability that the Lakers shoot more free throws than the Knicks' mean is 96.84% and for the Sixers' mean is 99.78%. Now let's compute a Bayesian confidence interval; at a 90% confidence level, the interval is (3.50,7.48) and at 95%, the interval is (3.06,7.85). Clearly, we can say *with a great deal of confidence* that the Lakers have a greater free throw attempt advantage than the rest of the league.

This approach suggests that there *is* some obvious advantage for big-market teams, in particular for the Lakers, Knicks, and Sixers. However, there are some shortcomings to this approach: the team data I've used for my analysis includes only the most basic information about shooting patterns--in fact, it only tells me whether a field goal attempt was a 2-pointer or a 3-pointer. And although in my regression analysis above, I included rebounds as a proxy for a team's physical domination of the paint, that's an imperfect measure. Ideally, I would be able to control for the distribution of 2-point field attempts by distance from the basket--the assumption being that shoots within 0-3 feet of the basketball are much likelier to draw fouls than shoots attempted 16 feet from the basket. Unfortunately, that data is only available for individual players.

Thus, in a future blog post I'll hone in on individual players; if I look at individual players' careers who played for the Lakers as well as other NBA teams, I can control for more detailed variables like shooting patterns (specifically the distance from their basket of their average 2 point field attempt), individual honors won, age, and winning percentage in games played in an attempt to isolate a possible 'Los Angeles Premium' for free throw attempts. I will also derive the posterior curves for selected current Los Angeles players (most importantly Lebron James and Anthony Davis), using their past seasons' free throw attempt data as the prior information and their free throw attempts while in a Lakers uniform as the parameter of interest. 

*Data is taken from [Basketball Reference](https://www.basketball-reference.com/).*

[Code and Data](https://github.com/dkposthumus/danielposthumus.github.io/tree/master/_posts/free_throw_2024)
---
title: 'Free Throw Bias in the NBA'
date: 2024-02-13
permalink: /posts/2024/02/free_throw/
tags:
    - economics
    - basketball
---
This past week, in a game between the New York Knicks and Houston Rockets, NBA officials called a last-second shooting foul, giving the Rockets 3 free throws to win the game--which they did. The problem was that in the Last 2 Minute report (L2M), and immediately after the game, the NBA admitted the call was incorrect, prompting an [appeal](https://www.nbcsports.com/nba/news/knicks-reportedly-to-protest-last-second-loss-to-rockets) of the game's conclusion from the Knicks.

This is just one episode of the NBA's recent controversies about officiating--more technology and the availability of media means fans in corners of Twitter endlessly parsing slow-motion replay of shooting fouls. Recent scoring spates have prompted claims that the NBA is growing 'soft', with blatant favoritism for certain teams or stars in the rewarding of free throws. Is there any validity to this claim?

It makes sense to start answering this question with the basics: do some teams earn more free-throws than others? The graph of below captures the distribution of the difference in free throw attempts (FTAs) for the 2023-2024 NBA season, including *only* the top 10 teams by average free throw differential.
![distribution of fta diff]({{ site.url }}{{ site.baseurl }}//images/blog-free-throw/fta_diff_dist.png)
Clearly, some teams get more free throws than others, even when controlling for game specific-effects (which I do by taking the difference between a team's and their opponent's free throw attempts).

However, there can be a lot of reasons why this discrepancy exists: teams can be more physically dominant in the paint, where shooting fouls are likelier to occur, or they could just shoot more in the paint. Running with the same dataset plotted above, I ran a simple OLS regression, with the fta_diff as the dependent variable, and a series of covariates, with the following specification for game $i$ and team $t$:

$$
\mathbf{Y}_{it} = \beta_1 \mathbf{X}_{it} + \mu_t + \beta_0 + \epsilon_{it}
$$

Where $\mu_t$ is the team fixed-effects term. The coefficients attached to the series of dummy variables for each team may be interpreted as estimates for $\mu_t$. I've plotted those estimates below:
![team fixed effects sizes]({{ site.url }}{{ site.baseurl }}//images/blog-free-throw/team_fe_size.png)
We can immediately see three teams get the largest 'bonus', other factors being controlled--the Los Angeles Lakers,  the New York Knicks, and the Philadelphia 76ers. Unsurprisingly, these are three large big-market teams--the Knicks are the 2nd-most valuable NBA franchise, the Lakers the 3rd, and Philadelphia the 9th, [as of December 2023](https://www.nbcdfw.com/news/sports/nba/listing-the-most-valuable-nba-franchises-after-mark-cuban-sells-stake-of-mavericks/3399123/).

Lastly, let's create a distribution of Free Throw Attempt differences and then use the negative log likelihood function to determine the likelihood of the Lakers, Knicks, and 76ers achieving their average free thow attempt differential.
![team fixed effects sizes]({{ site.url }}{{ site.baseurl }}//images/blog-free-throw/total_kdp.png)


*Note: data is taken from [BasketballReference](https://www.basketball-reference.com/).*

[Code](https://github.com/dkposthumus/danielposthumus.github.io/tree/master/_posts/free_throw_2024/code)

[Data](https://github.com/dkposthumus/danielposthumus.github.io/tree/master/_posts/free_throw_2024)
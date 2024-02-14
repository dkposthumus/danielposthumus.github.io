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

However, there can be a lot of reasons why this discrepancy exists: teams can be more physically dominant in the paint, where shooting fouls are likelier to occur, or they could just shoot more in the paint. Running with the same dataset plotted above, I ran a simple OLS regression, with the fta_diff as the dependent variable, and a series of independent variables, including (for both the team and its opponent): 
- Field Goal Attempts (FGA)
- Field Goal Percentage (FG%)
- Share of Field Goal Attempts that were 3 Pointers (3PA_FGA)
- Offensive Rebounds (ORB)
- Visitor Status (visitor)
I also include a dummy variable for each of those top 10 teams outlined above--the coefficient attached to this dummy variable will suggest the team effect on free throw attempt differentials, controlling for their style of play in the game.

*Note: data is taken from [BasketballReference](https://www.basketball-reference.com/).*
[Code]()
[Data]()
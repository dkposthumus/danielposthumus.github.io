# Import everything
import sys
import os
import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

# Create the list we're going to use to set up our loop:
teams = ["atl", "bos", "brk", "cho", "chi", "cle", "dal", "den", "det", "gsw", "hou", "ind", "lac", "lal", "mem", "mia", "mil", "min", "nop", "nyk", "okc", "orl", "phi", "pho", "por", "sac", "sas", "tor", "uta", "was"]
# Let's create an empty list that we're going to fill with each team's dataframe:
all_teams_data = []
# Now let's clean each of these dataframes using a loop:
for team in teams:
    team_2024 = pd.read_excel(f'team_data/{team}_2024.xlsx', header=1)
    # Let's create a dummy for whether the team is the visitor in the game or not
    team_2024.loc[team_2024['Unnamed: 3'] == '@', 'visitor'] = 1
    team_2024.loc[pd.isna(team_2024['Unnamed: 3']), 'visitor'] = 0
    # Now let's create a variable that captures the team name itself:
    team_2024['team_name'] = team
    # Let's create a dummy variable for a win, replacing the W/L column:
    team_2024.loc[team_2024['W/L'] == 'W', 'win'] = 1
    team_2024.loc[team_2024['W/L'] == 'L', 'win'] = 0
    # Now let's rename the variables ending with '.1', since those are for the opposing team:
    renamed_opp_cols = {col: col.replace('.1', '_opp') for col in team_2024.columns if '.1' in col}
    team_2024 = team_2024.rename(columns=renamed_opp_cols)
    # Let's replace the score column names, which are inappropiately named:
    rename_point_cols = {'Tm': 'team_pts', 'Opp_opp': 'opp_points'}
    team_2024 = team_2024.rename(columns=rename_point_cols)
    # Let's generate two differential variables: first in free throw attempts and then in personal fouls
    team_2024['fta_diff'] = team_2024['FTA'] - team_2024['FTA_opp']
    team_2024['pf_diff'] = team_2024['PF'] - team_2024['PF_opp']

    team_var_to_drop = ['Rk', 'Date', 'Unnamed: 3', 'W/L']
    team_2024 = team_2024.drop(columns=team_var_to_drop)
    # Finally, let's append this to a master dataframe:
    all_teams_data.append(team_2024)
# Let's concatenate into a true master dataset
master_team = pd.concat(all_teams_data, ignore_index=True)

# Now let's create a series of histograms to represent the distribution of free throw attempts:
# Let's set up the matplotlib figures
plt.figure(figsize=(12,6))
# let's create each team's histograms:
for team_name, data in master_team.groupby('team_name'):
    if team_name == 'lal':  # Bold curve for the LA Lakers
        sns.kdeplot(data=data['fta_diff'], label=team_name, linewidth=5)
    else:
        sns.kdeplot(data=data['fta_diff'], label=team_name)
# Add labels and legend
plt.xlabel('Free Throw Attempt Difference')
plt.ylabel('Density')
plt.title('Kernel Density Estimation of Free Throw Attempt Difference by Team')
plt.legend(title='Team')
plt.show()

# There's too much going on in this graph. Let's restrict it to the top 10 teams by average free throw differential:
# Calculate the average fta_diff for each team
avg_fta_diff = master_team.groupby('team_name')['fta_diff'].mean()
# let's select the top 10 teams with the highest average fta_diff:
top_10_teams = avg_fta_diff.nlargest(10).index
# Filter the original DataFrame to include only data for the top 10 teams
top_10_data = master_team[master_team['team_name'].isin(top_10_teams)]
print(top_10_data.head())
# Set up the matplotlib figure
plt.figure(figsize=(12, 6))
# Create distribution curves for each group in the DataFrame
for team_name, data in top_10_data.groupby('team_name'):
        sns.kdeplot(data=data['fta_diff'], label=team_name)
# Add labels and legend
plt.xlabel('Free Throw Attempt Difference')
plt.ylabel('Density')
plt.title('Kernel Density Estimation of Free Throw Attempt Difference for Top 10 Teams')
plt.legend(title='Team')
plt.show()

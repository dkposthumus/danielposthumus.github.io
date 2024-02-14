# Import everything
import sys
import os
import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import statsmodels.api as sm
# let's set the new working directory:
new_directory = '/Users/danielposthumus/danielposthumus.github.io/_posts/free_throw_2024'
os.chdir(new_directory)
# now let's define the variable we're using to save all images:
image_path = '/Users/danielposthumus/danielposthumus.github.io/images/blog-free-throw'
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
    # Now let's generate a dummy variable for each of these teams:
    team_2024[f'{team}'] = 1 
    team_var_to_drop = ['Rk', 'Date', 'Unnamed: 3', 'W/L']
    team_2024 = team_2024.drop(columns=team_var_to_drop)
    # Finally, let's append this to a master dataframe:
    all_teams_data.append(team_2024)
# Let's concatenate into a true master dataset
master_team = pd.concat(all_teams_data, ignore_index=True)
# We have a quick problem -- the dummy variables we coded for each team 
# are missing where they shoudl be 0 -- so let's fill that in right now:
for team in teams:
    master_team[f'{team}'] = master_team[f'{team}'].fillna(0)
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
    if team_name == 'lal':  # Bold curve for the LA Lakers
        sns.kdeplot(data=data['fta_diff'], label=team_name, linewidth=5)
    else:
        sns.kdeplot(data=data['fta_diff'], label=team_name)
# Add labels and legend
plt.xlabel('Free Throw Attempt Difference')
plt.ylabel('Density')
plt.title('Kernel Density Estimation of Free Throw Attempt Difference for Top 10 Teams in FTA Diff')
plt.legend(title='Team')
# Let's save this plot:
plt.savefig(image_path + '/fta_diff_dist.png')
plt.show()

# Let's check what variables we can work with:
print(list(master_team.columns))
# We want to create a couple of variables, e.g. the share of FGAs that were 3-pointers:
master_team['3pa_fga'] = master_team['3PA']/master_team['FGA']
master_team['3pa_fga_opp'] = master_team['3PA_opp']/master_team['FGA_opp']
lhs_reg = ['win', 'FGA', 'FGA_opp', 'FG%', 'FG%_opp', '3pa_fga', '3pa_fga_opp', 'ORB', 'ORB_opp', 'BLK', 'BLK_opp', 'visitor', "atl", "bos", "brk", "cho", "chi", "cle", "dal", "den", "det", "gsw", "hou", "ind", "lac", "lal", "mem", "mia", "mil", "min", "nop", "nyk", "okc", "orl", "phi", "pho", "por", "sac", "sas", "tor", "uta", "was"]
# Now let's run the regression, first defining our variables:
X = master_team[lhs_reg]
y = master_team['fta_diff']
print(X.isnull().sum())
# Add constant
X = sm.add_constant(X) 
model = sm.OLS(y, X).fit()
print(model.summary())
# Now let me extract the coefficients and their names:
coeff_names = ["atl", "bos", "brk", "cho", "chi", "cle", "dal", "den", "det", "gsw", "hou", "ind", "lac", "lal", "mem", "mia", "mil", "min", "nop", "nyk", "okc", "orl", "phi", "pho", "por", "sac", "sas", "tor", "uta", "was"]
coefficients_to_plot = model.params[coeff_names]
# Now let's plot them:
plt.figure(figsize=(10,6))
plt.bar(coeff_names, coefficients_to_plot)
plt.xlabel('Variable')
plt.ylabel('Coefficient')
plt.title('Coefficients of OLS Regression')
plt.xticks(rotation=45, ha='right')  # Rotate x-axis labels for better readability
plt.tight_layout()
plt.savefig(image_path + '/team_fe_size.png')
plt.show()
# Let's create a basic plot of ALL the games' free throw distributions:
plt.figure(figsize=(10,6))
sns.kdeplot(data=data['fta_diff'], linewidth=5)
# let's add a vertical line for the Lakers' average fta
lakers_average_fta_diff = master_team[master_team['team_name']=='lal']['fta_diff'].mean()
plt.axvline(x=lakers_average_fta_diff,color='red',linestyle='--', label='Lakers Avg FTA Diff')
plt.xlabel('Free Throw Attempt Difference')
plt.ylabel('Density')
plt.title('Kernel Density Estimation of Free Throw Attempt Difference for Top 10 Teams in FTA Diff')
plt.legend(title='Team')
plt.savefig(image_path + '/total_kdp.png')
plt.show()
# Import everything
import sys
import os
import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import statsmodels.api as sm
import scipy.stats as stats
from scipy.stats import norm, gaussian_kde
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
# let's now restrict this graph to only the top 10 teams by free throw attempt difference:
# First, calculate the average free throw attempts for each team
team_avg_fta = master_team.groupby('team_name')['fta_diff'].mean()
# Then, ensure team_avg_fta is a Series object
if not isinstance(team_avg_fta, pd.Series):
    raise ValueError("team_avg_fta should be a pandas Series object.")
# Now, sort the teams based on average free throw attempts and select the top 10
top_10_teams = team_avg_fta.sort_values(ascending=False).head(10)
# Now, create a sub-dataframe containing only the top 10 teams
top_10_data = master_team[master_team['team_name'].isin(top_10_teams.index)].copy()
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
team_colors = {'lal': 'purple', 'phi': 'blue', 'nyk': 'orange'}
team_labels = {'lal': 'Lakers', 'phi': 'Sixers', 'nyk': 'Knicks'}
team_averages = {}
for team in ['lal', 'phi', 'nyk']:
    team_average = master_team[master_team['team_name']==team]['fta_diff'].mean()
    team_averages[team] = team_average
    plt.axvline(x=team_average, color=team_colors[team], linestyle='--', label=f'{team_labels[team]} Avg FTA Diff')
plt.xlabel('Free Throw Attempt Difference')
plt.ylabel('Density')
plt.title('Kernel Density Estimation of Free Throw Attempt Difference for Top 10 Teams in FTA Diff')
plt.legend(title='Team')
plt.savefig(image_path + '/total_kdp.png')
plt.show()
# let's replot that as a histogram; the problem is that we can't have all 30 teams included; let's restrict it to the top 10.
# Now let's check about missing observations:
# Display the first few rows of the missing values count
pd.set_option('display.max_rows', None)
print(master_team.isnull().sum())
# Some variable called 'Unnamed: 24' is the problem, so let's drop it
master_team = master_team.drop(columns=['Unnamed: 24'])
print(master_team.isnull().sum())
# Now let's plot a histogram of these scaled values w/averages:
plt.figure(figsize=(8,4))
team_colors = {'lal': 'purple', 'phi': 'blue', 'nyk': 'orange'}
team_labels = {'lal': 'Lakers', 'phi': 'Sixers', 'nyk': 'Knicks'}
team_averages = {}
plt.hist(master_team['fta_diff'], bins=20, density=True, alpha=0.5, color='skyblue', edgecolor='black', label='FTA Difference')
# Plotting the normal curve
mu, std = np.mean(master_team['fta_diff']), np.std(master_team['fta_diff'])
x = np.linspace(np.min(master_team['fta_diff']), np.max(master_team['fta_diff']), 100)
plt.plot(x, norm.pdf(x, mu, std), 'r-', label='Normal Distribution')
plt.ylabel(r'Number of Games')
plt.xlabel(r'FTA Difference ($\theta$)')
plt.axvline(master_team['fta_diff'].mean(), ls='--', c='k', label='Mean Avg FTA')
for team in ['lal', 'phi', 'nyk']:
    team_average = master_team[master_team['team_name']==team]['fta_diff'].mean()
    team_averages[team] = team_average
    plt.axvline(x=team_average, color=team_colors[team], linestyle='--', label=f'{team_labels[team]} Avg FTA Diff')
plt.legend()
plt.tight_layout()
plt.savefig(image_path + '/total_hist.png')
plt.show()
# Now let's analytically derive the posterior. 
def likelihood(theta, data):
    mu = theta[0]
    sigma = theta[1]
    return np.prod(norm.pdf(data, mu, sigma))
# Prior distribution parameters
prior_mean = master_team['fta_diff'].mean()
prior_std = master_team['fta_diff'].std() 
prior_var = prior_std**2 
# Number of samples to draw from the posterior distribution
num_samples = 5000
# Now, let's run a loop for the three teams of interest:
teams_interest = ['lal', 'nyk', 'phi']
posterior_samples_all_teams = []
for team in teams_interest:
    team_data = master_team[master_team['team_name'] == team]['fta_diff']
    # Likelihood parameters
    likelihood_team = likelihood([team_data.mean(), team_data.std()], team_data)
    # Posterior distribution parameters
    posterior_mean_team = (prior_mean / prior_var + np.sum(team_data) / prior_var) / (1 / prior_var + len(team_data) / prior_var)
    posterior_var_team = 1 / (1 / prior_var + len(team_data) / prior_var)
    posterior_std_team = np.sqrt(posterior_var_team)
    # Sample from the posterior distribution
    posterior_samples_team = np.random.normal(posterior_mean_team, posterior_std_team, num_samples)
    posterior_samples_all_teams.append(posterior_samples_team)
    x_prior = np.linspace(prior_mean - 3*prior_std, prior_mean + 3*prior_std, 100)
    team_posterior = np.linspace(posterior_mean_team - 3*posterior_std_team, posterior_mean_team + 3*posterior_std_team, 100)
    # Append posterior samples to the list
    # Now let's plot everything: 
    plt.figure(figsize=(10, 6))
    plt.plot(x_prior, norm.pdf(x_prior, prior_mean, prior_std), label='Prior', color='blue')
    plt.hist(team_data, bins=20, density=True, alpha=0.5, color='green', label=f'Observed Values for {team}')
    plt.plot(team_posterior, norm.pdf(team_posterior, posterior_mean_team, posterior_std_team), label='Posterior', color='red')
    team_average = master_team[master_team['team_name']==team]['fta_diff'].mean()
    team_averages[team] = team_average
    plt.axvline(x=team_average, color=team_colors[team], linestyle='--', label=f'{team_labels[team]} Avg FTA Diff')
    plt.title(f'Posterior, Prior, and Likelihood Curves for {team} Team')
    plt.xlabel('FTA Difference')
    plt.ylabel('Probability Density')
    plt.legend()
    plt.savefig(image_path + f'/posterior_{team}.png')
    plt.show()
# Now let's plot all three posterior curves together:
plt.figure(figsize=(10, 6))
# Plot each posterior curve
for i, team in enumerate(teams_interest):
     # Calculate KDE
    kde = gaussian_kde(posterior_samples_all_teams[i])
    x = np.linspace(posterior_samples_all_teams[i].min(), posterior_samples_all_teams[i].max(), 100)
    plt.plot(x, kde(x), label=f'{team} Posterior')
# Add legend and labels
plt.title('Posterior Curves for All Teams')
plt.xlabel('FTA Difference')
plt.ylabel('Probability Density')
plt.legend()
plt.savefig(image_path + '/posterior_total_kde.png')
plt.show()
# Now let's do the same thing, but with histograms:
plt.figure(figsize=(10, 6))
for i, team in enumerate(teams_interest):
    plt.hist(posterior_samples_all_teams[i], bins=30, density=True, alpha=0.5, label=f'{team} Posterior')
plt.title('Posterior Curves for All Teams')
plt.xlabel('FTA Difference')
plt.ylabel('Probability Density')
plt.legend()
plt.savefig(image_path + '/posterior_total_hist.png')
plt.show()
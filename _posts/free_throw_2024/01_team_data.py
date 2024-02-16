# Import everything
import sys
import os
import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import statsmodels.api as sm
import scipy.stats as stats
from sklearn.preprocessing import MinMaxScaler
from scipy.stats import beta 
from scipy.stats import norm
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
# However, to fit the beta distribution, ALL observations of the fta_diff must be in the interval [0,1]; this is pretty simple via standardizing with min-max:
# Extract the 'fta_diff' column from the master data
fta_diff = master_team['fta_diff']
# Create a MinMaxScaler object
scaler = MinMaxScaler()
# Fit the scaler to your data and transform it
scaled_fta_diff = scaler.fit_transform(fta_diff.values.reshape(-1, 1))
# Add the scaled variable back to the DataFrame
master_team['scaled_fta_diff'] = scaled_fta_diff
master_team['scaled_fta_diff'] = master_team['scaled_fta_diff'] + 0.001
print(np.min(master_team['scaled_fta_diff']))
print(np.max(master_team['scaled_fta_diff']))
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
plt.hist(master_team['scaled_fta_diff'])
plt.ylabel(r'Number of Games')
plt.xlabel(r'FTA Difference ($\theta$)')
plt.axvline(master_team['scaled_fta_diff'].mean(), ls='--', c='k', label='Mean Avg FTA (Scaled)')
for team in ['lal', 'phi', 'nyk']:
    team_average = master_team[master_team['team_name']==team]['scaled_fta_diff'].mean()
    team_averages[team] = team_average
    plt.axvline(x=team_average, color=team_colors[team], linestyle='--', label=f'{team_labels[team]} Avg FTA Diff (Scaled)')
plt.legend()
plt.tight_layout()
plt.savefig(image_path + '/total_hist.png')
plt.show()
# Now let's fit a beta distribution:
res = stats.beta.fit(master_team['scaled_fta_diff'].values, floc=0, fscale=1.1)
# Print alpha and beta parameters of the beta distribution
print('alpha: %0.3f, beta: %0.3f of beta distribution' % (res[0], res[1]))
# Now let's plot the histogram w/the mean lines and the prior distribution curve
plot_theta = np.arange(0,1,.02)
prior_prob = np.array([beta(res[0], res[1], loc=0, scale=1.1).pdf(i) for i in plot_theta])

fig, ax = plt.subplots(1,1, figsize=(8,4))
ax.hist(master_team['scaled_fta_diff'], density=True)
ax.axvline(master_team['scaled_fta_diff'].mean(), ls='--', c='k',
            label='Mean ('+str(master_team['scaled_fta_diff'].mean().round(3))+')')
ax.plot(plot_theta, prior_prob, label="Prior Distribution")
ax.set_yticks([])
ax.set_ylabel(r'Pr($\theta$)')
ax.set_xlabel(r'FTA Difference($\theta$)')
ax.legend()
sns.despine(offset=[3.,0.])
plt.tight_layout()
plt.savefig(image_path + '/total_prior_dist.png')
plt.show()

# Now let's analytically derive the posterior; let's run a loop for the three teams of interest:
three_teams = ['lal', 'nyk', 'phi']
for team in three_teams:
    # Define the normal likelihood function
    def normal_likelihood(data, mean, std):
        likelihood = norm.pdf(data, loc=mean, scale=std)
        return likelihood
    # Calculate mean and standard deviation of the observed data
    # Filter the DataFrame to select only observations where team_name is 'team'
    team_data = master_team[master_team['team_name'] == f'{team}']
    # Calculate mean and standard deviation of the filtered data
    mean_team = team_data['scaled_fta_diff'].mean()
    std_team = team_data['scaled_fta_diff'].std()
    # Compute the likelihood function using the observed data and its parameter
    # Adjust the range of values for team_likelihood to match the length of prior_prob
    team_likelihood = normal_likelihood(np.linspace(0, 1, len(prior_prob)), mean_team, std_team)
    # Compute the unnormalized posterior by multiplying the likelihood with the prior
    team_unnormalized_posterior = team_likelihood * prior_prob
    # Normalize the posterior to obtain the actual posterior distribution
    team_posterior = team_unnormalized_posterior / np.sum(team_unnormalized_posterior)
    # Plot the prior, likelihood, and posterior distributions
    plt.figure(figsize=(10, 5))
    plt.plot(plot_theta, prior_prob, label='Prior (Beta)')
    plt.plot(plot_theta, team_likelihood, label='Likelihood (Normal)')
    plt.plot(plot_theta, team_posterior, label='Posterior')
    plt.xlabel('Parameter Value')
    plt.ylabel('Density')
    plt.title(f'Prior, Likelihood, and Posterior Distributions for {team}')
    plt.legend()
    plt.savefig(image_path + f'/posterior_{team}.png')
    plt.show()
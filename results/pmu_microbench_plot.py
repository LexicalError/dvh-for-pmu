import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
import seaborn as sns
import numpy as np

plt.rcParams.update({
    "font.family": "serif",
    "font.serif": ["DejaVu Serif"],  # A very high-quality open-source substitute for Times
    "font.size": 9,                  # Standard size for sigconf
    "axes.titlesize": 10,
    "axes.labelsize": 9,
    "xtick.labelsize": 8,
    "ytick.labelsize": 8,
    "legend.fontsize": 8,
    # This removes the "box" look and gives a clean academic feel
    "axes.grid": True,
    "grid.alpha": 0.3,
})
files = {
    'L2-DVH': 'pmu_micro_dvh.csv',
    'L2': 'pmu_micro_no_dvh.csv',
    'L1': 'pmu_micro_l1.csv'
}

# 2. Read and combine the CSVs
df_list = []
for config_name, file_path in files.items():
    temp_df = pd.read_csv(file_path)
    temp_df['Configuration'] = config_name
    df_list.append(temp_df)

# Combine into one master DataFrame containing ALL iterations
df_raw = pd.concat(df_list, ignore_index=True)

# 3. Setup the plot
plt.figure(figsize=(6.66, 5))
sns.set_theme(style="whitegrid")

# 4. Create a grouped bar chart with Error Bars
# By passing the RAW data, Seaborn calculates the mean and standard deviation automatically!
ax = sns.barplot(
    data=df_raw, 
    x='Test', 
    y='Cycles', 
    hue='Configuration',
    estimator='mean',     # Calculates the average
    errorbar='sd',        # Adds Standard Deviation error bars
    capsize=0.1,          # Adds small horizontal caps to the top/bottom of the error bars
    err_kws={'linewidth': 1.5, 'color': 'black'} # Styles the error lines
)

# 5. Styling
ax.set_yscale('log')
ax.set_ylabel('Latency (CPU Cycles)')
ax.set_xlabel('Register / MSR Test')
plt.title('PMU Microbenchmark Latency Comparison')

ax.yaxis.set_major_locator(ticker.LogLocator(base=10.0, subs=np.arange(1, 10), numticks=100))
ax.yaxis.set_major_formatter(ticker.ScalarFormatter())

# Optional: Add grid lines for the minor ticks to make them visible
ax.grid(True, which='both', linestyle='--', linewidth=0.5, alpha=0.7)

# Rotate x-axis labels so they don't overlap
plt.xticks(rotation=45, ha='right')

# Adjust layout so the labels aren't cut off
plt.tight_layout()

# Save for publication
plt.savefig('pmu_latency_std.pdf', bbox_inches='tight', dpi=300)
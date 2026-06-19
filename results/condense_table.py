import pandas as pd

# 1. Define your files and labels
files = {
    'L2-DVH': 'pmu_micro_dvh.csv',
    'L2': 'pmu_micro_no_dvh.csv',
    'L1': 'pmu_micro_l1.csv'
}

# 2. Read and combine
df_list = []
for config_name, file_path in files.items():
    temp_df = pd.read_csv(file_path)
    temp_df['Configuration'] = config_name
    df_list.append(temp_df)

df_raw = pd.concat(df_list, ignore_index=True)

# 3. Aggregate: Group by Test and Configuration (Mean only)
df_summary = df_raw.groupby(['Test', 'Configuration'])['Cycles'].mean().reset_index()

# 4. Pivot: Make it "wide" format
df_table = df_summary.pivot(index='Test', columns='Configuration', values='Cycles')

# 5. Output to LaTeX
latex_table = df_table.to_latex(
    float_format="%.0f",  # Using %.0f because cycle counts are typically integers
    caption="MSR Microbenchmark Performance (Average Cycles)",
    label="msr_t"
)

print(latex_table)
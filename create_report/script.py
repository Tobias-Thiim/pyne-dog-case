from google.cloud import bigquery
import pandas as pd
import matplotlib.pyplot as plt

project_id = "pyne-dogs-ttm-cles"  # dit projekt
client = bigquery.Client(project=project_id)

sql = """
SELECT
  breed_name,
  lifespan_years_avg,
  weight_class
FROM `pyne-dogs-ttm-cles.<DIT_DATASET>.fact_weight_life_span`
ORDER BY lifespan_years_avg DESC
LIMIT 10
"""

df = client.query(sql).to_dataframe()

# Gem tabel som HTML
df.to_html("top10_lifespan.html", index=False)

# Simpelt bar chart
plt.figure()
plt.bar(df["breed_name"], df["lifespan_years_avg"])
plt.xticks(rotation=45, ha="right")
plt.ylabel("År")
plt.title("Top 10 hunderacer efter gennemsnitlig levetid")
plt.tight_layout()
plt.savefig("top10_lifespan.png")

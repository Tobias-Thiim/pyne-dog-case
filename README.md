# Pyne Dog Case

End-to-end demo: model a dog breeds dataset in BigQuery using dbt and generate a reproducible HTML report from a Jupyter notebook.

## What this delivers
- dbt models: staging, dim_breed, fact_weight_life_span
- Automated HTML report with tables and charts
- GitHub Actions CI/CD that runs dbt and regenerates the report

## Repository structure (key parts)
```
dog_pyne_dbt/
├─ create_report/
│  ├─ report.ipynb        # Queries BigQuery and produces HTML output
│  ├─ script.py           # Optional runner
│  ├─ requirements.txt    # Report env (nbconvert, BigQuery libs)
│  └─ output/
│     └─ report.html      # Generated report
├─ models/                # dbt models
├─ macros/                # (optional dbt macros)
├─ tests/                 # dbt schema tests
├─ dbt_project.yml
├─ .dbt/profiles.yml      # Local profile (ignored in CI)
└─ .github/workflows/
   ├─ ci_cd.yml           # dbt run/test in dev/prod
   └─ report.yml          # Execute notebook and commit report
```

## Prerequisites
- Google Cloud project with BigQuery enabled
- Service account with access to read the dataset (and run jobs)
- Python 3.11+ (tested with 3.13)
- BigQuery dataset holding the models (e.g., bronze_prod)

## Local setup
1) Create and activate a virtual environment
- PowerShell:
  ```
  python -m venv .venv
  .\.venv\Scripts\Activate.ps1
  ```
- Bash:
  ```
  python -m venv .venv
  source .venv/bin/activate
  ```

2) Install dependencies
```
pip install -r create_report/requirements.txt
pip install dbt-bigquery
```

3) Authenticate to GCP
- PowerShell:
  ```
  $env:GOOGLE_APPLICATION_CREDENTIALS="C:\path\to\gcp_key.json"
  ```
- Bash:
  ```
  export GOOGLE_APPLICATION_CREDENTIALS="/path/to/gcp_key.json"
  ```

4) Configure dbt profile (local)
- Ensure .dbt/profiles.yml points to your GCP project and dataset.

## Running dbt locally
From the dog_pyne_dbt directory:
```
dbt deps
dbt run
dbt test
```

## Generate the HTML report locally
From the dog_pyne_dbt directory:
```
jupyter nbconvert --execute --to html --no-input create_report\report.ipynb --output report.html --output-dir create_report\output
```
Notes:
- The notebook auto-detects the GCP project via your GOOGLE_APPLICATION_CREDENTIALS.
- Update the DATASET variable in the notebook if your tables live elsewhere.

## CI/CD (GitHub Actions)
- .github/workflows/ci_cd.yml
  - Runs dbt deps/run/test in dev on PRs; in prod on push to main.
- .github/workflows/report.yml
  - Installs Python deps, authenticates to GCP, executes the notebook, and commits create_report/output/report.html.

Required secret:
- GCP_SA_KEY: JSON contents of the service account key (used by both workflows).

## Data model (high level)
- dim_breed: Breed attributes (name, group, temperament, family-friendly flag).
- fact_weight_life_span: Min/Max/Avg weight and lifespan + weight class.
- Staging models clean and standardize raw inputs.

## Troubleshooting
- BigQuery auth errors: ensure GOOGLE_APPLICATION_CREDENTIALS is set and the service account has BigQuery Data Viewer and BigQuery Job User roles.
- nbconvert ZMQ warning on Windows:
  - Harmless. To silence, you can add to the top of report.ipynb before execution:
    ```
    import asyncio
    try:
        asyncio.set_event_loop_policy(asyncio.WindowsSelectorEventLoopPolicy())
    except Exception:
        pass
    ```
- Empty report tables: confirm dbt run completed and DATASET matches where models were materialized.

## Updating the report
- Edit create_report/report.ipynb (queries, visuals, formatting).
- Commit and push the report workflow will regenerate and commit the updated HTM:
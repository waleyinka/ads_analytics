# ads_analytics/docs/setup_commands.sh

#!/usr/bin/env bash
# =============================================================================
# ads_analytics: project setup commands (reference)
# -----------------------------------------------------------------------------
# What this file is: every command used to scaffold this repo, in order, with
# a note on what each one does and why. Keep it in the repo (e.g. docs/) as a
# record of how the project was set up.
#
# How to use it: run the commands one at a time from the root of an empty,
# cloned repo folder. Read each comment first; the point is to know what
# every step does, not to run the file blind.
#
# Versions checked on PyPI on 2026-10-16:
#   dbt-databricks 1.12.7 (installs dbt-core 1.12.x)
#   elementary-data 0.26.1
# =============================================================================


# -----------------------------------------------------------------------------
# 1. Python project
# -----------------------------------------------------------------------------

# Create a minimal Python project: only pyproject.toml, with no sample code,
# README or git setup. --name is the package name in pyproject.toml.
# --python 3.12 records the supported Python version (requires-python).
uv init --bare --name ads-analytics --python 3.12

# Write .python-version so that uv, your editor and CI all use Python 3.12.
# Needed because --bare skips creating this file.
uv python pin 3.12


# -----------------------------------------------------------------------------
# 2. Runtime dependencies (needed to build the models)
# -----------------------------------------------------------------------------

# dbt plus the Databricks adapter. dbt-core is installed automatically.
# "~=1.12.0" allows 1.12.x patch fixes but never jumps to 1.13, so your laptop
# and CI cannot silently drift onto a different dbt version.
uv add "dbt-databricks~=1.12.0"

# Elementary's CLI ("edr"). It reads test results from the warehouse and
# builds the observability HTML report. The [databricks] extra adds the
# Databricks connector.
# Keep this version aligned with the Elementary dbt package version in
# packages.yml: mismatched versions are the most common Elementary error.
uv add "elementary-data[databricks]~=0.26.0"


# -----------------------------------------------------------------------------
# 3. Development-only dependencies (never needed in production)
# -----------------------------------------------------------------------------

# --dev puts these in a separate group, so a production install can skip them.
#   sqlfluff                 SQL linter and formatter (used in CI in Phase 9)
#   sqlfluff-templater-dbt   lets sqlfluff understand Jinja, ref() and source()
#   pre-commit               runs the linter automatically before each commit
uv add --dev sqlfluff sqlfluff-templater-dbt pre-commit


# -----------------------------------------------------------------------------
# 4. Check the installs
# -----------------------------------------------------------------------------

# "uv run" runs a command inside the project's virtual environment (.venv)
# without activating it first.
uv run dbt --version      # should list dbt-core 1.12.x and databricks 1.12.x
uv run edr --version      # should show 0.26.x


# -----------------------------------------------------------------------------
# 5. dbt project skeleton
# -----------------------------------------------------------------------------

# Create the dbt project: dbt_project.yml plus the models/, tests/, seeds/,
# macros/, snapshots/ and analyses/ folders.
# --skip-profile-setup stops dbt from asking for credentials and writing them
# to ~/.dbt/profiles.yml. You will write your own profiles.yml that reads
# every secret from environment variables (Phase 2).
uv run dbt init ads_analytics --skip-profile-setup


# Delete the example models dbt generates.
rm -rf models/example
# Also delete the "example:" block under "models:" at the bottom of
# dbt_project.yml.


# -----------------------------------------------------------------------------
# 6. Keep secrets and build output out of git
# -----------------------------------------------------------------------------

# dbt's generated .gitignore already covers target/, dbt_packages/ and logs/.
# Add the uv virtual environment and your local secrets file.
cat >> .gitignore <<'EOF'
.venv/
.env
EOF

# Create the local secrets file. It is git-ignored, so the values never leave
# your machine. Fill in your real values; profiles.yml will read them through
# env_var().
cat > .env <<'EOF'
DBT_PROFILES_DIR=dbt
DATABRICKS_HOST=
DATABRICKS_HTTP_PATH=
DATABRICKS_TOKEN=
EOF


# -----------------------------------------------------------------------------
# 7. First commit
# -----------------------------------------------------------------------------

# Commit the lockfile (uv.lock) and .python-version. CI can then run
# "uv sync --frozen" and get exactly the environment you have locally.
git add pyproject.toml uv.lock .python-version .gitignore dbt_project.yml \
        models analyses macros seeds snapshots tests README.md
git commit -m "chore: scaffold ads_analytics dbt project with uv"


# -----------------------------------------------------------------------------
# 8. Next steps (Phase 2 of the plan, after profiles.yml exists)
# -----------------------------------------------------------------------------

# Install the dbt packages listed in packages.yml (dbt_utils, elementary).
uv run --env-file .env dbt deps

# Test the connection to Databricks using the dev target.
# --env-file loads .env, so the secrets become environment variables only
# for this one command.
uv run --env-file .env dbt debug --target dev
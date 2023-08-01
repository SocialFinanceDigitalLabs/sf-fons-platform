from dagster import repository
from sync.jobs.liia import liia
from sync.jobs.sync_code import sync_code


@repository
def sync():
    """
    The repository definition for this etl Dagster repository.

    For hints on building your Dagster repository, see our documentation overview on Repositories:
    https://docs.dagster.io/overview/repositories-workspaces/repositories
    """
    jobs = [sync_code, liia]
    schedules = []
    sensors = []

    return jobs + schedules + sensors
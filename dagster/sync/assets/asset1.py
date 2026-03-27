from dagster import asset

@asset
def load_fixtures():
    """
    Load static data for processing
    :return:
    """
    return
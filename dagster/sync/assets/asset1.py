from dagster import asset
import decouple

@asset
def load_fixtures():
    """
    Load static data for processing
    :return:
    """
    return
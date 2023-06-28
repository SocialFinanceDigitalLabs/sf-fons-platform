from dagster import job
import decouple

@job
def sync_code():
    """
    Dummy function for now. But this will use the filesystem copy to copy any definitions
    from a specified location Does nothing at this moment.
    :return:
    """
    return
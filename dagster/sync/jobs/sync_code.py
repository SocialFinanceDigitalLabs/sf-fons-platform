from dagster import job
from sync.assets.asset1 import load_fixtures
from sync.ops.ops1 import ingest_data, merge, clean, validate, egress
import decouple

@job
def sync_code():
    """
    Dummy function for now. But this will use the filesystem copy to copy any definitions
    from a specified location Does nothing at this moment.
    :return:
    """
    static_data = load_fixtures()
    data = ingest_data()
    data = merge(data, static_data)
    data = clean(data)
    data = validate(data)
    data = egress(data)
    return
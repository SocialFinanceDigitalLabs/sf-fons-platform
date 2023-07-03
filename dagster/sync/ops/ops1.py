from dagster import op
import decouple

@op
def ingest_data():
    """
    Import data
    :return:
    """
    return

@op
def merge(data1, data2):
    """
    combines data together
    :return:
    """
    return

@op
def clean(data1, data2):
    """
    cleans the data
    :return:
    """
    return

@op
def validate(data1):
    """
    Validates against a schema
    :return:
    """
    return

@op
def egress(data):
    """
    Outputs result to storage
    :param data:
    :return:
    """
    return
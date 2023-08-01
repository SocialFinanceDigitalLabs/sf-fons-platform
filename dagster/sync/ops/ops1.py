from dagster import op
from sfdata_stream_parser.parser import openpyxl
from dagster import op

@op
def ingest_data():
    """
    Import data
    :return:
    """
    return {}

@op
def merge(data, static_data):
    """
    combines data together
    :return:
    """
    return data

@op
def clean(data):
    """
    cleans the data
    :return:
    """
    return data

@op
def validate(data):
    """
    Validates against a schema
    :return:
    """
    return data

@op
def egress(data):
    """
    Outputs result to storage
    :param data:
    :return:
    """
    return data
from dagster import Out, op
from pathlib import Path
from sfdata_stream_parser.parser import openpyxl

from liiatools.datasets.shared_functions.common import (
    flip_dict,
    check_file_type,
    supported_file_types,
)

from liiatools.datasets.annex_a.lds_annexa_clean import (
    configuration as clean_config,
    cleaner,
    degrade,
    logger,
    populate,
)

FILE_LOCATION = "./sync/files/Annex_A.xlsx"
LA_CODE = "BRE"
OUTPUT_DIR = "./sync/files"


@op(
    out={
        "filename": Out(),
        "liia_config": Out(),
        "la_name": Out(),
        "LA_CODE": Out(),
        "FILE_LOCATION": Out(),
        "OUTPUT_DIR": Out(),
    }
)
def configure_init():
    filename = Path(FILE_LOCATION).resolve().stem
    liia_config = clean_config.Config()
    la_name = flip_dict(liia_config["data_codes"])[LA_CODE]
    if (
        check_file_type(
            FILE_LOCATION,
            file_types=[".xlsx", ".xlsm"],
            supported_file_types=supported_file_types,
            la_log_dir=OUTPUT_DIR,
        )
        == "incorrect file type"
    ):
        return None, None, None, None, None

    return filename, liia_config, la_name, LA_CODE, FILE_LOCATION, OUTPUT_DIR


@op
def parse_file(file_location):
    """
    Import data
    :return:
    """
    stream = openpyxl.parse_sheets(file_location)
    return stream


@op
def add_stream_attributes(stream, filename, la_code):
    """
    combines data together
    :return:
    """
    return [ev.from_event(ev, la_code=la_code, filename=filename) for ev in stream]


@op
def promote_first_row(stream):
    """
    cleans the data
    :return:
    """
    return promote_first_row(stream)


@op
def configure_stream(stream, liia_config):
    """
    Validates against a schema
    :return:
    """
    return clean_config.configure_stream(stream, liia_config)


@op
def clean_stream(stream):
    """
    Outputs result to storage
    :param data:
    :return:
    """
    return cleaner.clean(stream)


@op
def degrade_stream(stream):
    """
    Outputs result to storage
    :param data:
    :return:
    """
    return degrade.degrade(stream)


@op
def log_errors(stream):
    """
    Outputs result to storage
    :param data:
    :return:
    """
    return logger.log_errors(stream)


@op
def create_la_child_id(stream, la_code):
    """
    Outputs result to storage
    :param data:
    :return:
    """
    return populate.create_la_child_id(stream, la_code=la_code)

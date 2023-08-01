from dagster import job
from pathlib import Path

# from liiatools.datasets.annex_a.annex_a_cli import cleanfile
from sfdata_stream_parser.parser import openpyxl
from ..ops.liia import (
    parse_file,
    add_stream_attributes,
    promote_first_row,
    configure_init,
    configure_stream,
    clean_stream,
    degrade_stream,
    log_errors,
    create_la_child_id,
)

from liiatools.datasets.annex_a.lds_annexa_clean import (
    configuration as clean_config,
    cleaner,
    degrade,
    logger,
    populate,
    file_creator,
)
from liiatools.datasets.shared_functions.common import (
    flip_dict,
    check_file_type,
    supported_file_types,
)

from sfdata_stream_parser.filters.column_headers import promote_first_row


@job
def liia():
    """
    Running liia tools on Dagster
    :return:
    """

    (
        filename,
        liia_config,
        la_name,
        la_code,
        file_location,
        output_dir,
    ) = configure_init()
    # Open & Parse file
    stream = parse_file(file_location)
    stream = add_stream_attributes(stream, filename, la_code)
    stream = promote_first_row(stream)

    # Configure Stream
    # stream = configure_stream(stream, liia_config)

    # Clean stream
    stream = clean_stream(stream)
    stream = degrade_stream(stream)
    stream = log_errors(stream)
    stream = create_la_child_id(stream, la_code=la_code)

    # Output result
    """stream = file_creator.save_stream(stream, la_name, output_dir)
    stream = logger.save_errors_la(stream, la_log_dir=output_dir)"""
    return

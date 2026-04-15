#!/usr/bin/env python3
import logging
import re

def logging_configuration(base_logger_level="INFO", script_logger_level="DEBUG") -> logging.Logger:
    log_level_options = [ "NOTSET", "DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL" ]
    if base_logger_level not in log_level_options:
        raise ValueError(f"Error: base_logger_level is: \"{base_logger_level}\" and must be one of: {log_level_options}")
    if script_logger_level not in log_level_options:
        raise ValueError(f"Error: script_logger_level is: \"{script_logger_level}\" and must be one of: {log_level_options}")

    # Configure root logger to INFO (to suppress other libraries' debug logs)
    logging.basicConfig(level=base_logger_level, format='%(asctime)s %(levelname)s: %(message)s', datefmt='%d-%b-%y %H:%M:%S')

    logger = logging.getLogger(__name__)
    logger.setLevel(script_logger_level)

    logger.info(f"Base logger is set to: \"{base_logger_level}\"")
    logger.info(f"Script logger is set to: \"{script_logger_level}\"")

    return logger

def get_regions(ec2_client, selected_regions: str = "", exclude_regions: str = "", all_regions: bool = False) -> list[str]:
    """
    session = boto3.Session(profile_name='my-profile')
    ec2_client = session.client('ec2')
    get_regions(ec2_client)
    """
    def _parse_regions(regions: str) -> set[str]:
        return set([r for r in re.split(r'[,\s]+', regions) if r.strip()])

    if selected_regions:
        selected_regions_list = _parse_regions(selected_regions)
        regions = selected_regions_list
    else:
        response = ec2_client.describe_regions(AllRegions=all_regions)
        regions = set([r['RegionName'] for r in response['Regions']])
    
    if exclude_regions:
        exclude_regions_list = _parse_regions(exclude_regions)
        regions = regions - exclude_regions_list
    
    return sorted(regions) # sort returns a list

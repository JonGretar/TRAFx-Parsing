import re
from datetime import datetime

def parse(data):
    logs = data.split("Counter log start")[1:]  # Remove initial data before the first counter log start
    return [parse_log(log) for log in logs]

def parse_log(log):
    lines = log.strip().split("\n")
    count_record_pattern = re.compile(r"^\d{2}-\d{2}-\d{2},\d{2}:\d{2},\d+$")

    result = {
        "counts": {}
    }

    for line in lines:
        if "Serial Number" in line:
            result["serial_number"] = line.split(":")[-1].strip()
        elif "Counter name" in line:
            result["counter_name"] = line.split(":")[-1].strip()
        elif "Mode" in line:
            result["mode"] = line.split(":")[-1].strip()
        elif "Batt. voltage" in line:
            result["battery_voltage"] = float(line.split(":")[-1].strip())
        elif "Stored records" in line:
            result["stored_records"] = int(line.split(":")[-1].strip())
        elif count_record_pattern.match(line):
            date_str, time_str, count = line.split(",")
            date = datetime.strptime("20" + date_str + " " + time_str, "%Y-%m-%d %H:%M")
            result["counts"][date] = int(count)

    return result

def combine_counts_with_name(parsed_data):
    combined_counts = []

    for counter_data in parsed_data:
        counter_name = counter_data["counter_name"]
        for date, count in counter_data["counts"].items():
            combined_counts.append(f"{counter_name}, {date.strftime('%Y-%m-%d %H:%M')}, {count}")

    return combined_counts

data = """
<your provided data dump here>
"""
parsed_data = parse(data)
combined_data = combine_counts_with_name(parsed_data)
print(combined_data)

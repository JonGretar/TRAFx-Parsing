library(stringr)
library(lubridate)

parse_data <- function(data) {
  logs <- str_split(data, "Counter log start")[[1]][-1]
  lapply(logs, parse_log)
}

parse_log <- function(log) {
  lines <- str_trim(unlist(str_split(log, "\n")))
  count_record_pattern <- "^\\d{2}-\\d{2}-\\d{2},\\d{2}:\\d{2},\\d+$"

  result <- list(counts = list())

  for (line in lines) {
    if (str_detect(line, "Serial Number")) {
      result$serial_number <- str_trim(str_split(line, ":")[[1]][2])
    } else if (str_detect(line, "Counter name")) {
      result$counter_name <- str_trim(str_split(line, ":")[[1]][2])
    } else if (str_detect(line, "Mode")) {
      result$mode <- str_trim(str_split(line, ":")[[1]][2])
    } else if (str_detect(line, "Batt. voltage")) {
      result$battery_voltage <-
        as.numeric(str_trim(str_split(line, ":")[[1]][2]))
    } else if (str_detect(line, "Stored records")) {
      result$stored_records <-
        as.integer(str_trim(str_split(line, ":")[[1]][2]))
    } else if (str_detect(line, count_record_pattern)) {
      parts <- str_split(line, ",")[[1]]
      date <- ymd_hm(paste0("20", parts[1], " ", parts[2]))
      count <- as.integer(parts[3])
      result$counts[[date]] <- count
    }
  }

  return(result)
}

combine_counts_with_name <- function(parsed_data) {
  combined_counts <- c()

  for (counter_data in parsed_data) {
    counter_name <- counter_data$counter_name

    for (date in names(counter_data$counts)) {
      count <- counter_data$counts[[date]]
      combined_counts <- append(
        combined_counts,
        paste(counter_name, date, count, sep = ", ")
      )
    }
  }

  return(combined_counts)
}

data <- '
<your provided data dump here>
'
parsed_data <- parse_data(data)
combined_data <- combine_counts_with_name(parsed_data)
print(combined_data)

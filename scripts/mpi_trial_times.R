# Read MPI deployment dates and apply the verified participant identity mapping.
read_mpi_study_dates <- function(path, corrections, audit_path = NULL) {
  study_dates <- readxl::read_excel(path)
  mapping <- readr::read_csv(
    corrections,
    col_types = readr::cols(.default = readr::col_character()),
    show_col_types = FALSE
  )
  required <- c(
    "logger_serial",
    "trial_start",
    "trial_end",
    "previous_Id",
    "corrected_Id",
    "historical_commit"
  )
  stopifnot(all(required %in% names(mapping)))
  deployment_key <- paste(
    study_dates$light_logger_serial_no,
    format(study_dates$datetime_trial_start, "%Y-%m-%d %H:%M:%S", tz = "UTC"),
    format(study_dates$datetime_trial_end, "%Y-%m-%d %H:%M:%S", tz = "UTC")
  )
  reference_key <- paste(
    mapping$logger_serial,
    mapping$trial_start,
    mapping$trial_end
  )
  if (
    anyDuplicated(deployment_key) ||
      anyDuplicated(reference_key) ||
      !setequal(deployment_key, reference_key)
  ) {
    stop(
      "MPI deployments do not match the verified serial-number/date mapping",
      call. = FALSE
    )
  }
  mapping <- mapping[match(deployment_key, reference_key), ]
  valid_id <- study_dates$subjectID_device == mapping$previous_Id |
    study_dates$subjectID_device == mapping$corrected_Id
  if (
    anyNA(valid_id) ||
      !all(valid_id) ||
      anyDuplicated(mapping$corrected_Id) ||
      !all(grepl("^MPI_S[0-9]{3}$", mapping$corrected_Id))
  ) {
    stop(
      "MPI participant IDs differ from both the documented original and corrected IDs",
      call. = FALSE
    )
  }
  if (!is.null(audit_path)) {
    dir.create(dirname(audit_path), recursive = TRUE, showWarnings = FALSE)
    utils::write.csv(
      data.frame(
        workbook_row = seq_len(nrow(study_dates)) + 1L,
        previous_Id = mapping$previous_Id,
        corrected_Id = mapping$corrected_Id,
        logger_serial = study_dates$light_logger_serial_no,
        historical_commit = mapping$historical_commit,
        changed = mapping$previous_Id != mapping$corrected_Id
      ),
      file = audit_path,
      row.names = FALSE
    )
  }
  study_dates$subjectID_device <- mapping$corrected_Id
  study_dates
}

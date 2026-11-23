# Parse the explicit timestamp formats used in MPI exports and resolve repeats.

parse_mpi_timestamp <- function(x, timezone = "Europe/Berlin") {
  if (!is.character(x)) {
    stop("MPI timestamps must be imported as character strings.", call. = FALSE)
  }
  parsed <- lubridate::parse_date_time(
    x,
    orders = c(
      "%Y-%m-%d %H:%M:%S",
      "%Y-%m-%d %H:%M",
      "%d.%m.%Y %H:%M:%S",
      "%d.%m.%Y %H:%M"
    ),
    exact = TRUE,
    tz = timezone,
    quiet = TRUE
  )
  if (any(!is.na(x) & nzchar(trimws(x)) & is.na(parsed))) {
    stop(
      "MPI timestamps contain an unrecognised or invalid date-time format.",
      call. = FALSE
    )
  }
  parsed
}

select_latest_mpi_confidence <- function(data, timezone = "Europe/Berlin") {
  stopifnot(all(
    c("record_id", "startdate", "enddate", "mhlea_confidence") %in% names(data)
  ))
  submissions <- data |>
    dplyr::mutate(
      .audit_row = dplyr::row_number(),
      Date = as.Date(.data$startdate, tz = timezone) -
        as.integer(
          lubridate::hour(lubridate::with_tz(.data$startdate, timezone)) < 14L
        ),
      submitted_at = dplyr::coalesce(.data$enddate, .data$startdate)
    )
  if (anyNA(submissions$Date) || anyNA(submissions$submitted_at)) {
    stop(
      "A confidence submission lacks a usable diary date or submission time.",
      call. = FALSE
    )
  }
  latest <- submissions |>
    dplyr::group_by(.data$record_id, .data$Date) |>
    dplyr::filter(.data$submitted_at == max(.data$submitted_at))
  ties <- latest |>
    dplyr::summarise(
      ratings = dplyr::n_distinct(.data$mhlea_confidence),
      .groups = "drop"
    )
  if (any(ties$ratings > 1L)) {
    stop(
      "Conflicting confidence ratings have the same latest submission time; resolve the tie before export.",
      call. = FALSE
    )
  }
  selected <- latest |>
    dplyr::arrange(.data$startdate, .data$.audit_row) |>
    dplyr::slice_tail(n = 1L) |>
    dplyr::ungroup()
  submissions$selected <- submissions$.audit_row %in% selected$.audit_row
  list(
    selected = dplyr::select(
      selected,
      -dplyr::any_of(c(".audit_row", "submitted_at"))
    ),
    submissions = submissions
  )
}

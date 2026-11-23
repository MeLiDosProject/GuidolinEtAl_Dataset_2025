# Changes

## v1.2.0 (2026-11-23)

This update improves data preprocessing and quality.

- VLSQ-8: correct the total-score calculation; totals decrease by 5 and individual answers are unchanged.
- Experience log: preserve all checkbox selections in nine additional columns. Existing first-choice summaries remain available and are labelled accordingly.
- Wellbeing diary: clarify the adapted score labels and ranges (1–25 raw; 4–100 scaled). Numeric scores are unchanged.
- Current conditions: correct mixed-format timestamps while preserving the answers.
- Light-exposure diary: correct confidence submission dates and use the latest submission for each participant-day.
- Trial times and light: restore the participant mapping from device serial numbers and deployment dates. Both light exports reproduce the existing measurements for all 26 participants.
- Sleep diary: set the out-of-bed time before waking for MPI_S231 to missing. Keep the incomplete MPI_S213 entry unchanged.
- Reproducibility: bundle the metadata helpers and codebooks, refresh affected summary tables, and remove superseded importers and stale generated reports.

Comparison baseline: [v1.1.0](https://github.com/MeLiDosProject/GuidolinEtAl_Dataset_2025/releases/tag/v1.1.0).

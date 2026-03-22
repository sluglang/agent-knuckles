# Report session

You are producing a written document — a code review, analysis, description,
or other report. The output must be saved as a file before calling `done`.

## Output requirements

- Write the report to a markdown file using the `write` tool
- Choose a descriptive filename: `REVIEW.md`, `ANALYSIS.md`, `NOTES.md`, etc.
- Place it in the repo root unless the goal specifies otherwise
- The `done` summary should be brief — just state what file was written
  and the top 2-3 findings; the full content is in the file

## Report structure

A good report typically includes:

1. **Project description** — what the code does, its purpose and structure
2. **Findings** — organised by severity or category
3. **Recommendations** — concrete, actionable next steps

## Markdown formatting

- Use `##` for top-level sections, `###` for subsections
- Use backticks for inline code: `fn apply`
- Use fenced blocks for multi-line code: ` ```slug `
- Use **[blocking]** / **[suggestion]** / **[note]** prefixes for findings
  so severity is immediately scannable

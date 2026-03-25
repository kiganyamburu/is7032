# IS7032 Assignment Workspace

This repository contains materials for **IS7032 logical model validation** and SQL deliverables.

## Project Purpose

The work covers two connected parts:

- **Part A (SQL/DDL):** PostgreSQL implementation of the assignment schema and constraints.
- **Part B (Model Validation):** Validated logical modeling artifacts:
  - Directed-arc model
  - Dependency diagrams
  - Information-preserving logical model

## Key Files

### Core Deliverables

- `IS7032_A4_solution_postgres.sql` — SQL DDL solution (tables, PK/FK, constraints).
- `IS7032_instructions_deliverable.txt` — Main written deliverable for the 3 validation sections.
- `IS7032_A4.txt` — Assignment-related text content.

### Final/Combined Submission Drafts

- `IS7032_Final_Submission.txt`
- `IS7032_Combined_Submission.txt`

### Guidance and Checklist

- `instructions.txt` — Assignment instructions for sections 1–3.
- `IS7032_submission_checklist.txt` — Submission checklist and quality checks.

### Diagram Source + Rendered Outputs

- `Figure1_Validated_DirectedArc.mmd` / `Figure1_Validated_DirectedArc.html`
- `Figure2_Validated_DependencyDiagrams.mmd` / `Figure2_Validated_DependencyDiagrams.html`
- `Figure3_Validated_InformationPreservingModel.mmd` / `Figure3_Validated_InformationPreservingModel.html`
- `FigurePack_PartB_All3.mmd` / `FigurePack_PartB_All3.html`

## Semantic Integrity Constraints (Current)

- `EMPLOYEE.emp_gender IN ('M','F','O')`
- `ASSIGNMENT.asg_hours > 1`
- A manager is assigned to any internal project they manage.

## How to Use This Workspace

1. Open the `.html` files in a browser to review exported diagrams.
2. Edit `.mmd` files if diagram updates are needed.
3. Review `IS7032_submission_checklist.txt` before final submission.
4. Use `IS7032_A4_solution_postgres.sql` to run/create the database objects.

## Suggested Submission Bundle

- `IS7032_A4_solution_postgres.sql`
- `IS7032_instructions_deliverable.txt`
- Required screenshots (tables list, query output)
- Diagram images/exports required by your instructor

## Notes

- If LMS/instructor instructions differ from local checklist text, follow the instructor/LMS requirements first.
- Keep file names unchanged when submitting unless your instructor asks otherwise.
- Keep file names unchanged when submitting unless your instructor asks otherwise.

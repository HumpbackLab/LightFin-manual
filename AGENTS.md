# AGENT GUIDELINES FOR FLIGHT-MANUAL REPOSITORY

This document provides guidelines for AI agents operating within the `flight-manual` Typst project. The goal is to ensure consistency, maintainability, and efficiency in agentic code generation and modifications. Adhering to these guidelines will help in producing high-quality, predictable, and easily auditable changes within the codebase.

## 1. Project Overview

*   **Technology Stack**: This repository primarily utilizes Typst, a modern markup language for typesetting. All document-related tasks will involve `.typ` files.
*   **Primary Document**: The main entry point for the document compilation is `main.typ`.
*   **Output**: The final compiled output of the project is `main.pdf`.
*   **Purpose**: This project appears to be a "flight manual," suggesting a focus on clarity, accuracy, and structured documentation. Agents should prioritize these aspects in all modifications.

## 2. Build / Compilation Commands

For Typst projects, the "build" process typically refers to compiling the `.typ` source files into a `.pdf` document.

*   **Compile `main.typ` to PDF**: To generate the primary output document, use the following command:
    ```bash
    typst compile main.typ
    ```
    This command will process `main.typ` and any imported modules, producing `main.pdf` in the same directory.
    *   **Prerequisites**: Ensure the `typst` CLI is installed and accessible in the system's PATH.
    *   **Error Handling**: Agents should monitor the output of this command. Any compilation errors or warnings should be addressed immediately. A successful compilation is indicated by an exit code of `0` and no critical error messages in the console output.

*   **Running a Single "Test"**: Typst does not have a traditional unit testing framework. The equivalent of "running a single test" involves:
    1.  **Isolating changes**: If working on a specific section or module, agents should focus their review on that area.
    2.  **Recompilation**: Run `typst compile main.typ` after making changes.
    3.  **Visual Verification**: Open and meticulously review the generated `main.pdf` to ensure the changes are rendered as expected and have not introduced any regressions or visual artifacts in other parts of the document. This is the primary form of "testing" in Typst.
    4.  **Content Accuracy**: Verify that the content, formatting, and layout conform to the intended design and information conveyed.

## 3. Lint / Static Analysis / Type Checking

Typst, by its nature, handles many aspects of typesetting directly. However, agents should still adhere to practices that ensure code quality and correctness.

*   **Linting/Static Analysis**: While there isn't a dedicated linter for Typst (like ESLint for JavaScript), agents should enforce:
    *   **Consistent Syntax**: Adherence to the official Typst syntax.
    *   **Idiomatic Usage**: Preferring standard and efficient Typst patterns over convoluted or less readable alternatives.
    *   **Code Duplication**: Avoid unnecessary repetition of styling or layout logic; leverage variables and functions.
*   **Type Checking**: Typst has a built-in type system for its functions and values. Agents must ensure:
    *   **Correct Function Arguments**: All built-in and custom Typst functions are called with the correct number and type of arguments.
    *   **Variable Usage**: Variables are used consistently with their intended types (e.g., length, color, content).
    *   **Semantic Correctness**: Changes should maintain the logical flow and integrity of the document structure.

## 4. Code Style Guidelines (Typst Specific)

Consistency in code style is paramount for collaborative projects.

*   **Formatting**:
    *   **Indentation**: Use 2 spaces for indentation within Typst blocks (`#let`, `#show`, `#set`, etc.).
    *   **Line Length**: Aim for a maximum of 100 characters per line for `.typ` source files to enhance readability, especially in pull requests.
    *   **Whitespace**:
        *   Maintain consistent spacing around operators (e.g., `1 + 2`, not `1+2`).
        *   Space after `#` for keywords (e.g., `#let`, `#show`, `#set`).
        *   Blank lines to separate logical blocks of code or distinct styling rules.
*   **Naming Conventions**:
    *   **Variables**: Use `kebab-case` for variable names (e.g., `#let page-margin = ...`).
    *   **Custom Functions**: Use `snake_case` for custom function names (e.g., `#let generate_title_page(..) = ...`).
    *   **Labels**: Use descriptive `kebab-case` for labels and references (e.g., `<introduction-section>`).
*   **Imports (`#import`)**:
    *   **Ordering**: Imports should be grouped logically. Typically, project-specific modules come first, followed by third-party Typst packages.
    *   **Absolute vs. Relative Paths**: For modules within this repository, prefer relative paths (e.g., `#import "components/header.typ"`). For external packages, use their specified import paths.
    *   **Alias**: Use explicit aliases for clarity when importing (e.g., `#import "utils.typ": utils`).
*   **Comments**:
    *   **Single-line**: Use `//` for brief inline comments or to explain a single line of code.
    *   **Multi-line/Block**: Use `/* ... */` for explaining complex logic, document structure, or temporary commented-out sections.
    *   **Purpose**: Comments should explain *why* something is done, not just *what* it does (unless the *what* is not immediately obvious).
*   **Modularity and Structure**:
    *   **Main File**: `main.typ` should primarily orchestrate the document structure and import other modules. It should contain minimal direct content or styling.
    *   **Component/Module Separation**: Break down the document into logical `.typ` files (e.g., `sections/chapter1.typ`, `styles/layout.typ`, `components/figure.typ`). This enhances readability, reusability, and maintainability.
    *   **Declarative over Imperative**: Where possible, prefer declarative Typst features (e.g., `#show` rules, `#set` rules) to define styling and layout over imperative manipulation.

## 5. Cursor / Copilot Rules (No specific rules found)

A search for `.cursor/rules/`, `.cursorrules`, or `.github/copilot-instructions.md` yielded no results. This indicates that there are currently no explicit agent-specific rules configured through these tools within this repository. Therefore, agents should adhere strictly to the general guidelines outlined in this `AGENTS.md` and leverage their general knowledge of best practices for code generation and modification. If such configuration files are introduced in the future, agents should incorporate and prioritize those rules accordingly.

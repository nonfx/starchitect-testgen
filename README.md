# Regula Testgen Action

This GitHub Action automates test generation using AI models. It supports both initial test generation and updates via PR comments.

## Action Inputs

| Input | Description | Required | 
|-------|-------------|----------|
| `input_file_path` | Path to the input CSV file containing test cases | Yes |
| `output_file_path` | Directory where generated test files will be stored | Yes |
| `pipeline_token` | Authentication token for the pipeline | Yes |
| `anthropic_api_key` | API key for Claude AI model access | Yes |
| `openai_api_key` | API key for OpenAI model access | Yes |
| `pr_workflow` | Workflow type to execute ('pr' for main PR creation or 'comment' for PR comment updates) | Yes |

## Setup Instructions

1. **Prepare Test Data**
   Create a CSV file in the following format at `./test-data/data.csv`:
   ```csv
   "title","urls","description","status""dms-auto-minor-version-upgrade-check","https://docs.aws.amazon.com/config/latest/developerguide/dms-auto-minor-version-upgrade-check.html","","TODO"
   ```
If you have multiple urls add them inside double quotes separated by comma. for ex.
   "https://example.com/url1,https://example.com/url2,https://example.com/url3"
   

2. **Configure Workflow Files**
   
   Add two workflow files to your repository under `.github/workflows/`:

   a. `regogen.yml` for initial test generation:
   ```yaml
   name: Regula codegen Workflow
   on:
     workflow_dispatch:
   
   permissions:
     contents: write
     pull-requests: write
     issues: write
   
   jobs:
     test:
       runs-on: ubuntu-latest
       name: Starchitect Testgen Job
       steps:
         - uses: actions/checkout@v2
           with:
             fetch-depth: 0
   
         - name: Run starchitect Test Agent
           uses: nonfx/starchitect-testgen@main
           with:
             input_file_path: "./test-data/data.csv"
             output_file_path: "./test-output"
             pipeline_token: ${{ secrets.PIPELINE_TOKEN }}
             anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
             openai_api_key: ${{ secrets.OPENAI_API_KEY }}
             pr_workflow: "pr"
   ```

   b. `pr-comment.yml` for handling PR comment updates:
   ```yaml
   name: PR Comment Workflow
   on:
     issue_comment:
       types: [created]
   
   permissions:
     contents: write
     pull-requests: write
     issues: write
   
   jobs:
     process-comment:
       if: github.event.issue.pull_request && contains(github.event.comment.body, '/update')
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v3
           with:
             ref: refs/pull/${{ github.event.issue.number }}/head
             fetch-depth: 0
   
         - name: Run starchitect Test Agent
           uses: nonfx/starchitect-testgen@main
           with:
             input_file_path: "./test-data/data.csv"
             output_file_path: "./test-output"
             pipeline_token: ${{ secrets.PIPELINE_TOKEN }}
             anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
             openai_api_key: ${{ secrets.OPENAI_API_KEY }}
             pr_workflow: "comment"
   ```

3. **Configure Repository Secrets**
   Add the following secrets to your repository:
   - `PIPELINE_TOKEN`
   - `ANTHROPIC_API_KEY`
   - `OPENAI_API_KEY`

## Usage

1. **Initial Test Generation**
   - Navigate to the "Actions" tab in your repository
   - Select "Regula codegen Workflow"
   - Click "Run workflow"
   - This will create separate PRs for each test case in your CSV file

2. **Updating Tests via PR Comments**
   - On any generated PR, add a comment starting with `/update`
   - Follow it with the changes you want to make
   - Example: `/update Please add validation for edge cases`
   - The workflow will process your request and add a new commit to the PR

## Notes
- Ensure your CSV file follows the required format
- The action uses both Claude model for optimal results, you can skip OPENAI_API_KEY
- All generated tests will be placed in the specified output directory
- Each test case from the CSV file gets its own PR for better tracking
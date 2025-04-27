#!/bin/bash
# Bash script to set up GitHub lab environment dedicated to Issues and Projects.

# If "--delete" is passed as an argument, delete all issues in the repository
if [[ "$1" == "--delete" || "$1" == "--seed-all" ]]; then
  echo "Deleting all issues..."
  gh issue list --limit 1000 | awk '{print $1}' | xargs -I {} gh issue delete {} --yes
fi

# If "--seed" is passed as an argument, automatically create issues that are meant to be manually created
if [[ "$1" == "--seed-all" ]]; then
  gh issue create \
    --title "Investigate Issue Basics" \
    --body "
# Issue Basics

This task describes the lab steps required to complete the Issue Basics tasks.  As a template item, this description was filled out for you in advance (to save typing).  Generally, you will use templates to get started with a standard format and content but add additional information.  In this case, the issue is complete as-is...

To complete this task you will:
- [x] Use an issue template (done)
- [x] Review markdown used to format content in GitHub. You're looking at it now, but if you aren't already familiar with markdown you can refer to [this link](https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github).  If you've already saved it and want to review the source markdown you can edit the description to see the unformatted text.
- [ ] Apply Labels
- [ ] Apply Milestones
- [ ] Query Issues
- [ ] Verify automation triggered by issues" \
    --assignee "@me" 
fi

# Function to load issue seeds from a JSON file
load_issue_seeds() {
    # Check if jq is installed
    if ! command -v jq &> /dev/null; then
        echo "Error: jq is not installed. Please install it with: sudo apt-get install jq" >&2
        return 1
    fi

    # Check if file exists
    local file_path="issue-seeds.json"
    if [[ ! -f "$file_path" ]]; then
        echo "Error: $file_path not found in current directory." >&2
        return 1
    fi

    # Read the JSON file and return the content
    local json_content
    json_content=$(jq '.' "$file_path")
    
    # Check if the JSON is valid
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to parse JSON file." >&2
        return 1
    fi
    
    # Echo the JSON content
    echo "$json_content"

}

# Function to create a GitHub issue from a JSON issue object
create_issue_from_json() {
    local issue_json="$1"
    
    # Extract issue properties with proper error handling
    local id=$(echo "$issue_json" | jq -r '.id // empty') 
    local title=$(echo "$issue_json" | jq -r '.title // empty')
    local body=$(echo "$issue_json" | jq -r '.body // empty')
    # local labels=$(echo "$issue_json" | jq -r '.labels // [] | join(",")') 
    local labels=$(echo "$issue_json" | jq -r '.labels // empty') 
    local milestone=$(echo "$issue_json" | jq -r '.milestone // empty')
    local parent=$(echo "$issue_json" | jq -r '.parent // empty')
    
    # Validate required fields
    if [[ -z "$title" ]]; then
        echo "Error: Issue title is required." >&2
        return 1
    fi
    
    echo "Creating issue: $title"
    
    # Build the gh issue create command
    local cmd="gh issue create --title \"$title\" --body \"$body\""
            
    # Add labels if provided
    if [[ -n "$labels" && "$labels" != "" ]]; then
        cmd="$cmd --label \"$labels\""
    fi
    
    # Add milestone if provided
    if [[ -n "$milestone" && "$milestone" != "null" ]]; then
        cmd="$cmd --milestone \"$milestone\""
    fi
    
    # Execute the command to create the issue
    issue_url=$(eval "$cmd")
    
    # Check if issue was created successfully
    if [[ $? -eq 0 ]]; then
        echo "Successfully created issue: $issue_url"

        # Parse the issue number from the URL
        issue_number=$(echo "$issue_url" | grep -oE '[0-9]+$')

        # Modify the URL to create the related API URL
        api_url=$(echo "/repos/$issue_url" | sed 's/https:\/\/github.com\///')

        # Set the issue Type based on the JSON "type" field
        issue_type=$(echo "$issue_json" | jq -r '.type // empty')

        # Use the GitHub CLI to call the api_url and apply the issue_type
        echo "Setting issue type to: $issue_type"
        gh api -X PATCH "$api_url" -f type="$issue_type"

        # Capture the parent issue number if provided
        if [[ -n "$id" && "$id" != "null" ]]; then
            echo "Capturing issue ID[$id] = $issue_number"
            parent_issue_numbers[$id]=$issue_number
        fi

        # If a parent issue is specified, create the relationship
        if [[ -n "$parent" && "$parent" != "null" ]]; then
            echo "Attempting to add relationship with parent issue: $parent"

            # Look up this issue's node_id
            child_id=$(gh api -X GET "$api_url" | jq -r '.id // empty')

            # Check the parent issue number array
            if [[ "${parent_issue_numbers[$parent]}" ]]; then

                # create a version of the API URL for the parent issue
                parent_id=${parent_issue_numbers[$parent]}
                parent_api_url=$(echo "$api_url" | sed -E "s|/([0-9]+)$|/$parent_id/sub_issues|")

                # Add the sub-issue relationship via the GitHub API
                echo "Adding sub-issue relationship from $parent_id to $issue_number"
                gh api $parent_api_url -X POST -F sub_issue_id=$child_id
            fi
        fi

        return 0
    else
        echo "Failed to create issue: $title" >&2
        return 1
    fi
}

# ------------------------------------------------------------
# Seed automation issues required for the lab
# ------------------------------------------------------------
if [[ "$1" == "" || "$1" == "--seed-all" ]]; then

  # Call the function and store the result in a variable
  echo "Reading seed issues for the lab..."
  issue_seeds_json=$(load_issue_seeds)

  if [[ $? -eq 0 ]]; then
      echo "Successfully loaded $(echo "$issue_seeds_json" | jq 'length') issue seeds."
      
      # Initialize an array for parent issue numbers
      declare -a parent_issue_numbers=()

      # Loop through each issue in the JSON array
      for i in $(seq 0 $(( $(echo "$issue_seeds_json" | jq 'length') - 1 ))); do
          # Extract the issue object
          issue=$(echo "$issue_seeds_json" | jq ".[$i]")
          
          # Create issue from the JSON object
          create_issue_from_json "$issue"
          
          # Optional: Add a small delay between issue creation to avoid rate limits
          # sleep 1
      done
  else
      echo "Failed to load issue seeds JSON"
      exit 1
  fi
fi


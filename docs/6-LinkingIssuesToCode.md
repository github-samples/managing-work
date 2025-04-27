## Linking Issues to Code
_Linking code to issues is a common pattern within GitHub. It is frequently used to associate code changes with the issues that caused them (bugs, feature requests, etc.). This exercise walks you through fixing a small Bug and how the code and issues are related._

### Fix the README Bug
- [ ] Open the Bug issue and review the contents
  - If you're not already in your repo, use the menu button on the top-left of the page to navigate to your repo.
  - Click on **Issues** in the top-nav and filter to show Bug issue type (e.g., `type:Bug`).
  - Open the **Fix the typo in the README file** issue and review the description.
- [ ] Open the README file and fix the typo.
  - Click on the **<> Code** button in the top-nav.
  - Click on the **README.md** file in file list.
  - Click on the "Edit this file" (i.e., **pencil** ![Pencil](./images/bare-pencil.png)) button near the top-right of the page.
  - Fix the text on line 3 so that it correctly reads `## Abstract`.
- [ ] Commit the file to a branch and open a Pull Request referencing the bug issue.
  - Click on the green **Commit changes...** button near the top-right of the page.
  - In the "Extended description" textarea, type `Fixes `; there are [multiple keywords](https://docs.github.com/en/get-started/writing-on-github/working-with-advanced-formatting/using-keywords-in-issues-and-pull-requests) that can be used to link issues to code changes.
  - The **#** key is used to bring up issue reference.  Press **#** and review the list of issues.  Even if you see your issue, continue to the next step.
  - You could type the issue number directly, reference an issue in a differnt repo, or type text to filter the issue list.  Complete typing "README" so that the list filters to show your issue (i.e., `Fixes #README`).
  - Click on the bug issue to complete the linkage; it will insert the issue number for you.
  - ***IMPORTANT:*** Change the radio button on the bottom of the form to select "Create a **new branch**..."; you can accept the default branch name or enter a different name if you'd like.
  - Click the **Propose changes** button.
  - You can accept the defaults; click the **Create pull request** button .
- [ ] Merge the pull request and review the results.
  - Although this would generally trigger a peer review, possibly Copilot-review, and possible automated checks, for this exercise we are just going to merge the code.  Click the **Merge pull request** button.
  - You can modify anything or accept the defaults, then click **Confirm merge**.
  - Since we added automation in an earlier exercise for the project, this pull request (PR) is automatically added to your project.  In the right-column of the page, click on the name of your project under the "Projects" section.
  - If not already selected, click on the **Feature Planning** tab.
  - Locate the bug; note that it's status was updated to done through a series of events: merging the PR with the "fixes" keyword closed the issue, and the project automation updated the status to "Done".
  - Click on the bug to open it; scan down in the on the right column and look for the "Deveopment" section.
  - Verify that the link to the PR in that section has the "merged" icon (![Merged icon](./images/merged-icon.jpeg)) showing that the merge is complete.
  - If you'd like, click on the PR to drill into it.  You can review all files, individually changed lines, and review feedabck in the PR as associated with this issue, and seamlessly move between the issue and the code changes.

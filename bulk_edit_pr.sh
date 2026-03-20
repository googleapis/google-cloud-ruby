#!/bin/bash

# Bulk Edit PR Script
# Usage: ./bulk_edit_pr.sh <PR_NUMBER>

if [ -z "$1" ]; then
    echo "Usage: $0 <PR_NUMBER>"
    exit 1
fi

PR=$1
export NEW_MSG="* Upgrade dependencies for Ruby v4.0 and drop Ruby v3.1 support"

if gh pr checks $PR | grep -qi "fail\|pending"; then
    echo "❌ CI NOT READY"
else
    echo "--- 🟢 STARTING PR #$PR ---"
    gh pr checkout $PR
    git fetch origin main && git rebase origin/main
    CHANGELOG=$(gh pr diff $PR --name-only | grep "CHANGELOG.md" | head -n 1)

    if [ -z "$CHANGELOG" ]; then
        echo "📄 No CHANGELOG found"
    else
        # 1. Clean local CHANGELOG.md
        perl -i -ne 'if (/Update minimum Ruby to v3\.2|Add irb as explicit dependency/i) { print "$ENV{NEW_MSG}\n" unless $s++; } else { print }' "$CHANGELOG"

        # 2. Commit and Push
        git commit -am "chore: combine duplicate Ruby 4.0 release notes"
        git push origin $(git branch --show-current) --force-with-lease

        # 3. Update PR body on GitHub and apply label
        gh pr view $PR --json body -q .body | perl -ne 'if (/Update minimum Ruby to v3\.2|Add irb as explicit dependency/i) { print "$ENV{NEW_MSG}\n" unless $s++; } else { print }' > /tmp/new_body.md
        gh pr edit $PR --body-file /tmp/new_body.md --add-label "autorelease: pending"

        echo "👍 Approving PR #$PR"
        gh pr review --approve $PR

        echo "🔀 Merging PR #$PR (bypassing CI)"
        gh pr merge $PR --squash --admin

        echo "🚀 DONE #$PR"
     fi
fi

# Rollback Process

## Overview

This document describes the rollback strategy for infrastructure changes that fail during the automated deployment pipeline. The approach uses manual Git reverts combined with automated CI/CD execution to safely restore infrastructure to a known good state.

## Process Description

When a commit introduces breaking changes that cause the `main_apply` Cloud Build workflow to fail, the rollback is performed through a **semi-automatic process**: a developer manually reverts the problematic commit, and the automated CI/CD pipeline applies the reverted state to the infrastructure.

## Step-by-Step Rollback Example

### Scenario

A commit was merged to `master` that included:

1. A new VM instance with an invalid machine type (causing deployment failure)
2. A valid change renaming an existing VM from `vm-3` to `vm-4`

The `main_apply` Cloud Build trigger failed during deployment.

### Rollback Steps

1. **Identify the problematic commit**

   ```bash
   git log -1 --oneline
   ```

   Output: `9566ccd (HEAD -> master, origin/master) Add invalid vm`

2. **Revert the commit locally**

   ```bash
   git revert --no-edit 9566ccd
   ```

   This creates a new commit that undoes all changes from `9566ccd`, including both the invalid VM and the rename.

3. **Push the revert commit**

   ```bash
   git push
   ```

   This triggers the `main_apply` Cloud Build workflow automatically.

4. **Verify restoration**
   - The CI/CD pipeline executes Terraform apply with the reverted configuration
   - `vm-3` is restored with its original name
   - The invalid VM configuration is removed from the codebase
   - Infrastructure matches the Git history on `master`

## Why Semi-Automatic Rollback?

This approach was chosen over fully automatic rollback for the following reasons:

### 1. **Git History Integrity**

Automatic rollback would require programmatic manipulation of Git history (e.g., force pushes, automated reverts), which is risky and can lead to:

- Conflicts with concurrent changes
- Loss of audit trail
- Synchronization issues across developer machines

### 2. **Clear Failure Visibility**

In a manual revert approach:

- **Failed apply** → remains visible as a failure in build history
- **Successful revert** → shown as a new, successful deployment

With automatic rollback:

- **Failed apply + successful rollback** → should arguably still be marked as a failure, but this obscures the actual state
- **Failed apply + failed rollback** → double failure, creating confusion about which failure to investigate

### 3. **Prevention of Infinite Rollback Loops**

Automatic rollback systems require safeguards against:

- Rollback commits that themselves fail
- Cascading rollbacks creating infinite loops
- Determining "how far back" to roll back safely

Manual intervention provides a natural circuit breaker.

### 4. **Source-of-Truth Consistency**

Alternative approaches like "restore Terraform state without changing code" create dangerous scenarios:

- Code on `master` diverges from actual infrastructure state
- Next deployment will attempt to reapply the broken changes
- State files become unreliable as the source of truth

### 5. **State Restoration Limitations**

Simply restoring a previous Terraform state file does not:

- Guarantee changes are applied to the cloud provider
- Handle resources created outside Terraform
- Provide a clear audit trail of what changed and why

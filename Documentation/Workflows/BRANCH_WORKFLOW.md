# Branch Workflow and Merge Process

## Overview
All specialized agents must work in their own feature branches. The Master Agent is responsible for reviewing and merging approved scripts into the main branch.

## Branch Naming Convention

### Format
`agent/[role]/[script-name]` or `agent/[role]/[task-description]`

### Examples
- `agent/user-admin/bulk-license-assignment`
- `agent/exchange-admin/mailbox-audit`
- `agent/security-admin/conditional-access-review`
- `agent/audit/profile-m365-usage`

### Guidelines
- Use lowercase
- Use hyphens to separate words
- Include role identifier
- Be descriptive but concise

## Workflow

### Step 1: Agent Creates Branch
**Actor**: Specialized Agent

**Actions**:
1. Create feature branch from main:
   ```bash
   git checkout main
   git pull origin main
   git checkout -b agent/[role]/[script-name]
   ```
2. Work on script in the branch
3. Commit changes as work progresses:
   ```bash
   git add Scripts/[Role]/[ScriptName].ps1
   git commit -m "feat: Add [script description]"
   ```

### Step 2: Agent Completes Script
**Actor**: Specialized Agent

**Actions**:
1. Complete script following all standards
2. Self-review against `SAFETY_CHECKLIST.md`
3. Ensure script is production-ready (no placeholders)
4. Push branch to remote:
   ```bash
   git push origin agent/[role]/[script-name]
   ```
5. Notify Master Agent that script is ready for review

### Step 3: Master Agent Review
**Actor**: Master Agent

**Actions**:
1. Checkout the agent's branch:
   ```bash
   git fetch origin
   git checkout agent/[role]/[script-name]
   ```
2. Review script using `SAFETY_CHECKLIST.md`
3. Test script if needed (with `-WhatIf`)
4. Provide feedback:
   - **APPROVED**: Ready to merge
   - **NEEDS REVISION**: Request changes
   - **REJECTED**: Critical issues, branch should be closed

### Step 4A: Script APPROVED - Merge to Main
**Actor**: Master Agent

**Actions**:
1. Ensure branch is up to date with main:
   ```bash
   git checkout agent/[role]/[script-name]
   git merge main  # or rebase if preferred
   ```
2. Resolve any conflicts if present
3. Merge to main:
   ```bash
   git checkout main
   git merge agent/[role]/[script-name]
   git push origin main
   ```
4. Delete feature branch (optional, after merge):
   ```bash
   git branch -d agent/[role]/[script-name]
   git push origin --delete agent/[role]/[script-name]
   ```
5. Document merge in review log

### Step 4B: Script NEEDS REVISION
**Actor**: Master Agent → Specialized Agent

**Actions**:
1. Master Agent provides detailed feedback
2. Agent makes changes in the same branch:
   ```bash
   git checkout agent/[role]/[script-name]
   # Make changes
   git add Scripts/[Role]/[ScriptName].ps1
   git commit -m "fix: Address review feedback"
   git push origin agent/[role]/[script-name]
   ```
3. Agent notifies Master Agent of changes
4. Master Agent reviews again (back to Step 3)

### Step 4C: Script REJECTED
**Actor**: Master Agent

**Actions**:
1. Document rejection reasons
2. Close or delete branch:
   ```bash
   git branch -D agent/[role]/[script-name]
   git push origin --delete agent/[role]/[script-name]
   ```
3. Notify user of rejection

## Commit Message Standards

### Format
`[Type]: [Description]`

### Types
- `feat`: New script or feature
- `fix`: Bug fix or addressing review feedback
- `docs`: Documentation update
- `refactor`: Code refactoring
- `test`: Test additions or updates

### Examples
```
feat: Add bulk user license assignment script
fix: Add -WhatIf support to license assignment
fix: Address review feedback - add error handling
docs: Update script documentation
refactor: Improve error handling in user script
```

## Merge Requirements

### Before Merging
- [ ] Script reviewed and approved by Master Agent
- [ ] All safety checks pass
- [ ] All security checks pass
- [ ] Code quality meets standards
- [ ] No merge conflicts
- [ ] Branch is up to date with main

### Merge Process
1. **Review**: Master Agent completes review
2. **Update**: Ensure branch is current with main
3. **Merge**: Merge branch to main
4. **Verify**: Confirm merge was successful
5. **Cleanup**: Delete feature branch (optional)

## Conflict Resolution

### If Conflicts Occur
1. Master Agent resolves conflicts
2. Test resolution to ensure script still works
3. Commit resolution:
   ```bash
   git add [conflicted-files]
   git commit -m "fix: Resolve merge conflicts"
   ```
4. Continue with merge process

## Branch Protection

### Main Branch
- **Protected**: Only Master Agent can merge to main
- **Requires Review**: All merges must be reviewed
- **No Direct Commits**: Agents should not commit directly to main

### Feature Branches
- Agents have full control of their feature branches
- Can push, commit, and modify freely
- Master Agent can checkout and review

## Best Practices

### For Agents
- Create branch before starting work
- Commit frequently with meaningful messages
- Keep branch focused on single script/task
- Update branch if main changes significantly
- Notify Master Agent when ready for review

### For Master Agent
- Always review before merging
- Test scripts when possible
- Keep main branch stable
- Document all merges
- Clean up merged branches regularly

## Emergency Procedures

### Hotfix Process
For urgent fixes to main branch:
1. Create hotfix branch from main
2. Make fix
3. Master Agent reviews immediately
4. Merge to main
5. Also merge to any active feature branches if needed

### Rollback Process
If merged script causes issues:
1. Revert the merge commit:
   ```bash
   git revert -m 1 [merge-commit-hash]
   git push origin main
   ```
2. Document the rollback
3. Notify relevant parties

## Integration with Review Process

### Review Status and Branch Actions

| Status | Branch Action |
|--------|---------------|
| **APPROVED** | Merge to main, delete branch |
| **NEEDS REVISION** | Keep branch, agent makes changes |
| **REJECTED** | Delete branch, do not merge |

## Documentation

### Review Documentation
- Review notes should be documented
- Merge decisions should be logged
- Branch cleanup should be tracked

### Branch Tracking
Maintain awareness of:
- Active feature branches
- Branches awaiting review
- Merged branches (for cleanup)
- Rejected branches (for reference)

---

**Remember**: The Master Agent has final authority on all merges to main. Safety and quality are paramount.


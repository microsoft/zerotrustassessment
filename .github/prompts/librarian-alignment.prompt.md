---
mode: ask
---

# Documentation Alignment Analysis Function

This function is called by `librarian.prompt.md` to perform alignment analysis against organizational standards and formatting consistency.

Identify files that need content updates by checking for:

**Missing/Empty Sections:**
- Files missing `**Implementation Effort:**` metadata
- Files missing `**User Impact:**` metadata  
- Files with empty Overview sections
- Files with empty Reference sections (just `*` placeholders)

**Quality Issues:**
- Placeholder content ("TBD", "TODO", etc.)
- Minimal Overview content (< 100 words)
- Inconsistent metadata formatting

## Expected Format

Files should follow this structure:
```markdown
# [ID]: [Title]

**Implementation Effort:** [High/Medium/Low] – [Description]
**User Impact:** [High/Medium/Low] - [Description]

## Overview
[Zero Trust device guidance content]

## Reference
[Microsoft Learn links]
```

## Output

Categorize findings as:
- **High Priority:** Missing required metadata sections or completely empty sections
- **Medium Priority:** Incomplete content or minimal descriptions  
- **Low Priority:** Content improvements and enhancements

For each file, provide: filename, specific issues, and recommended actions.

## Link Domain Compliance

Validate all external links for Microsoft domain compliance:

### Domain Validation Checklist
- [ ] All links use Microsoft-owned domains (`microsoft.com`, `learn.microsoft.com`, etc.)
- [ ] No unauthorized external domains referenced
- [ ] GitHub links only point to `github.com/microsoft/*` or `microsoft.github.io/*` repositories
- [ ] `aka.ms` short links are used appropriately for Microsoft redirects

### Non-Compliance Actions
- **Document**: List all non-Microsoft domain links
- **Categorize**: Essential vs. replaceable external references  
- **Recommend**: Microsoft Learn alternatives or content summarization
- **Flag**: Links requiring security review for business justification
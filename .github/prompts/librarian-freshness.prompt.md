---
mode: ask
---

# Documentation Freshness Analysis Function

This function is called by `librarian.prompt.md` to perform freshness analysis on Zero Trust Assessment documentation.

## Purpose

Verify that documentation content stays current with Microsoft's latest guidance and Zero Trust principles for the identified pillar.

## Prerequisites

Before using this function:
1. **Pillar must be identified** by the main librarian prompt
2. **Pillar-specific configuration** must be available (sites, topics, focus areas)
3. **Target files** must be specified for analysis

## Analysis Process

### Step 1: Content Verification
For the identified pillar, check:
- **Technical accuracy**: Does content match current capabilities?
- **Feature currency**: Are deprecated features identified and new features included?
- **Best practices alignment**: Does guidance follow current security recommendations?
- **Zero Trust principles**: Are Zero Trust concepts properly applied?

### Step 2: Link Validation
Verify all Microsoft Learn references:
- **Working links**: All URLs return valid content
- **Current versions**: Links point to latest documentation versions
- **Proper redirects**: Deprecated URLs redirect to current content
- **Consistent domains**: Use official Microsoft Learn domains

### Step 3: Reference Verification
Use pillar-specific search patterns:
```
Primary: site:[pillar-primary-site] [topic]
Secondary: site:[pillar-secondary-site] [topic]  
Zero Trust: site:learn.microsoft.com/security/zero-trust [topic]
General: site:learn.microsoft.com [topic]
```

### Step 4: Feature Currency Check
- **Deprecated features**: Mark for removal or update
- **New capabilities**: Identify missing current features
- **Version alignment**: Ensure content matches current service versions
- **Preview vs GA**: Distinguish between preview and generally available features

## Freshness Indicators

### Current Content ✅
- Matches latest Microsoft documentation
- Uses current terminology and feature names
- References active Microsoft Learn URLs
- Aligns with current Zero Trust guidance

### Needs Review ⚠️  
- Content may be outdated but not clearly wrong
- Links redirect but may not be optimal
- Missing recent features but core content valid
- Partial alignment with current best practices

### Outdated Content ❌
- Contradicts current Microsoft guidance
- References deprecated or removed features
- Uses obsolete terminology or concepts
- Broken or invalid Microsoft Learn links

### Enhancement Opportunities 📈
- Could benefit from new feature additions
- Missing relevant current capabilities
- Opportunity to improve Zero Trust alignment
- Could reference more current documentation

## Output Format

Structure findings as:

```markdown
## Freshness Analysis Results

### ✅ Current Content
- [Specific findings with file references]

### ⚠️ Needs Review  
- [Specific findings with file references]
- **Recommended Action**: [What should be updated]
- **Reference**: [Current Microsoft Learn URL]

### ❌ Outdated Content
- [Specific findings with file references]  
- **Issue**: [What contradicts current guidance]
- **Recommended Action**: [How to fix]
- **Reference**: [Current Microsoft Learn URL]

### 🔗 Broken Links
- [File and broken URL]
- **Replacement**: [Current working URL]

### 📈 Enhancement Opportunities
- [Missing current features or capabilities]
- **Recommended Addition**: [What to add]
- **Reference**: [Supporting Microsoft Learn URL]
```

## Quality Standards

All recommendations must include:
- **Specific file references**: Exact files and sections
- **Current Microsoft Learn URLs**: Always provide working references
- **Clear action items**: Specific steps to resolve issues
- **Priority indicators**: High/Medium/Low urgency classification

## Validation Requirements

Before reporting findings:
1. **Verify all recommended URLs** are working and current
2. **Confirm technical accuracy** against official Microsoft sources  
3. **Check Zero Trust alignment** using official Zero Trust documentation
4. **Ensure pillar relevance** - recommendations match pillar focus area

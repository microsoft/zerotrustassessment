Trainable classifiers are Microsoft Purview's machine learning-based content classification engine that learns to identify sensitive or business-critical information based on organizational examples. Unlike fixed-pattern Sensitive Information Types (SITs) that match predefined formats (e.g., credit card numbers, phone numbers), trainable classifiers use artificial intelligence to recognize nuanced content patterns such as strategic plans, financial reports, HR documents, or proprietary research—data that lacks consistent structured formats but requires protection based on meaning and context. By integrating trainable classifiers into auto-labeling policies and Data Loss Prevention (DLP) rules, organizations extend their data protection capabilities beyond pattern-matching to semantic understanding of content. This enables automatic classification and protection of complex, unstructured data that would be difficult or impossible to capture with traditional pattern-based rules. Organizations leveraging trainable classifiers in policies achieve broader data discovery and more comprehensive compliance coverage, particularly for sensitive business documents that require context-aware classification rather than format-based detection.

**Remediation action**

To create and deploy trainable classifiers:

1. Sign in as a Global Administrator or Compliance Administrator to the [Microsoft Purview portal](https://purview.microsoft.com)
2. Navigate to Information Protection > Classifiers > Trainable classifiers
3. Select "+ Create trainable classifier"
4. Enter a name and description for your classifier (e.g., "Strategic Plans", "Financial Reports", "HR Documents")
5. Select the classifier type (Document or Message classifier)
6. Upload example documents:
   - **Positive examples**: 5-500 documents that represent the content you want to classify
   - **Negative examples** (optional): 5-500 documents that represent content you do NOT want to classify
7. Review examples for accuracy and completeness
8. Submit the classifier for training
9. Wait for training completion (typically 1-2 weeks)
10. After classifier is published, integrate into policies:
    - **Auto-Labeling**: Create auto-labeling policy with rule that uses the classifier condition
    - **DLP**: Create DLP policy with rule that uses the classifier condition
11. Monitor classifier accuracy through DLP and auto-labeling rule matches

Example trainable classifier scenarios:
- **Strategic Plans**: Confidential business strategy documents, competitive analysis
- **Financial Reports**: Earnings reports, budget documents, financial forecasts
- **HR Documents**: Employee records, compensation information, performance reviews
- **Patent Documents**: Intellectual property, patent applications, technical specifications
- **Customer Contracts**: Business agreements, customer-specific terms, confidential pricing

To integrate classifiers into auto-labeling policies:
1. Create or edit auto-labeling policy
2. Add rule with condition: "Content contains information detected by trainable classifier"
3. Select the trained classifier from the dropdown
4. Assign the appropriate sensitivity label
5. Publish the policy

To integrate classifiers into DLP policies:
1. Create or edit DLP compliance policy
2. Add rule with condition using trainable classifier detection
3. Define protection actions (restrict access, notify user, block action)
4. Publish the policy

- [Create and train trainable classifiers](https://learn.microsoft.com/en-us/purview/classifier-learn-about)
- [Use trainable classifiers in auto-labeling](https://learn.microsoft.com/en-us/purview/apply-sensitivity-label-automatically)
- [Use trainable classifiers in DLP policies](https://learn.microsoft.com/en-us/purview/dlp-learn-about-dlp)
<!--- Results --->
%TestResult%


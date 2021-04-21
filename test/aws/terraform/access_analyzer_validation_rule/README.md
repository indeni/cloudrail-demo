In this directory you will find several examples of problematic IAM permissions, and how each of the known tools 
(Cloudrail, Checkov, KICS, tfsec, terrascan) handles them.

Of specific interest is the case in [iam_multiple_issues](iam_multiple_issues), where there's a set of IAM policies 
which lead to privilege escalation. Cloudrail is capable of identifying this in multiple ways, while the other tools 
do not.

Within that same example, you'll see Cloudrail's use of the policy validation feature available through AWS Access 
Analyzer. This means that you can include an official AWS review of your IAM policies before deploying them. For 
example, see this output from Cloudrail:

```
Rule: Ensure IAM policies pass Access Analyzer policy validation without SECURITY and ERROR issues
 - 1 Resources Exposed:
-----------------------------------------------
   - Exposed Resource: [aws_iam_role_policy.allow-policy-1] (main.tf:25)
     Violating Resource: [aws_iam_role_policy.allow-policy-1]  (main.tf:25)

     Evidence:
         Line 6, Col 8:
             | Using the iam:PassRole action with wildcards (*) in the resource can be overly permissive because it allows iam:PassRole permissions on multiple resources
             | We recommend that you specify resource ARNs or add the iam:PassedToService condition key to your statement
             | See https://docs.aws.amazon.com/IAM/latest/UserGuide/access-analyzer-reference-policy-checks.html#access-analyzer-reference-policy-checks-security-warning-pass-role-with-star-in-resource
```
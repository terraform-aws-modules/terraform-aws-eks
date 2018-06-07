# eks_test_fixture example

This set of templates serves two purposes:

1.  it shows developers how to use the module in a straightforward way as integrated with other terraform community supported modules.
1.  serves as the test infrastructure for CI on the project.

## IAM Permissions

The following IAM policy is the minimum needed to execute the module from the test suite.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1507789535000",
      "Effect": "Allow",
      "Action": [],
      "Resource": ["*"]
    }
  ]
}
```

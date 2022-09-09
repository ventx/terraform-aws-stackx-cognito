## Examples

This is the main example - it deploys a simple AWS S3 bucket.


### How to run against Localstack

> Change to the root of this repository

Install [http://localstack.cloud](Localstack) and configure your API-Key to enable Pro APIs:

```bash
 export LOCALSTACK_API_KEY=1234567890
```

and start the Localstack service (in the background) with `make`:

```bash
 make tf-local
```

Try it out:

Now you can run the terratest tests in this [examples/](../examples) directory against your Localstack:

```bash
 make test
```

> 💡**Bonus Tip:** Use `make test-fast` when using Localstack to run tests with more (64) parallel requests than default (16).


### How to run against AWS

> Change to the root of this repository

Try it out:

Now you can run the terratest tests in this [examples/](../examples) directory with your AWS credentials:

> ⚠️ AWS Credentials:
>
> Configure your AWS credentials _(Environment Variables, Profile, Credential File, OIDC, ...)_
> for Terraform before continuing with the next step.


```bash
 make tf-test
```

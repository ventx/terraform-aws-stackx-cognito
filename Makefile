# Include another Makefile
-include $(shell curl -sSL "https://raw.githubusercontent.com/ventx/stackx-action-readme-templates/main/Makefile" -o .Makefile; echo .Makefile)

##@ Repository specific

.PHONY: all
all: init validate plan apply ## Format your code, init, validate, lint and test.

.PHONY: apply
apply: tf-apply ## Run terraform apply for your code.

.PHONY: clean
clean: tf-clean ## Remove lockfiles and terraform states.

.PHONY: fmt
fmt: tf-fmt ## Run terraform fmt to format your HCL code.

.PHONY: init
init: tf-init ## Run terraform init.

.PHONY: lint
lint: tflint ## Run tflilnt on your code.

.PHONY: destroy
destroy: tf-destroy ## Run terraform destroy.

.PHONY: plan
plan: tf-plan ## Run terraform plan.

.PHONY: test
test: tf-test ## Run terratest on your code.

.PHONY: test-fast
test-fast: tf-test-fast ## Run terratest against localstack with 64 parallel requests.

.PHONY: validate
validate: tf-validate ## Run terraform validate for some basic HCL validation.

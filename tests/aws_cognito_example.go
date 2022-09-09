package tests

import (
	"context"
	"fmt"
	awssdk "github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/ec2"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/files"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"log"
	"net"
	"os"
	"testing"
)

func runAwsCognitoTest(t *testing.T) {

	// Pick a random AWS region to test in.
	// approvedRegions match with stackx regions
	approvedRegions := []string{"eu-central-1", "eu-west-2", "us-east-1", "us-west-2", "ap-east-1", "ap-southeast-1", "ap-southeast-2"}
	awsRegion := aws.GetRandomStableRegion(t, approvedRegions, nil)
	log.Printf("awsRegion: %s", awsRegion)

	var _ awssdk.Config

	// Localstack check
	//
	// Waiting for:
	// https://github.com/gruntwork-io/terratest/pull/495
	// to be implemented / merged.
	//
	// Check if we can listen on port 4566 (a localstack port)
	// If YES (no localstack port found) --> Continue with additional tests
	// If NO (we cant listen, therefore localstack port was found) --> Skip additional tests
	//

	port := "4566"
	listener, listenerErr := net.Listen("tcp", "127.0.0.1:"+port)

	if listenerErr != nil {
		log.Printf("Running Localstack found (can't listen on localstack port %q): %s\n", port, listenerErr)
		log.Println("Copy localstack.tf provider configuration file to examples/localstack-provider.tf (will be removed at the end)")

		defer os.Remove("../examples/localstack-provider.tf")
		err := files.CopyFile("localstack.tf", "./../examples/localstack-provider.tf")
		if err != nil {
			log.Fatalf("Failed to copy localstack.tf to examples/localstack-provider.tf: %s", err)
		}

		log.Println("Configuring aws-sdk with localstack endpoints")
		os.Setenv("AWS_ACCESS_KEY_ID", "mocktest")
		os.Setenv("AWS_SECRET_ACCESS_KEY", "mocktest")

		customResolver := awssdk.EndpointResolverWithOptionsFunc(func(service, region string, options ...interface{}) (awssdk.Endpoint, error) {
			if service == ec2.ServiceID {
				return awssdk.Endpoint{
					PartitionID:       "aws",
					URL:               "http://localhost:4566",
					SigningRegion:     awsRegion,
					HostnameImmutable: true,
				}, nil
			}
			return awssdk.Endpoint{}, fmt.Errorf("localstack endpoint config in AWS-SDK failed")
		})

		_, err = config.LoadDefaultConfig(context.TODO(), config.WithEndpointResolverWithOptions(customResolver))

		if err != nil {
			log.Fatal(err)
		}
	}

	// Construct the terraform options with default retryable errors to handle the most common retryable errors in
	// terraform testing.
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "./../examples",

		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	})

	// At the end of the test, run `terraform destroy`
	defer terraform.Destroy(t, terraformOptions)

	// Runs `terraform init` and `terraform apply` and fails the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the value of an output variable
	//oidcIssuerUrl := terraform.Output(t, terraformOptions, "oidc_issuer")
	//clusterEndpointUrl := terraform.Output(t, terraformOptions, "cluster_endpoint")
	//
	//// Check if the URL is valid
	//var validIssuerURL, validClusterURL bool
	//
	//_, err := url.Parse(oidcIssuerUrl)
	//
	//if err != nil {
	//	fmt.Println(err)
	//	validIssuerURL = false
	//} else {
	//	validIssuerURL = true
	//}
	//
	//assert.True(t, validIssuerURL)
	//
	//_, err = url.Parse(clusterEndpointUrl)
	//
	//if err != nil {
	//	fmt.Println(err)
	//	validClusterURL = false
	//} else {
	//	validClusterURL = true
	//}
	//
	//assert.True(t, validClusterURL)

	if listenerErr == nil {
		log.Println("Running against AWS - Continue with additional tests")

		// Closing the listener we created to check if Localstack is running
		errClose := listener.Close()
		if errClose != nil {
			log.Fatalf("Error while closing port %s for testing if Localstack is running: %v", port, errClose)
		}

		// AWS config
		var err error
		_, err = config.LoadDefaultConfig(context.TODO())

		if err != nil {
			log.Fatal(err)
		}
	}
}

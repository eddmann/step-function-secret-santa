package main

import (
	"bytes"
	"context"
	"encoding/json"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3"
	"os"
	"time"
)

type Allocations struct {
	Allocations []Allocation `json:"allocations"`
}

type Allocation struct {
	Participant Participant `json:"participant"`
	Recipient   Participant `json:"recipient"`
}

type Participant struct {
	Name       string   `json:"name"`
	Email      string   `json:"email"`
	Number     string   `json:"number"`
	Exclusions []string `json:"exclusions"`
}

var svc *s3.S3

func init() {
	svc = s3.New(session.Must(session.NewSession()))
}

func Handle(ctx context.Context, event Allocations) (Allocations, error) {
	allocations, _ := json.MarshalIndent(event, "", "  ")

	input := &s3.PutObjectInput{
		Body:   bytes.NewReader(allocations),
		Bucket: aws.String(os.Getenv("ALLOCATION_BUCKET")),
		Key:    aws.String(time.Now().Format(time.RFC3339)),
	}

	_, err := svc.PutObject(input)
	if err != nil {
		panic("Failed to store allocations")
	}

	return event, nil
}

func main() {
	lambda.Start(Handle)
}

.PHONY: package
package: \
	package/parse-participants \
	package/validate-allocations \
	package/store-allocations \
	package/notify-sms \
	package/notify-email

.PHONY: package/parse-participants
package/parse-participants:
	docker run --rm \
		-e PATH="$${PATH}:/root/.dotnet/tools" \
		-v $(PWD)/src/parse-participants:/src \
		-w /src \
		mcr.microsoft.com/dotnet/sdk:6.0 \
		./build.sh

.PHONY: package/validate-allocations
package/validate-allocations:
	docker run --rm \
		-v $(PWD)/src/validate-allocations:/src \
		-w /src \
		maven:3.8.6-amazoncorretto-11 \
		mvn package

.PHONY: package/store-allocations
package/store-allocations:
	docker run --rm \
		-v $(PWD)/src/store-allocations:/src \
		-w /src \
		golang:1.19.2-alpine3.16 \
		sh -c " \
			GOARCH=amd64 GOOS=linux CGO_ENABLED=0 GO111MODULE=on \
			go build -ldflags=\"-s -w\" -o bin/handler handler.go; \
		"

.PHONY: package/notify-sms
package/notify-sms:
	docker run --rm \
		-v $(PWD)/src/notify-sms:/src \
		-w /src \
		lambci/lambda:build-ruby2.7 \
		sh -c " \
			bundle config set --local path 'vendor/bundle' && \
			bundle install && \
			zip -r notify-sms.zip handler.rb vendor \
		"

.PHONY: package/notify-email
package/notify-email:
	docker run --rm \
		-v $(PWD)/src/notify-email:/src \
		-w /src \
		--entrypoint= \
		public.ecr.aws/lambda/python:3.9 \
		sh -c " \
			pip3 install -r requirements.txt --target ./package && \
			yum install -y zip && \
			cd package && zip -r ../notify-email.zip . && \
			cd .. && zip -g notify-email.zip handler.py \
		"

deploy: _require_AWS_ACCESS_KEY_ID _require_AWS_SECRET_ACCESS_KEY
	docker run --rm \
		-v $(PWD):/src \
		-w /src \
		-e AWS_ACCESS_KEY_ID \
		-e AWS_SECRET_ACCESS_KEY \
		node:16-bullseye \
		sh -c " \
			mkdir -p bin && \
			([ -f bin/serverless ] || wget -q -O bin/serverless https://github.com/serverless/serverless/releases/download/v3.23.0/serverless-linux-x64) && \
			chmod +x bin/serverless && \
			yarn && \
			bin/serverless deploy --verbose \
		"

_require_%:
	@_=$(or $($*),$(error "`$*` env var required"))

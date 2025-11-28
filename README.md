# Step Function Secret Santa

This year (2022) I decided to over-engineer the problem of allocating Secret Santa's for my family, by building a AWS Step Function workflow which uses **every** available [Lambda runtime](https://docs.aws.amazon.com/lambda/latest/dg/lambda-runtimes.html) (managed and custom runtime).

For the custom runtime `provided.al2` I explored the ability of using [my own language](https://github.com/eddmann/santa-lang-ts) which I have been developing throughout the year.

## Getting Started

```
make package
make deploy AWS_ACCESS_KEY_ID=ID AWS_SECRET_ACCESS_KEY=KEY
```

## The Workflow

<img src="./workflow.svg" width="300px" />

| Function                                              | Purpose                                                                                                           | Language                                                                                   |
| ----------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------ |
| [Parse Participants](./src/parse-participants/)       | Converts the CSV input supplied by the clients API Gateway request into a JSON form used throughout the workflow. | C# `dotnet6`                                                                               |
| [Validate Participants](./src/validate-participants/) | Ensures that all supplied participant data is present and valid.                                                  | JavaScript `nodejs16.x`                                                                    |
| [Allocate](./src/allocate/)                           | Allocates each participant to a random recipient.                                                                 | [santa-lang](https://github.com/eddmann/santa-lang-ts/tree/main/src/lambda) `provided.al2` |
| [Validate Allocations](./src/validate-allocations/)   | Ensures that the supplied allocations are valid, taking into consideration participant exclusions.                | Java `java11`                                                                              |
| [Store Allocations](./src/store-allocations/)         | Stores the allocations within an plain-text file S3 object for review.                                            | Go `go1.x`                                                                                 |
| [Notify Email](./src/notify-email/)                   | Sends an email (via Mailgun) to the given participant with their allocated recipient name in.                     | Python `python3.9`                                                                         |
| [Notify SMS](./src/notify-sms/)                       | Sends an SMS (via Twilio) to the given participant with their allocated recipient name in.                        | Ruby `ruby2.7`                                                                             |

## Other Years

Interested in seeing how I over-engineered the problem of allocating Secret Santa's in other years?

- [2020 - Clojure Secret Santa](https://github.com/eddmann/clojure-secret-santa)
- [2021 - Pico Secret Santa](https://github.com/eddmann/pico-secret-santa)
- **2022 - Step Function Secret Santa** ⭐
- [2023 - Secret Santa PWA](https://github.com/eddmann/secret-santa-pwa)
- [2024 - Secret Santa Draw](https://github.com/eddmann/secret-santa-draw)
- [2025 - Secret Santa Draw Arcade](https://github.com/eddmann/secret-santa-draw-arcade)

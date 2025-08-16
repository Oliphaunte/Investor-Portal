## Introduction

This project is built using React/Typescript/Graphql with a Phoenix/Elixir backend and some Liveview.

I originally was going to keep this purely in the Phoenix ecosystem since that would have sufficied for the requirements and we have utilized Liveview for streaming the upload section of the page.

However, I decided to take an extra step to simulate the team's architecture as best I could by creating a mounted React/TypeScript form setup with a Graphql/Rest API to a Phoenix/Elixir backend. There is some mixing with Liveview such as with the tables and the Admin section.

Everything done here was done within the requested time window (I did have to take a bit extra time with the documentation and the docker setup)

## Features

- Authentication/Authorization (Can be tested by registering/logging in as different user to view isolated data)
- CRUD functionality for Investors associated to the user
- Investor form (includes first name, last name, email, phone number, address, state and zip code)
- Investor document upload functionality

## Running

There are two ways to run this project:

1. Using the dev container and Docker locally
2. Run everything from scratch

### Docker

You will need Docker setup and running locally. You can then run:

```
docker compose -f .devcontainer/docker-compose.yml run --service-ports --rm app \
  bash -lc 'mix setup && (cd assets && corepack enable && pnpm install || npm install) && mix phx.server'
```

This should setup everything you need and have the server running from localhost:4000

### From Scratch

You will need:

- Node.js
- Elixir
- Phoenix
- PostgreSQL
- React
- NPM/Yarn/PNPM

Assuming you have all of the above installed, you can run the following commands:

- Make sure your instance of postgres is running and you have configuration setup already
- Run `mix setup` to install and setup dependencies
- In your `/assets` folder, run `npm install` or `yarn install` or `pnpm install` (This project uses pnpm, but you can use anything, just make sure to remove the `pnpm-lock.yaml` file if you are using yarn or npm instead. There should not be any issues regardless, but just in case)
- Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## User Interaction

To interact with the forms and uploads, you will need to register an account. This project only supports authentication via magic links, so you will need to register your email and then visit [localhost:4000/dev/mailbox](http://localhost:4000/dev/mailbox) to login.

You can create different accounts to see isolated data presentations.

## Testing

- We have backend tests for the context and upload functionality. To run the tests, you can use `mix test`

## Final Notes

There are several pieces I would have liked to add to this project, but was unable to due to the time constraints.

- Introduce Apollo client instead of inline graphql queries
- Expanding authentication to include passkeys and 3rd party authentication and memberships (Google, Github, etc)
- Expanding the authorization layer to include roles and permissions
- Integrating the location portion of the form with a 3rd party service like google maps/mapbox
- E2E testing
- General UI/UX tweaks and cleanup

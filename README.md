# Billetto Events & Voting API

Rails 8 JSON API that imports events from the Billetto API and lets signed-in users like or dislike them. Votes are stored as events in Rails Event Store; auth uses Clerk.

## Setup

```bash
cp .env.example .env   # add your Billetto key pair and Clerk test keys
docker compose up --build
```

Without Docker (Ruby 3.4.7 + PostgreSQL):

```bash
bundle install
bin/rails db:prepare
bin/rails server
```

Then load events: `curl -X POST http://localhost:3000/events/sync`

## API

| Method | Path | Auth | Body |
|---|---|---|---|
| POST | `/auth/sign_up` | | `{ "email", "password" }` |
| POST | `/auth/sign_in` | | `{ "email", "password" }` → returns `token` |
| POST | `/auth/sign_out` | Bearer token | |
| POST | `/events/sync` | | |
| GET | `/events?page=1&per_page=20` | | |
| GET | `/events/:id` | | |
| POST | `/events/:event_id/vote` | Bearer token | `{ "value": "up" }` or `{ "value": "down" }` |
| DELETE | `/events/:event_id/vote` | Bearer token | |

Send the token as `Authorization: Bearer <token>`.

## Rails Event Store

- Configured in `config/initializers/rails_event_store.rb` (event store, command bus, subscriptions).
- Browse stored events at http://localhost:3000/res (development).

Voting flow:

```
Controller → Command → Command Bus → Command Handler → EventVote Aggregate
→ EventUpvoted / EventDownvoted / EventVoteRemoved → Rails Event Store
→ EventVotesProjection → votes table + vote counts on events
```

## Notes

- Each user counts once per event; only their latest vote counts.
- Every vote event stores the Clerk user id; there is no local users table.
- API only: no UI was added due to time constraints (test it with Postman or curl).
- Automated test cases are not added yet.

## AI usage

I used an AI assistant (Claude Code) to generate boilerplate code. I reviewed, understood and own every line of code in this repository, and all design and architecture decisions are my own.

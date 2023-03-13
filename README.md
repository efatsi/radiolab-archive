# Radiolab Archive

Available at: https://long-waterfall-5524.fly.dev/

## Local Development
```bash
# Install dependencies
bundle install

# Set up database
rails db:create db:migrate
# Seed episode data
rails db:seed

# Start application
foreman start -f Procfile.dev
```

## Fly Commands
```bash
# Login
fly auth login

# Deploy
fly deploy

# SSH
fly ssh console -C '/bin/bash'

# Open / Status
flyctl open
flyctl status
```

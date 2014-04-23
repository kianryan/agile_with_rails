set :stage, :production
set :branch, "master"

server 'toy', user: 'kian', roles: %w{web app db}, primary: true

set :rails_env, :production

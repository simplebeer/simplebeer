clock: bundle exec clockwork clock.rb
web: bundle exec puma -t 0:5 -p $PORT -e $RACK_ENV -w 3
worker: bundle exec sidekiq -q default -q mailer

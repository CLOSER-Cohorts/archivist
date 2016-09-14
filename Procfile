web: bundle exec rails prepare_to_start && bundle exec puma -C config/puma.rb
in_out_worker: QUEUE=in_and_out bundle exec rails environment resque:work

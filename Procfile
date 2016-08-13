web: bundle exec rails clear_tmp && bundle exec puma -C config/puma.rb
in_out_worker: QUEUE=in_and_out bundle exec rails environment resque:work

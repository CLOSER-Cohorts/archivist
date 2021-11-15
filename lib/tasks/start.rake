namespace :start do
  desc 'Start dev server'
  task :development do
    exec 'cd react && npm install && npm audit fix && cd ../ && bundle exec foreman start -f Procfile.dev'
  end

  desc 'Start production server'
  task :production do
    exec 'npm install && npm audit fix'
    exec 'NPM_CONFIG_PRODUCTION=true npm run postinstall && foreman start'
  end
end
task :start => 'start:development'

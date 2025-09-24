namespace :start do
  desc 'Start dev server'
  task :development do
    system 'cd react && npm install --legacy-peer-deps && npm audit fix --legacy-peer-deps'
    exec 'bundle exec foreman start -f Procfile.dev'
  end

  desc 'Start production server'
  task :production do
    exec 'npm install --legacy-peer-deps && npm audit fix --legacy-peer-deps'
    exec 'NPM_CONFIG_PRODUCTION=true npm run postinstall && foreman start'
  end
end
task :start => 'start:development'

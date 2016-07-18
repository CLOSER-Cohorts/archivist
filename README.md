## README

[![Build Status](https://travis-ci.org/CLOSER-Cohorts/archivist.svg?branch=develop)](https://travis-ci.org/CLOSER-Cohorts/archivist)
[![Inline docs](http://inch-ci.org/github/CLOSER-Cohorts/archivist.svg?branch=develop)](http://inch-ci.org/github/CLOSER-Cohorts/archivist)
[![Coverage Status](https://coveralls.io/repos/github/CLOSER-Cohorts/archivist/badge.svg?branch=develop)](https://coveralls.io/github/CLOSER-Cohorts/archivist?branch=master)
[![Code Climate](https://codeclimate.com/github/CLOSER-Cohorts/archivist/badges/gpa.svg)](https://codeclimate.com/github/CLOSER-Cohorts/archivist)
[![Issue Stats](http://issuestats.com/github/CLOSER-Cohorts/archivist/badge/issue)](http://issuestats.com/github/CLOSER-Cohorts/archivist)

### Non-Implemented Models
#### Mapper
* topic.rb
* variable.rb
* map.rb
* link.rb
* dataset.rb
* instruments_datasets.rb

#### User
* user.rb
* role.rb     (probably)
* group.rb    (probably)

### Model Relationship Diagram
Run `rake generate_erd` to regenerate (must have graphvis).
![](/app/assets/images/diagrams/erd.png)

## Configuation
* Ruby: 2.2.3
* Rails: 4.2.5.1
* Postgres: 9.4.5
* Redis: 3.0.7

## Deployment
Currently Archivist has only been designed to be deployed to [Heroku][heroku], but rolling your own deployment should not be too difficult.

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy?template=https://github.com/CLOSER-Cohorts/archivist/tree/master)

#### Some basic steps
1. `git clone -b master --single-branch https://github.com/CLOSER-Cohorts/archivist.git`
2. `cd archivist`
3. `gem install bundler`
4. `bundler install`
5. Set the environment variable  `RAILS_ENV=production` (e.g. `export RAILS_ENV=production`)
6. Set the environment variable  `ARCHIVIST_DATABASE_PASSWORD=secure_password`
7. `rake db:setup`
8. Start server: `bundle exec puma -C config/puma.rb`

This could cause the webserver to start...

## Testing
To run the test suite just call `rake test`. Currently 196 tests and 263 assertions.

## Stats
| Name                 | Lines |   LOC | Classes | Methods | M/C | LOC/M |
|----------------------|-------|-------|---------|---------|-----|-------|
| Controllers          |   576 |   328 |      27 |      27 |   1 |    10 |
| Models               |   479 |   404 |      27 |      34 |   1 |     9 |
| Javascripts          |  2527 |  2167 |       0 |     287 |   0 |     5 |
| Libraries            |  1647 |  1437 |       7 |      76 |  10 |    16 |
| Controller tests     |   835 |   684 |      18 |       0 |   0 |     0 |
| Model tests          |   659 |   484 |      27 |       0 |   0 |     0 |
| **Total**            |**6746**|**5520**|**110**| **425** |**3**| **10**|

  - Code LOC: 4347
  - Test LOC: 1173
  - Code to Test Ratio: 1:0.3

## Archivist Realtime
Archivist is both a module within Archivist and an entirely separate webapp. [Archivist-realtime][realtime] is very slim Node.js app that provides a communications channel between the [Redis][redis] cache and all active users via websockets (Socket.io). The purpose of this is to be able to lock objects while editing them and to update a users screen as changes are made to an instrument.

[realtime]: https://github.com/CLOSER-Cohorts/archivist-realtime
[redis]: http://redis.io
[heroku]: http://heroku.com
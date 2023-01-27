## Archivist

[![Build Status](https://travis-ci.org/CLOSER-Cohorts/archivist.svg?branch=develop)](https://travis-ci.org/CLOSER-Cohorts/archivist)
[![Coverage Status](https://coveralls.io/repos/github/CLOSER-Cohorts/archivist/badge.svg?branch=develop)](https://coveralls.io/github/CLOSER-Cohorts/archivist?branch=master)
[![Code Climate](https://codeclimate.com/github/CLOSER-Cohorts/archivist/badges/gpa.svg)](https://codeclimate.com/github/CLOSER-Cohorts/archivist)
<!-- [![Issue Stats](https://issuestats.com/github/CLOSER-Cohorts/archivist/badge/issue)](https://issuestats.com/github/CLOSER-Cohorts/archivist) -->

### Model Relationship Diagram
![](/app/assets/images/diagrams/erd.png)

## Configuration
* Ruby: 2.7.5
* Rails: 5.2.X
* Postgres: 13.5
* React JS 16.7.0
* Redis: 6.2.3

## Deployment
Currently Archivist has only been designed to be deployed to [Heroku][heroku], but rolling your own deployment should not be too difficult.

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy?template=https://github.com/CLOSER-Cohorts/archivist/tree/master)

Clicking on the 'Deploy to Heroku' button will create a new Heroku instance of Archivist within your own Heroku account.

### Standalone Installation

If you want to launch Archivist on your local machine or on a server other than Heroku then we have detailed installation guidance please see Archivist's [Wiki](https://github.com/CLOSER-Cohorts/archivist/wiki/Installing-Archivist-(Standalone)) page.

Please keep in mind that some of Archivist's requirements installations - [Ruby](https://www.ruby-lang.org/en/), [Rails](https://rubyonrails.org/), [React](https://reactjs.org/), for example - will vary depending on your operating system. Archivist's installation guidance does not cover the installation of those requirements. Yet.

## Testing
To run the test suite just call `rails test`. Currently 197 tests and 256 assertions.

## Stats
| Name                 |   Lines |     LOC | Classes | Methods | M/C | LOC/M |
|----------------------|---------|---------|---------|---------|-----|-------|
| Controllers          |    1188 |     755 |      34 |      79 |   2 |     7 |
| Jobs                 |     136 |     117 |      10 |      10 |   1 |     9 |
| Models               |    2835 |    1571 |      40 |     154 |   3 |     8 |
| Mailers              |      12 |      11 |       2 |       1 |   0 |     9 |
| Javascripts          |    4137 |    3550 |       0 |     432 |   0 |     6 |
| Libraries            |    3041 |    2359 |      33 |     124 |   3 |    17 |
| Tasks                |     362 |     297 |       0 |       0 |   0 |     0 |
| Controller tests     |     862 |     713 |      18 |      93 |   5 |     5 |
| Model tests          |     663 |     478 |      30 |      97 |   3 |     2 |
| Mailer tests         |      11 |       5 |       2 |       0 |   0 |     0 |
| **Total**            |**13271**| **9875**|  **169**|  **992**|**5**|  **7**|

  - Code LOC: 8679
  - Test LOC: 1196
  - Code to Test Ratio: 1:0.1

[redis]: https://redis.io
[heroku]: https://heroku.com

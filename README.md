## README

[![Build Status](https://travis-ci.org/CLOSER-Cohorts/archivist.svg?branch=master)](https://travis-ci.org/CLOSER-Cohorts/archivist)

### Models
#### CADDIES
* category.rb
* cc_condition.rb
* cc_loop.rb
* cc_question.rb
* cc_sequence.rb
* cc_statement.rb
* code.rb
* code_list.rb
* control_construct.rb
* instruction.rb
* instrument.rb
* question_grid.rb
* question_item.rb
* rds_qs.rb
* response_domain_code.rb
* response_domain_datetime.rb
* response_domain_numeric.rb
* response_domain_text.rb
* response_unit.rb

#### Mapper
* topic.rb
* variable.rb
* map.rb
* link.rb
* dataset.rb
* instruments_datasets.rb

### Models to Add
#### User
* user.rb
* role.rb     (maybe)
* group.rb    (maybe)

### Model Relationship Diagram
Run `rake generate_erd` to regenerate (must have graphvis).
![](/app/assets/images/diagrams/erd.png)

## Configuation
* Ruby: 2.2.1
* Rails: 4.2.4
* Postgres: 9.4
* Redis: coming soon

## Testing
To run the test suite just call `rake test`. Currently 244 tests and 370 assertions.

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:
* System dependencies

* Configuration

* Database creation

* Database initialization

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions


Please feel free to use a different markup language if you do not plan to run
<tt>rake doc:app</tt>.

(function() {
  var resolution,
    indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  resolution = angular.module('archivist.data_manager.resolution', []);

  resolution.factory('ResolutionService', [
    '$timeout', '$rootScope', function($timeout, $rootScope) {
      var service;
      service = {};
      service.ConstructResolver = (function() {
        function _Class(constructs) {
          this.constructs = constructs;
        }

        _Class.prototype.map = {
          CcCondition: 'Conditions',
          CcLoop: 'Loops',
          CcQuestion: 'Questions',
          CcSequence: 'Sequences',
          CcStatement: 'Statements'
        };

        _Class.prototype.queue = [];

        _Class.prototype.added_to_queue = 0;

        _Class.prototype.resolve_children = function(item) {
          var child, i, index, j, len, len1, ref, ref1, self;
          console.log(item.children);
          ref = item.children.slice().reverse();
          for (index = i = 0, len = ref.length; i < len; index = ++i) {
            child = ref[index];
            if (child.type != null) {
              if (child.type in this.map) {
                item.children[item.children.length - 1 - index] = this.constructs[this.map[child.type]].select_resource_by_id(child.id);
              }
            }
            if (item.children[item.children.length - 1 - index].children != null) {
              this.queue.unshift(item.children[item.children.length - 1 - index]);
              this.added_to_queue = this.added_to_queue + 1;
            }
          }
          if (item.fchildren != null) {
            ref1 = item.fchildren.slice().reverse();
            for (index = j = 0, len1 = ref1.length; j < len1; index = ++j) {
              child = ref1[index];
              if (child.type != null) {
                if (child.type in this.map) {
                  item.fchildren[item.fchildren.length - 1 - index] = this.constructs[this.map[child.type]].select_resource_by_id(child.id);
                }
              }
              if (item.fchildren[item.fchildren.length - 1 - index].children != null) {
                this.queue.unshift(item.fchildren[item.fchildren.length - 1 - index]);
                this.added_to_queue = this.added_to_queue + 1;
              }
            }
          }
          item.resolved = true;
          self = this;
          if (this.queue.length > 0) {
            console.log('Scheduled resolution');
            return $timeout(function(item) {
              index = 'resolving:' + item.label;
              console.time(index);
              self.resolve_children(item);
              return console.timeEnd(index);
            }, 0, false, self.queue.shift());
          } else {
            console.log('call digest');
            return $rootScope.$digest();
          }
        };

        _Class.prototype.broken_resolve = function() {
          var self, seq;
          self = this;
          this.queue.unshift(((function() {
            var i, len, ref, results;
            ref = this.constructs.Sequences;
            results = [];
            for (i = 0, len = ref.length; i < len; i++) {
              seq = ref[i];
              if (seq.top) {
                results.push(seq);
              }
            }
            return results;
          }).call(this))[0]);
          this.added_to_queue = this.added_to_queue + 1;
          return $timeout(function() {
            return self.resolve_children(self.queue.shift());
          }, 0);
        };

        _Class.prototype.resolve = function(to_check, check_against) {
          var child, collection, construct, index, key, ref, results;
          if (to_check == null) {
            to_check = ['Conditions', 'Loops', 'Sequences'];
          }
          if (check_against == null) {
            check_against = ['Conditions', 'Loops', 'Questions', 'Sequences', 'Statements'];
          }
          ref = this.constructs;
          results = [];
          for (key in ref) {
            collection = ref[key];
            if (indexOf.call(to_check, key) >= 0) {
              results.push((function() {
                var i, j, k, len, len1, len2, ref1, ref2, results1;
                results1 = [];
                for (i = 0, len = collection.length; i < len; i++) {
                  construct = collection[i];
                  ref1 = construct.children;
                  for (index = j = 0, len1 = ref1.length; j < len1; index = ++j) {
                    child = ref1[index];
                    if (child.type != null) {
                      if (child.type in this.map) {
                        construct.children[index] = this.constructs[this.map[child.type]].select_resource_by_id(child.id);
                      }
                    }
                  }
                  if (construct.fchildren != null) {
                    ref2 = construct.fchildren;
                    for (index = k = 0, len2 = ref2.length; k < len2; index = ++k) {
                      child = ref2[index];
                      if (child.type != null) {
                        if (child.type in this.map) {
                          construct.fchildren[index] = this.constructs[this.map[child.type]].select_resource_by_id(child.id);
                        }
                      }
                    }
                  }
                  results1.push(construct.resolved = true);
                }
                return results1;
              }).call(this));
            } else {
              results.push(void 0);
            }
          }
          return results;
        };

        return _Class;

      })();
      service.QuestionResolver = (function() {
        function _Class(questions) {
          this.questions = questions;
        }

        _Class.prototype.map = {
          QuestionItem: 'Items',
          QuestionGrid: 'Grids'
        };

        _Class.prototype.resolve = function(constructs) {
          var base, construct, i, index, len, results;
          results = [];
          for (index = i = 0, len = constructs.length; i < len; index = ++i) {
            construct = constructs[index];
            results.push((base = constructs[index]).base != null ? base.base : base.base = this.questions[this.map[construct.question_type]].select_resource_by_id(construct.question_id));
          }
          return results;
        };

        return _Class;

      })();
      service.CodeResolver = (function() {
        function _Class(codes_lists, categories) {
          this.code_lists = codes_lists;
          this.categories = categories;
        }

        _Class.prototype.category = function(code) {
          return this.categories.select_resource_by_id(code.category_id);
        };

        _Class.prototype.resolve = function() {
          var code, code_list, i, index, len, ref, results;
          ref = this.code_lists;
          results = [];
          for (i = 0, len = ref.length; i < len; i++) {
            code_list = ref[i];
            results.push((function() {
              var j, len1, ref1, results1;
              ref1 = code_list.codes;
              results1 = [];
              for (index = j = 0, len1 = ref1.length; j < len1; index = ++j) {
                code = ref1[index];
                results1.push(code_list.codes[index].label = this.category(code)['label']);
              }
              return results1;
            }).call(this));
          }
          return results;
        };

        return _Class;

      })();
      service.GroupResolver = (function() {
        function _Class(groups, users) {
          this.groups = groups;
          this.users = users;
        }

        _Class.prototype.resolve = function() {
          var group, group_index, i, len, ref, results, user, user_index;
          ref = this.groups;
          results = [];
          for (group_index = i = 0, len = ref.length; i < len; group_index = ++i) {
            group = ref[group_index];
            this.groups[group_index].users = [];
            results.push((function() {
              var j, len1, ref1, results1;
              ref1 = this.users;
              results1 = [];
              for (user_index = j = 0, len1 = ref1.length; j < len1; user_index = ++j) {
                user = ref1[user_index];
                if (group.id === user.group_id) {
                  this.users[user_index].group = group.label;
                  results1.push(this.groups[group_index].users.push(user));
                } else {
                  results1.push(void 0);
                }
              }
              return results1;
            }).call(this));
          }
          return results;
        };

        return _Class;

      })();
      return service;
    }
  ]);

}).call(this);

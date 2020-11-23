(function() {
  var admin;

  admin = angular.module('archivist.admin', ['templates', 'ngRoute', 'archivist.data_manager', 'archivist.flash']);

  admin.config([
    '$routeProvider', function($routeProvider) {
      return $routeProvider.when('/admin', {
        templateUrl: 'partials/admin/index.html',
        controller: 'AdminDashController'
      }).when('/admin/instruments', {
        templateUrl: 'partials/admin/instruments.html',
        controller: 'AdminInstrumentsController'
      }).when('/admin/datasets', {
        templateUrl: 'partials/admin/datasets.html',
        controller: 'AdminDatasetsController'
      }).when('/admin/users', {
        templateUrl: 'partials/admin/users.html',
        controller: 'AdminUsersController'
      }).when('/admin/import', {
        templateUrl: 'partials/admin/import.html',
        controller: 'AdminImportController'
      }).when('/admin/imports', {
        templateUrl: 'partials/ddi_imports/index.html',
        controller: 'DdiImportsController'
      }).when('/admin/imports/:id', {
        templateUrl: 'partials/ddi_imports/show.html',
        controller: 'DdiImportsShowController'
      }).when('/admin/export', {
        templateUrl: 'partials/admin/export.html',
        controller: 'AdminExportController'
      });
    }
  ]);

  admin.controller('AdminDashController', [
    '$scope', 'DataManager', function($scope, DataManager) {
      return $scope.counts = DataManager.getApplicationStats();
    }
  ]);

  admin.controller('DdiImportsController', [
    '$scope', '$routeParams', 'VisDataSet', 'DataManager', function($scope, $routeParams, VisDataSet, DataManager) {
      return $scope.imports = DataManager.getDdiImports();
    }
  ]);

  admin.controller('DdiImportsShowController', [
    '$scope', '$routeParams', 'VisDataSet', 'DataManager', function($scope, $routeParams, VisDataSet, DataManager) {
      return $scope["import"] = DataManager.getDdiImport({
        id: $routeParams.id
      }, {}, function() {
        $scope.page['title'] = 'Imports';
        return $scope.breadcrumbs = [
          {
            label: 'Imports',
            link: '/ddi_imports',
            active: false
          }, {
            label: $routeParams.id,
            link: false,
            active: true
          }
        ];
      });
    }
  ]);

  admin.controller('AdminUsersController', [
    '$scope', 'DataManager', 'Flash', function($scope, DataManager, Flash) {
      DataManager.getUsers();
      $scope.groups = DataManager.Data.Groups;
      $scope.reset = function() {
        $scope.users = [];
        $scope.current = null;
        $scope.mode = false;
        return $scope.editing = false;
      };
      $scope.reset();
      $scope.selectGroup = function(group) {
        $scope.users = group.users;
        $scope.current = group;
        $scope.mode = 'group';
        return $scope.editing = false;
      };
      $scope.selectUser = function(user) {
        $scope.current = user;
        $scope.mode = 'user';
        return $scope.editing = false;
      };
      $scope.newGroup = function() {
        $scope.original = null;
        $scope.current = new DataManager.Auth.Groups.resource();
        $scope.current.study = [
          {
            label: ''
          }
        ];
        $scope.mode = 'group';
        return $scope.editing = true;
      };
      $scope.newUser = function() {
        $scope.original = null;
        $scope.current = new DataManager.Auth.Users.resource();
        $scope.mode = 'user';
        $scope.users = [];
        return $scope.editing = true;
      };
      $scope.addStudy = function() {
        return $scope.current.study.push({
          label: ''
        });
      };
      $scope.edit = function() {
        $scope.original = $scope.current;
        $scope.current = null;
        $scope.current = angular.copy($scope.original);
        return $scope.editing = true;
      };
      $scope.cancel = function() {
        if ($scope.original != null) {
          $scope.current = $scope.original;
        } else {
          $scope.current = null;
          $scope.mode = false;
        }
        return $scope.editing = false;
      };
      $scope.save = function() {
        console.log($scope);
        if ($scope.original != null) {
          angular.copy($scope.current, $scope.original);
        } else {
          if ($scope.mode === 'group') {
            $scope.groups.push($scope.current);
          } else {
            DataManager.Data.Users.push($scope.current);
            DataManager.GroupResolver.resolve();
          }
          $scope.original = $scope.current;
        }
        return $scope.original.save({}, function(a, b, c, d, e) {
          return $scope.editing = false;
        }, function() {
          $scope.original = null;
          return Flash.add('danger', 'Could not save ' + $scope.mode + '.');
        });
      };
      $scope.reset_password = function() {
        return $scope.current.$reset_password();
      };
      $scope.lock = function() {
        return $scope.current.$lock();
      };
      $scope["delete"] = function() {
        var arr, index;
        arr = $scope[$scope.mode + 's'];
        index = arr.indexOf($scope.current);
        return arr[index].$delete({}, function() {
          arr.splice(index, 1);
          return $scope.reset();
        });
      };
      $scope.only_group_check = function() {
        if ($scope.groups.length === 1) {
          return $scope.selectGroup($scope.groups[$scope.groups.length - 1]);
        }
      };
      return $scope.groups.$promise.then(function() {
        return $scope.only_group_check();
      });
    }
  ]);

  admin.controller('AdminInstrumentsController', [
    '$scope', 'DataManager', 'Flash', '$http', 'AdminMappingImportsFactory', function($scope, DataManager, Flash, $http, AdminMappingImportsFactory) {
      $scope.instruments = DataManager.Instruments.query();
      $scope.pageSize = 24;
      $scope.currentPage = 1;
      $scope.confirmation = {
        prefix: ''
      };
      $scope.mapping = {};
      $scope.prepareCopy = function(id) {
        $scope.original = $scope.instruments.select_resource_by_id(id);
        $scope.copiedInstrument = {};
        $scope.copiedInstrument['new_study'] = $scope.original.study;
        $scope.copiedInstrument['new_agency'] = $scope.original.agency;
        return $scope.copiedInstrument['new_version'] = $scope.original.version;
      };
      $scope.copy = function() {
        return $scope.copiedInstrument = $scope.original.$copy($scope.copiedInstrument, function() {
          return Flash.add('success', 'Instrument copied successfully');
        }, function(response) {
          return Flash.add('danger', 'Instrument failed to copy - ' + response.message);
        });
      };
      $scope.prepareDelete = function(id) {
        return $scope.instrument = $scope.instruments.select_resource_by_id(id);
      };
      $scope["delete"] = function() {
        if ($scope.confirmation.prefix === $scope.instrument.prefix) {
          $scope.instrument.$delete({}, function() {
            DataManager.Data = {};
            $scope.instruments = DataManager.Instruments.requery();
            return Flash.add('success', 'Instrument has successfully been queued for deletion. This may take a few minutes.');
          }, function(response) {
            console.error(response);
            return Flash.add('danger', 'Failed to delete instrument - ' + response.message);
          });
        } else {
          Flash.add('danger', 'The prefixes did not match. The instrument was not deleted.');
        }
        return $scope.confirmation.prefix = '';
      };
      $scope.prepareNew = function() {
        return $scope.newInstrument = new DataManager.Instruments.resource();
      };
      $scope["new"] = function() {
        $scope.newInstrument.$create({}, function() {
          return Flash.add('success', 'New instrument created successfully');
        }, function(response) {
          return Flash.add('danger', 'Failed to create new instrument - ' + response.message);
        });
        return $scope.instruments.push($scope.newInstrument);
      };
      $scope.cleanInputImport = function() {
        if ($scope.mapping.files) {
          return $scope.mapping.files = void 0;
        }
      };
      $scope.clearCache = function(id) {
        return $scope.instruments.select_resource_by_id(id).$clear_cache();
      };
      $scope.prepareImport = function(prefix, id) {
        $scope.id = id;
        $scope.modal = {};
        $scope.modal.title = prefix;
        $scope.modal.msgFileType = "Q-V and T-Q";
        return $scope.modal.fileTypes = [
          {
            value: 'qvmapping',
            label: 'Q-V Mapping'
          }, {
            value: 'topicq',
            label: 'T-Q Mapping'
          }
        ];
      };
      return $scope["import"] = function(id) {
        return AdminMappingImportsFactory["import"]($scope.mapping.files, $scope.mapping.type, 'POST', '/instruments/' + $scope.id + '/imports.json').then((function(response) {
          if (response.status === 200) {
            return Flash.add('success', 'File imported.');
          } else {
            return Flash.add('danger', 'Something went wrong, please import the file again.');
          }
        }), function(error) {
          return Flash.add('danger', 'Something went wrong, please import the file again.');
        });
      };
    }
  ]);

  admin.controller('AdminDatasetsController', [
    '$scope', 'DataManager', 'Flash', '$http', 'AdminMappingImportsFactory', function($scope, DataManager, Flash, $http, AdminMappingImportsFactory) {
      $scope.datasets = DataManager.getDatasets();
      $scope.pageSize = 24;
      $scope.currentPage = 1;
      $scope.mapping = {};
      $scope.prepareImport = function(name, id) {
        $scope.id = id;
        $scope.modal = {};
        $scope.modal.title = name;
        $scope.modal.msgFileType = "T-V and DV";
        return $scope.modal.fileTypes = [
          {
            value: 'topicv',
            label: 'T-V Mapping'
          }, {
            value: 'dv',
            label: 'DV Mapping'
          }
        ];
      };
      $scope["import"] = function(id) {
        return AdminMappingImportsFactory["import"]($scope.mapping.files, $scope.mapping.type, 'POST', '/datasets/' + $scope.id + '/imports.json').then((function(response) {
          if (response.status === 200) {
            return Flash.add('success', 'File imported.');
          } else {
            return Flash.add('danger', 'Something went wrong, please import the file again.');
          }
        }), function(error) {
          console.log(error);
          return Flash.add('danger', 'Something went wrong, please import the file again.');
        });
      };
      $scope.prepareDelete = function(id) {
        return $scope.dataset = $scope.datasets.select_resource_by_id(id);
      };
      return $scope["delete"] = function() {
        return $scope.dataset.$delete({}, function() {
          DataManager.Data = {};
          $scope.datasets = DataManager.Dataset.requery();
          return Flash.add('success', 'Dataset deleted successfully');
        }, function(response) {
          console.error(response);
          return Flash.add('danger', 'Failed to delete dataset - ' + response.message);
        });
      };
    }
  ]);

  admin.controller('AdminImportController', [
    '$scope', '$http', 'Flash', function($scope, $http, Flash) {
      $scope.files = [];
      $scope.options = {
        question_grids: true
      };
      $scope.uploadInstrumentImport = function() {
        var fd, j, key, len, possible_options;
        $scope.publish_flash();
        fd = new FormData();
        angular.forEach($scope.files, function(item) {
          return fd.append('files[]', item);
        });
        possible_options = ['question_grids', 'instrument_prefix', 'instrument_agency', 'instrument_study'];
        for (j = 0, len = possible_options.length; j < len; j++) {
          key = possible_options[j];
          if ($scope.options[key] != null) {
            fd.set(key, $scope.options[key]);
          }
        }
        if ($scope.options) {
          return $http({
            method: 'POST',
            url: '/admin/import/instruments',
            data: fd,
            transformRequest: angular.identity,
            headers: {
              'Content-Type': void 0
            }
          }).success(function() {
            return Flash.add('success', 'Instrument imported.');
          }).error(function(res) {
            return Flash.add('danger', 'Instrument failed to import - ' + res.message);
          });
        }
      };
      return $scope.uploadDatasetImport = function() {
        var fd;
        $scope.publish_flash();
        fd = new FormData();
        angular.forEach($scope.files, function(item) {
          return fd.append('files[]', item);
        });
        return $http({
          method: 'POST',
          url: '/admin/import/datasets',
          data: fd,
          transformRequest: angular.identity,
          headers: {
            'Content-Type': void 0
          }
        }).success(function() {
          return Flash.add('success', 'Dataset imported.');
        }).error(function(res) {
          return Flash.add('danger', 'Dataset failed to import - ' + res.message);
        });
      };
    }
  ]);

  admin.controller('AdminExportController', [
    '$scope', '$http', 'DataManager', function($scope, $http, DataManager) {
      $scope.instruments = DataManager.Instruments.query({}, function(instruments) {
        return angular.forEach(instruments, function(v, k) {
          v.can_export = (Date.parse(v.export_time) < Date.parse(v.last_edited_time)) || v.export_time === null;
          return v.has_export = v.export_url !== null;
        });
      });
      $scope.pageSize = 24;
      $scope.currentPage = 1;
      console.log($scope);
      return $scope["export"] = function(instrument) {
        return $http.get('/instruments/' + instrument.id.toString() + '/export.json');
      };
    }
  ]);

  admin.factory('AdminMappingImportsFactory', [
    '$http', '$q', function($http, $q) {
      var MappingImports;
      MappingImports = {};
      MappingImports["import"] = function(files, filetype, method, url) {
        var data, i, params;
        i = 0;
        params = {};
        params.imports = [];
        while (i < files.length) {
          data = {
            file: files[i].base64,
            type: filetype[i]
          };
          params.imports.push(data);
          i++;
        }
        return $http({
          method: method,
          url: url,
          data: JSON.stringify(params)
        }).then((function(res) {
          console.log('imported');
          console.log(res);
          return res;
        }), function(res) {
          console.log(res);
          return $q.reject(res);
        });
      };
      return MappingImports;
    }
  ]);

}).call(this);
(function() {
  var users;

  users = angular.module('archivist.users', ['archivist.flash']);

  users.controller('UserController', [
    '$scope', '$location', '$http', '$route', 'User', 'DataManager', function($scope, $location, $http, $route, User, DataManager) {
      $scope.sign_in = function(cred) {
        $scope.user.set('email', cred.email);
        return $scope.user.sign_in(cred.password).then(function() {
          return $location.path('/instruments');
        }, function() {
          $scope.publish_flash();
          cred.password = "";
          DataManager.clearCache();
          $route.reload();
          return console.log('User logged in.');
        });
      };
      $scope.sign_up = function(details) {
        $scope.user.set('email', details.email);
        $scope.user.set('first_name', details.fname);
        $scope.user.set('last_name', details.lname);
        $scope.user.set('group_id', details.group);
        return $scope.user.sign_up(details.password, details.confirm).then(function() {
          $location.path('/instruments');
          return true;
        }, function() {
          $scope.publish_flash();
          details.password = "";
          details.confirm = "";
          DataManager.clearCache();
          $route.reload();
          return false;
        });
      };
      $http.get('/user_groups/external.json').then(function(res) {
        return $scope.sign_up_groups = res.data;
      });
      return console.log($scope);
    }
  ]);

  users.factory('User', [
    '$http', '$q', '$route', 'Flash', 'DataManager', function($http, $q, $route, Flash, DataManager) {
      return (function() {
        function _Class(email) {
          this.email = email;
          this.logged_in = false;
        }

        _Class.attributes = ['email', 'first_name', 'last_name', 'group', 'group_id', 'role'];

        _Class.prototype.sign_in = function(password) {
          var self;
          self = this;
          return $http.post('/users/sign_in.json', {
            user: {
              email: this.email,
              password: password,
              remember_me: 1
            }
          }).then(function(res) {
            DataManager.clearCache();
            $route.reload();
            self.logged_in = true;
            self.set('first_name', res.data.first_name);
            self.set('last_name', res.data.last_name);
            self.set('group', res.data.group);
            self.set('role', res.data.role);
            return true;
          }, function(res) {
            self.logged_in = false;
            Flash.add('danger', res.data.error);
            return $q.reject(res.data.error);
          });
        };

        _Class.prototype.sign_out = function() {
          var self;
          self = this;
          return $http["delete"]('/users/sign_out.json').then(function() {
            DataManager.clearCache();
            return $route.reload();
          })["finally"](function() {
            return self.logged_in = false;
          });
        };

        _Class.prototype.sign_up = function(password, confirmation) {
          var self;
          self = this;
          return $http.post('/users.json', {
            user: this.get_all_data({
              password: password,
              password_confirmation: confirmation
            })
          }).then(function(res) {
            DataManager.clearCache();
            $route.reload();
            self.logged_in = true;
            return self.set('role', res.data.role);
          }, function(res) {
            self.logged_in = false;
            return Flash.add('danger', res.errors);
          });
        };

        _Class.prototype.is_admin = function() {
          return this.get('role') === 'admin';
        };

        _Class.prototype.is_editor = function() {
          return this.get('role') === 'admin' || this.get('role') === 'editor';
        };

        _Class.prototype.get = function(attribute) {
          return this[attribute];
        };

        _Class.prototype.set = function(attribute, val) {
          return this[attribute] = val;
        };

        _Class.prototype.get_all_data = function(extra) {
          var attribute, i, key, len, output, ref;
          if (extra == null) {
            extra = {};
          }
          output = {};
          ref = this.constructor.attributes;
          for (i = 0, len = ref.length; i < len; i++) {
            attribute = ref[i];
            output[attribute] = this.get(attribute);
          }
          for (key in extra) {
            output[key] = extra[key];
          }
          return output;
        };

        return _Class;

      })();
    }
  ]);

}).call(this);
(function() {
  var datasets;

  datasets = angular.module('archivist.datasets', ['templates', 'ngRoute', 'archivist.datasets.index', 'archivist.datasets.show', 'archivist.datasets.edit', 'archivist.datasets.imports', 'archivist.datasets.imports.show']);

  datasets.config([
    '$routeProvider', function($routeProvider) {
      return $routeProvider.when('/datasets', {
        templateUrl: 'partials/datasets/index.html',
        controller: 'DatasetsIndexController'
      }).when('/datasets/:id', {
        templateUrl: 'partials/datasets/show.html',
        controller: 'DatasetsShowController'
      }).when('/datasets/:id/edit', {
        templateUrl: 'partials/datasets/edit.html',
        controller: 'DatasetsEditController'
      }).when('/datasets/:id/imports', {
        templateUrl: 'partials/datasets/imports/index.html',
        controller: 'DatasetsImportsController'
      }).when('/datasets/:dataset_id/imports/:id', {
        templateUrl: 'partials/datasets/imports/show.html',
        controller: 'DatasetsImportsShowController'
      });
    }
  ]);

}).call(this);
(function() {
  var index;

  index = angular.module('archivist.datasets.index', ['archivist.data_manager']);

  index.controller('DatasetsIndexController', [
    '$scope', '$http', 'DataManager', function($scope, $http, DataManager) {
      $scope.datasets = DataManager.getDatasets();
      $scope.pageSize = 24;
      $scope.currentPage = 1;
      $scope.filterStudy = function(study) {
        return $scope.filteredStudy = study;
      };
      $http.get('/studies.json').success(function(data) {
        return $scope.studies = data;
      });
      return console.log($scope);
    }
  ]);

}).call(this);
(function() {
  var show;

  show = angular.module('archivist.datasets.show', ['ngVis', 'archivist.data_manager']);

  show.controller('DatasetsShowController', [
    '$scope', '$routeParams', 'VisDataSet', 'DataManager', function($scope, $routeParams, VisDataSet, DataManager) {
      $scope.dataset = DataManager.getDataset($routeParams.id, {
        variables: true,
        questions: true
      }, function() {
        return $scope.breadcrumbs = [
          {
            label: 'Datasets',
            link: '/datasets',
            active: false
          }, {
            label: $scope.dataset.name,
            link: false,
            active: true
          }
        ];
      });
      $scope.pageSize = 20;
      $scope.currentPage = 1;
      $scope.graphData = {};
      $scope.graphOptions = {
        interaction: {
          dragNodes: false
        },
        layout: {
          hierarchical: {
            enabled: true,
            direction: 'LR'
          }
        }
      };
      $scope.graphEvents = {
        click: function(data) {
          var id, type;
          if (data.nodes.length === 1) {
            if (data.nodes[0] < 20000000) {
              type = 'CcQuestion';
              id = data.nodes[0] - 10000000;
            } else {
              type = 'Variable';
              id = data.nodes[0] - 20000000;
            }
            return console.log($scope);
          }
        }
      };
      $scope.split_mapping = function(model, other, x, y) {
        if (x == null) {
          x = null;
        }
        if (y == null) {
          y = null;
        }
        return model.$split_mapping({
          other: {
            "class": other["class"],
            id: other.id
          },
          x: x,
          y: y
        });
      };
      $scope.detectKey = function(event, variable, x, y) {
        var new_sources;
        if (x == null) {
          x = null;
        }
        if (y == null) {
          y = null;
        }
        if (event.keyCode === 13) {
          new_sources = event.target.value.split(',');
          DataManager.addSources(variable, new_sources, x, y).then(function() {
            return $scope.model.orig_topic = $scope.model.topic;
          }, function(reason) {
            return variable.errors = reason.data.message;
          });
        }
        return console.log(variable);
      };
      return console.log($scope);
    }
  ]);

}).call(this);
(function() {
  var edit;

  edit = angular.module('archivist.datasets.edit', ['archivist.data_manager']);

  edit.controller('DatasetsEditController', [
    '$http', '$scope', '$routeParams', '$location', 'Flash', 'DataManager', function($http, $scope, $routeParams, $location, Flash, DataManager) {
      $scope.dataset = DataManager.getDataset($routeParams.id, {}, function() {
        $scope.page['title'] = $scope.dataset.name + ' | Edit';
        return $scope.breadcrumbs = [
          {
            label: 'Datasets',
            link: '/datasets',
            active: false
          }, {
            label: $scope.dataset.name,
            link: '/datasets/' + $scope.dataset.id,
            active: false
          }, {
            label: 'Edit',
            link: false,
            active: true
          }
        ];
      });
      $http.get('/studies.json').success(function(data) {
        return $scope.studies = data;
      });
      return $scope.updateDataset = function() {
        return $scope.dataset.$save({}, function() {
          Flash.add('success', 'Dataset updated successfully!');
          $location.path('/datasets');
          return DataManager.clearCache();
        }, function() {
          return Flash.add('error', 'Dataset could not be updated.');
        });
      };
    }
  ]);

}).call(this);
(function() {
  var imports;

  imports = angular.module('archivist.datasets.imports', ['ngVis', 'archivist.data_manager']);

  imports.controller('DatasetsImportsController', [
    '$scope', '$routeParams', 'VisDataSet', 'DataManager', function($scope, $routeParams, VisDataSet, DataManager) {
      $scope.dataset = DataManager.getDataset($routeParams.id, {}, function() {
        $scope.page['title'] = $scope.dataset.name + ' | Edit';
        return $scope.breadcrumbs = [
          {
            label: 'Datasets',
            link: '/admin/datasets',
            active: false
          }, {
            label: $scope.dataset.name,
            link: '/datasets/' + $scope.dataset.id,
            active: false
          }, {
            label: 'Imports',
            link: false,
            active: true
          }
        ];
      });
      return $scope.imports = DataManager.getDatasetImports({
        dataset_id: $routeParams.id
      });
    }
  ]);

}).call(this);
(function() {
  var show;

  show = angular.module('archivist.datasets.imports.show', ['ngVis', 'archivist.data_manager']);

  show.controller('DatasetsImportsShowController', [
    '$scope', '$routeParams', 'VisDataSet', 'DataManager', function($scope, $routeParams, VisDataSet, DataManager) {
      $scope.dataset = DataManager.getDataset($routeParams.dataset_id, {}, function() {
        $scope.page['title'] = $scope.dataset.name + ' | Edit';
        return $scope.breadcrumbs = [
          {
            label: 'Datasets',
            link: '/admin/datasets',
            active: false
          }, {
            label: $scope.dataset.name,
            link: '/datasets/' + $scope.dataset.id,
            active: false
          }, {
            label: 'Imports',
            link: '/datasets/' + $scope.dataset.id + '/imports',
            active: false
          }, {
            label: $routeParams.id,
            link: false,
            active: true
          }
        ];
      });
      return $scope["import"] = DataManager.getDatasetImportsx({
        dataset_id: $routeParams.dataset_id,
        id: $routeParams.id
      });
    }
  ]);

}).call(this);
(function() {


}).call(this);
(function() {
  var instruments;

  instruments = angular.module('archivist.instruments', ['templates', 'ngRoute', 'ngResource', 'ui.bootstrap', 'archivist.flash', 'archivist.data_manager', 'naif.base64']);

  instruments.config([
    '$routeProvider', function($routeProvider) {
      return $routeProvider.when('/instruments', {
        templateUrl: 'partials/instruments/index.html',
        controller: 'InstrumentsController'
      }).when('/instruments/:id', {
        templateUrl: 'partials/instruments/show.html',
        controller: 'InstrumentsController'
      }).when('/instruments/:id/edit', {
        templateUrl: 'partials/instruments/edit.html',
        controller: 'InstrumentsController'
      }).when('/instruments/:id/import', {
        templateUrl: 'partials/instruments/import.html',
        controller: 'InstrumentsController'
      }).when('/instruments/:id/imports', {
        templateUrl: 'partials/instruments/imports/index.html',
        controller: 'InstrumentsImportsController'
      }).when('/instruments/:instrument_id/imports/:id', {
        templateUrl: 'partials/instruments/imports/show.html',
        controller: 'InstrumentsImportsShowController'
      });
    }
  ]);

  instruments.controller('InstrumentsController', [
    '$scope', '$routeParams', '$location', '$q', '$http', '$timeout', 'Flash', 'DataManager', 'Base64Factory', function($scope, $routeParams, $location, $q, $http, $timeout, Flash, DataManager, Base64Factory) {
      var loadStructure, loadStudies, progressUpdate;
      $scope.page['title'] = 'Instruments';
      if ($routeParams.id) {
        loadStructure = $location.path().split("/")[$location.path().split("/").length - 1].toLowerCase() !== 'edit';
        loadStudies = !loadStructure;
        $scope.loading = {
          state: "Downloading",
          progress: 0,
          type: "info"
        };
        progressUpdate = function(newValue) {
          $scope.loading.progress = newValue;
          if ($scope.loading.progress > 99) {
            $scope.loading.state = "Processing";
            return $scope.loading.type = "success";
          }
        };
        $scope.instrument = DataManager.getInstrument($routeParams.id, {
          constructs: loadStructure,
          questions: loadStructure,
          progress: progressUpdate
        }, function() {
          $scope.page['title'] = $scope.instrument.prefix + ' | Edit';
          return $timeout(function() {
            if (loadStructure) {
              $scope.page['title'] = $scope.instrument.prefix + ' | View';
              DataManager.resolveConstructs();
              DataManager.resolveQuestions();
              console.log($scope);
            }
            $scope.breadcrumbs = [
              {
                label: 'Instruments',
                link: '/instruments',
                active: false
              }, {
                label: $scope.instrument.prefix,
                link: false,
                active: false,
                subs: [
                  {
                    label: loadStructure ? 'Edit' : 'View',
                    link: '/instruments/' + $routeParams.id + (loadStructure ? '/edit' : '')
                  }, {
                    label: 'Build',
                    link: '/instruments/' + $routeParams.id + '/build'
                  }, {
                    label: 'Map',
                    link: '/instruments/' + $routeParams.id + '/map'
                  }
                ]
              }, {
                label: loadStructure ? 'View' : 'Edit',
                link: false,
                active: true
              }
            ];
            return $scope.loading.state = "Done";
          }, 100);
        });
      } else {
        $scope.instruments = DataManager.getInstruments();
        $scope.pageSize = 24;
        $scope.currentPage = 1;
        $scope.filterStudy = function(study) {
          return $scope.filteredStudy = study;
        };
        $http.get('/studies.json').success(function(data) {
          return $scope.studies = data;
        });
      }
      return $scope.updateInstrument = function() {
        return $scope.instrument.$save({}, function() {
          Flash.add('success', 'Instrument updated successfully!');
          $location.path('/instruments');
          return DataManager.clearCache();
        }, function() {
          return console.log("error");
        });
      };
    }
  ]);

  instruments.controller('InstrumentsImportsController', [
    '$scope', '$routeParams', 'VisDataSet', 'DataManager', function($scope, $routeParams, VisDataSet, DataManager) {
      $scope.instrument = DataManager.getInstrument($routeParams.id, {}, function() {
        $scope.page['title'] = $scope.instrument.prefix + ' | Imports';
        return $scope.breadcrumbs = [
          {
            label: 'Instruments',
            link: '/admin/instruments',
            active: false
          }, {
            label: $scope.instrument.prefix,
            link: '/instruments/' + $scope.instrument.slug,
            active: false
          }, {
            label: 'Imports',
            link: false,
            active: true
          }
        ];
      });
      return $scope.imports = DataManager.getInstrumentImports({
        instrument_id: $routeParams.id
      });
    }
  ]);

  instruments.controller('InstrumentsImportsShowController', [
    '$scope', '$routeParams', 'VisDataSet', 'DataManager', function($scope, $routeParams, VisDataSet, DataManager) {
      $scope.instrument = DataManager.getInstrument($routeParams.instrument_id, {}, function() {
        $scope.page['title'] = $scope.instrument.prefix + ' | Imports';
        return $scope.breadcrumbs = [
          {
            label: 'Instruments',
            link: '/admin/instruments',
            active: false
          }, {
            label: $scope.instrument.prefix,
            link: '/instruments/' + $scope.instrument.slug,
            active: false
          }, {
            label: 'Imports',
            link: '/instruments/' + $scope.instrument.slug + '/imports',
            active: false
          }, {
            label: $routeParams.id,
            link: false,
            active: true
          }
        ];
      });
      return $scope["import"] = DataManager.getInstrumentImport({
        instrument_id: $routeParams.instrument_id,
        id: $routeParams.id
      });
    }
  ]);

  instruments.factory('Base64Factory', [
    '$q', function($q) {
      return {
        getBase64: function(file) {
          var deferred, readerMapping;
          deferred = $q.defer();
          readerMapping = new FileReader;
          readerMapping.readAsDataURL(file);
          readerMapping.onload = function() {
            deferred.resolve(readerMapping.result);
          };
          readerMapping.onerror = function(error) {
            deferred.reject(error);
          };
          return deferred.promise;
        }
      };
    }
  ]);

}).call(this);
(function() {
  var build;

  build = angular.module('archivist.build', ['templates', 'ngRoute', 'archivist.flash', 'archivist.data_manager']);

  build.config([
    '$routeProvider', 'treeConfig', function($routeProvider, treeConfig) {
      $routeProvider.when('/instruments/:id/build', {
        templateUrl: 'partials/build/index.html',
        controller: 'BuildMenuController'
      }).when('/instruments/:id/build/code_lists/:code_list_id?', {
        templateUrl: 'partials/build/editor.html',
        controller: 'BuildCodeListsController'
      }).when('/instruments/:id/build/response_domains/:response_domain_type?/:response_domain_id?', {
        templateUrl: 'partials/build/editor.html',
        controller: 'BuildResponseDomainsController'
      }).when('/instruments/:id/build/questions/:question_type?/:question_id?', {
        templateUrl: 'partials/build/editor.html',
        controller: 'BuildQuestionsController'
      }).when('/instruments/:id/build/constructs', {
        templateUrl: 'partials/build/editor.html',
        controller: 'BuildConstructsController',
        reloadOnSearch: false
      });
      treeConfig.placeholderClass = 'a-tree-placeholder a-construct list-group-item';
      treeConfig.hiddenClass = 'a-tree-hidden';
      return treeConfig.dragClass = 'a-tree-drag';
    }
  ]);

}).call(this);
(function() {
  angular.module('archivist.build').controller('BaseBuildController', [
    '$scope', '$routeParams', '$location', '$timeout', 'Flash', 'DataManager', function($scope, $routeParams, $location, $timeout, Flash, DataManager) {
      $scope.page['title'] = $scope.title;
      $scope.underscored = $scope.title.toLowerCase().replaceAll(' ', '_');
      $scope.main_panel = "partials/build/" + $scope.underscored + ".html";
      $scope.url_path_args = $location.path().split('/');
      $scope.newMode = $scope.url_path_args.slice(0).pop() === 'new';
      if (typeof $scope.before_instrument_loaded === "function") {
        $scope.before_instrument_loaded();
      }
      $scope.instrument = DataManager.getInstrument($routeParams.id, $scope.instrument_options, function() {
        if ($scope.instrument.signed_off) {
          return window.location.href = '/instruments';
        } else {
          $scope.page['title'] = $scope.instrument.prefix + ' | ' + $scope.title;
          $scope.reset();
          $scope.breadcrumbs = [
            {
              label: 'Instruments',
              link: '/instruments',
              active: false
            }, {
              label: $scope.instrument.prefix,
              link: '/instruments/' + $scope.instrument.id.toString(),
              active: false
            }, {
              label: 'Build',
              link: '/instruments/' + $scope.instrument.id.toString() + '/build',
              active: false
            }, {
              label: $scope.title,
              link: false,
              active: true
            }
          ];
          $timeout(function() {
            return jQuery('.first-field').first().focus();
          }, 0);
          if (typeof $scope.after_instrument_loaded === "function") {
            $scope.after_instrument_loaded();
          }
          return console.log($scope);
        }
      });
      if ($scope.cancel == null) {
        $scope.cancel = function() {
          console.log("cancel called");
          if ($scope.newMode) {
            $scope.editMode = $scope.newMode = false;
          } else {
            $scope.reset();
          }
          return null;
        };
      }
      if ($scope.edit_path == null) {
        $scope.edit_path = function(obj) {
          var terms;
          terms = ['instruments', $scope.instrument.id, 'build'];
          if ($scope.extra_url_parameters) {
            terms = terms.concat($scope.extra_url_parameters);
          }
          if (obj != null) {
            if (obj.type != null) {
              terms.push((obj.type.replace(/([A-Z])/g, function(x, y) {
                return "_" + y.toLowerCase();
              }).replace(/^_/, '')) + 's');
            }
            terms.push(obj.id);
          }
          return terms.join('/');
        };
      }
      if ($scope.startEditMode == null) {
        $scope.startEditMode = function() {
          $scope.editMode = true;
          console.log($scope.current);
          return null;
        };
      }
      if ($scope.startFragmentFormMode == null) {
        $scope.startFragmentFormMode = function() {
          $scope.fragmentFormMode = true;
          console.log($scope.current);
          return null;
        };
      }
      if ($scope.endFragmentFormMode == null) {
        $scope.endFragmentFormMode = function() {
          $scope.fragmentFormMode = false;
          $scope.current.fragment_xml = '';
          return null;
        };
      }
      if ($scope.openFragmentXML == null) {
        $scope.openFragmentXML = function() {
          window.open("/instruments/" + $scope.current.instrument_id + "/question_items/" + $scope.current.id + ".xml");
          return null;
        };
      }
      if ($scope.change_panel == null) {
        return $scope.change_panel = function(obj) {
          localStorage.setItem('sidebar_scroll', jQuery('.sidebar').scrollTop());
          return $location.url($scope.edit_path(obj));
        };
      }
    }
  ]);

}).call(this);
(function() {
  var slice = [].slice;

  angular.module('archivist.build').controller('BuildCodeListsController', [
    '$controller', '$scope', '$routeParams', '$location', '$filter', '$timeout', 'Flash', 'DataManager', function($controller, $scope, $routeParams, $location, $filter, $timeout, Flash, DataManager) {
      console.log('called code_list controller');
      $scope.load_sidebar = function() {
        var get_count_from_used_by, obj;
        get_count_from_used_by = function(cl) {
          cl.count = cl.used_by.length;
          return cl;
        };
        $scope.sidebar_objs = ((function() {
          var j, len, ref, results;
          ref = $scope.instrument.CodeLists;
          results = [];
          for (j = 0, len = ref.length; j < len; j++) {
            obj = ref[j];
            results.push(get_count_from_used_by(obj));
          }
          return results;
        })()).sort_by_property();
        DataManager.Data.Codes.Categories.$promise.then(function() {
          return $scope.categories = DataManager.Data.Codes.Categories;
        });
        return $timeout(function() {
          var offset;
          offset = localStorage.getItem('sidebar_scroll');
          if (offset !== null) {
            console.log(offset);
            jQuery('.sidebar').scrollTop(offset);
            return localStorage.removeItem('sidebar_scroll');
          }
        }, 0);
      };
      $scope["delete"] = function() {
        var index;
        index = $scope.instrument.CodeLists.get_index_by_id(parseInt($routeParams.code_list_id));
        if (index != null) {
          return $scope.instrument.CodeLists[index].$delete({}, function() {
            $scope.instrument.CodeLists.splice(index, 1);
            $scope.load_sidebar();
            return $timeout(function() {
              if ($scope.instrument.CodeLists.length > 0) {
                return $scope.change_panel($scope.instrument.CodeLists[0]);
              } else {
                return $scope.change_panel({
                  type: 'CodeList',
                  id: 'new'
                });
              }
            }, 0);
          });
        }
      };
      $scope.save = function() {
        var index;
        console.log($scope.current);
        if ($routeParams.code_list_id === 'new') {
          $scope.instrument.CodeLists.push($scope.current);
          index = $scope.instrument.CodeLists.length - 1;
          $scope.instrument.CodeLists[index].instrument_id = $routeParams.id;
        } else {
          angular.copy($scope.current, $scope.instrument.CodeLists.select_resource_by_id(parseInt($routeParams.code_list_id)));
          index = $scope.instrument.CodeLists.get_index_by_id(parseInt($routeParams.code_list_id));
        }
        $scope.instrument.CodeLists[index].save({}, function(value, rh) {
          value['instrument_id'] = $scope.instrument.id;
          Flash.add('success', 'Code list updated successfully!');
          $scope.reset();
          $scope.load_sidebar();
          DataManager.Data.Codes.Categories = DataManager.Codes.Categories.requery({
            instrument_id: $scope.instrument.id
          });
          DataManager.Data.ResponseDomains.Codes = DataManager.ResponseDomains.Codes.requery({
            instrument_id: $scope.instrument.id
          });
          DataManager.Data.Codes.Categories.$promise.then(function() {
            return $scope.categories = DataManager.Data.Codes.Categories;
          });
          return DataManager.Data.ResponseDomains.Codes.$promise.then(function() {
            return DataManager.groupResponseDomains();
          });
        }, function(value, rh) {
          return Flash.add('danger', 'Code list failed to update! ' + value.data.error_sentence);
        });
        return DataManager.Data.ResponseDomains[$routeParams.id] = null;
      };
      $scope.title = 'Code Lists';
      $scope.instrument_options = {
        codes: true
      };
      $scope.reset = function() {
        console.log("reset called");
        if (DataManager.CodeResolver == null) {
          DataManager.resolveCodes();
        }
        if (!isNaN($routeParams.code_list_id)) {
          $scope.current = angular.copy($scope.instrument.CodeLists.select_resource_by_id(parseInt($routeParams.code_list_id)));
          $scope.editMode = false;
        }
        if ($routeParams.code_list_id === 'new') {
          $scope.editMode = true;
          return $scope.current = new DataManager.Codes.CodeLists.resource({
            codes: []
          });
        }
      };
      $scope["new"] = function() {
        return $scope.change_panel({
          type: 'CodeList',
          id: 'new'
        });
      };
      $scope.removeCode = function(code) {
        var c, i, results;
        $scope.current.codes = (function() {
          var j, len, ref, results;
          ref = $scope.current.codes;
          results = [];
          for (j = 0, len = ref.length; j < len; j++) {
            c = ref[j];
            if (c.$$hashKey !== code.$$hashKey) {
              results.push(c);
            }
          }
          return results;
        })();
        $scope.current.codes.sort(function(a, b) {
          return a.order - b.order;
        });
        results = [];
        for (i in $scope.current.codes) {
          results.push($scope.current.codes[i].order = parseInt(i));
        }
        return results;
      };
      $scope.moveUp = function(code) {
        return $scope.moveCode(code, -1);
      };
      $scope.moveDown = function(code) {
        return $scope.moveCode(code, 1);
      };
      $scope.moveCode = function(code, shift) {
        var being_moved, i, original_index, ref, results;
        original_index = $scope.current.codes.findIndex(function(c) {
          return c.$$hashKey === code.$$hashKey;
        });
        if (original_index + shift < 0 || original_index + shift >= $scope.current.codes.length) {
          return false;
        }
        being_moved = $scope.current.codes.splice(original_index, 1);
        (ref = $scope.current.codes).splice.apply(ref, [original_index + shift, 0].concat(slice.call(being_moved)));
        results = [];
        for (i in $scope.current.codes) {
          results.push($scope.current.codes[i].order = parseInt(i));
        }
        return results;
      };
      $scope.after_instrument_loaded = function() {
        $scope.categories = DataManager.Data.Codes.Categories;
        console.log($scope.sidebar_objs);
        $scope.load_sidebar();
        return $scope.$watch('current.newValue', function(newVal, oldVal, scope) {
          var i;
          console.log(newVal, oldVal, scope);
          if (newVal !== oldVal) {
            if (newVal != null) {
              scope.current.codes.push({
                id: null,
                value: newVal,
                category: null
              });
              for (i in $scope.current.codes) {
                $scope.current.codes[i].order = parseInt(i);
              }
              $scope.current.newValue = null;
              return $timeout(function() {
                var strLength;
                jQuery('.code-value').last().focus();
                strLength = jQuery('.code-value').last().val().length * 2;
                return jQuery('.code-value').last()[0].setSelectionRange(strLength, strLength);
              }, 0);
            }
          }
        });
      };
      return $controller('BaseBuildController', {
        $scope: $scope,
        $routeParams: $routeParams,
        $location: $location,
        Flash: Flash,
        DataManager: DataManager
      });
    }
  ]);

}).call(this);
(function() {
  angular.module('archivist.build').controller('BuildConstructsController', [
    '$controller', '$scope', '$routeParams', '$location', '$filter', '$http', '$timeout', 'bsLoadingOverlayService', 'Flash', 'DataManager', function($controller, $scope, $routeParams, $location, $filter, $http, $timeout, bsLoadingOverlayService, Flash, DataManager) {
      console.time('end to end');
      $scope.title = 'Constructs';
      $scope.details_bar = true;
      $scope.hide_edit_buttons = true;
      $scope.extra_url_parameters = ['constructs'];
      $scope.instrument_options = {
        constructs: true,
        questions: true,
        rus: true
      };
      $scope.index = {};
      $scope.details_path = function() {
        return 'partials/build/details/' + $routeParams.construct_type + '.html';
      };
      $scope.setIndex = function(parent_id, parent_type, branch) {
        if (branch == null) {
          branch = null;
        }
        if (parent_id != null) {
          $scope.index.parent_id = parent_id;
          $scope.index.parent_type = parent_type;
        } else {
          $scope.index.parent_id = $scope.instrument.topsequence.id;
          $scope.index.parent_type = 'sequence';
        }
        return $scope.index.branch = branch;
      };
      $scope.$on('$routeUpdate', function(scope, next, current) {
        return $scope.reset();
      });
      $scope.change_panel = function(obj) {
        $location.search({
          construct_type: obj.type,
          construct_id: obj.id
        });
        return $scope.editMode = (obj.type != null) && (obj.id != null);
      };
      $scope.treeOptions = {
        dropped: function() {
          var positionUpdater;
          bsLoadingOverlayService.start();
          $scope.updates = [];
          positionUpdater = function(parent) {
            var child_dimensions, child_key, dimension, i, index, len, results;
            child_dimensions = ['children', 'fchildren'];
            results = [];
            for (index = i = 0, len = child_dimensions.length; i < len; index = ++i) {
              dimension = child_dimensions[index];
              if (parent[dimension] != null) {
                results.push((function() {
                  var results1;
                  results1 = [];
                  for (child_key in parent[dimension]) {
                    if (parent[dimension].hasOwnProperty(child_key)) {
                      if (parent[dimension][child_key].position !== (parseInt(child_key)) + 1 || parent[dimension][child_key].parent !== parent.id || (parent[dimension][child_key].branch !== index && Number.isInteger(parent[dimension][child_key].branch))) {
                        $scope.updates.push({
                          id: parent[dimension][child_key].id,
                          type: parent[dimension][child_key].type,
                          position: (parseInt(child_key)) + 1,
                          parent: {
                            id: parent.id,
                            type: parent.type
                          },
                          branch: index
                        });
                        parent[dimension][child_key].position = $scope.updates[$scope.updates.length - 1]['position'];
                        parent[dimension][child_key].parent = $scope.updates[$scope.updates.length - 1]['parent'];
                      }
                      results1.push(positionUpdater(parent[dimension][child_key]));
                    } else {
                      results1.push(void 0);
                    }
                  }
                  return results1;
                })());
              } else {
                results.push(void 0);
              }
            }
            return results;
          };
          positionUpdater($scope.instrument.topsequence);
          return $http.post('/instruments/' + $scope.instrument.id.toString() + '/reorder_ccs.json', {
            updates: $scope.updates
          })["finally"](function() {
            return bsLoadingOverlayService.stop();
          });
        }
      };
      $scope.toggle = function(scope) {
        return scope.toggle();
      };
      $scope["delete"] = function() {
        var arr, index, obj;
        arr = $scope.instrument.Constructs[$routeParams.construct_type.capitalizeFirstLetter() + 's'];
        index = arr.get_index_by_id(parseInt($routeParams.construct_id));
        if (index != null) {
          obj = arr[index];
          if (obj.children === void 0 || confirm("Deleting this construct will also delete all of it's children. Are you sure you want to delete this construct?")) {
            return arr[index].$delete({}, function() {
              var obj_to_remove, scan;
              obj_to_remove = arr[index].$$hashKey;
              arr.splice(index, 1);
              scan = function(obj, key) {
                var child, i, j, len, len1, ref, ref1;
                if (obj.children !== void 0) {
                  ref = obj.children;
                  for (index = i = 0, len = ref.length; i < len; index = ++i) {
                    child = ref[index];
                    if (child.$$hashKey === key) {
                      obj.children.splice(index, 1);
                      return true;
                    } else {
                      if (scan(child, key)) {
                        return true;
                      }
                    }
                  }
                  if (obj.fchildren !== void 0) {
                    ref1 = obj.fchildren;
                    for (index = j = 0, len1 = ref1.length; j < len1; index = ++j) {
                      child = ref1[index];
                      if (child.$$hashKey === key) {
                        obj.fchildren.splice(index, 1);
                        return true;
                      } else {
                        if (scan(child, key)) {
                          return true;
                        }
                      }
                    }
                  }
                }
                return false;
              };
              scan($scope.instrument.topsequence, obj_to_remove);
              return $timeout(function() {
                return $scope.change_panel({
                  type: null,
                  id: null
                });
              }, 0);
            });
          }
        }
      };
      $scope.save_construct = function() {
        var arr, index;
        arr = $scope.instrument.Constructs[$routeParams.construct_type.capitalizeFirstLetter() + 's'];
        console.log('<<<<<<<<');
        console.log('Arr variable: ');
        console.log(arr);
        console.log('<<<<<<<<');
        if ($routeParams.construct_id === 'new') {
          console.info('Adding a new construct');
          arr.push($scope.current);
          index = arr.length - 1;
          arr[index].instrument_id = $routeParams.id;
        } else {
          console.info('Construct id: ' + $routeParams.construct_id);
          console.info('Saving an existing construct');
          console.log('-------------------------------------------------------');
          console.log('Current scope: ');
          console.log($scope.current);
          console.log('-------------------------------------------------------');
          angular.copy($scope.current, arr.select_resource_by_id(parseInt($routeParams.construct_id)));
          index = arr.get_index_by_id(parseInt($routeParams.construct_id));
          console.log('-------------------------------------------------------');
          console.log('Array index: ' + index);
          console.log('Parent id: ' + $scope.current.parent_id + ' | ' + 'Parent type: ' + $scope.current.parent_type);
          console.log('-------------------------------------------------------');
        }
        return arr[index].save({}, function(value, rh) {
          var child, child_obj, i, j, len, len1, parent, ref, ref1, type;
          value['instrument_id'] = $scope.instrument.id;
          value['type'] = $routeParams.construct_type;
          Flash.add('success', 'Construct updated successfully!');
          if ($routeParams.construct_id === 'new') {
            parent = DataManager.Data.Instrument.Constructs[$scope.index.parent_type.capitalizeFirstLetter() + 's'].select_resource_by_id($scope.index.parent_id);
            if ($scope.index.branch === 0 || $scope.index.branch === null) {
              parent.children.push(arr[index]);
            } else {
              parent.fchildren.push(arr[index]);
            }
            $scope.change_panel(arr[index]);
          } else {
            if (value.children !== void 0) {
              ref = value.children;
              for (index = i = 0, len = ref.length; i < len; index = ++i) {
                child = ref[index];
                type = child.type.replace('Cc', '');
                child_obj = DataManager.Data.Instrument.Constructs[type.capitalizeFirstLetter() + 's'].select_resource_by_id(child.id);
                value.children[index] = child_obj;
              }
            }
            if (value.fchildren !== void 0) {
              ref1 = value.fchildren;
              for (index = j = 0, len1 = ref1.length; j < len1; index = ++j) {
                child = ref1[index];
                type = child.type.replace('Cc', '');
                child_obj = DataManager.Data.Instrument.Constructs[type.capitalizeFirstLetter() + 's'].select_resource_by_id(child.id);
                value.fchildren[index] = child_obj;
              }
            }
          }
          $scope.change_panel({
            type: null,
            id: null
          });
          return $scope.reset();
        }, function() {
          Flash.add('danger', 'Construct failed to update');
          return console.error("Construct failed to update - save_construct (Cannot connect to Redis)");
        });
      };
      $scope.reset = function() {
        var cc, i, len, ref;
        if (($routeParams.construct_type != null) && !isNaN(parseInt($routeParams.construct_id))) {
          ref = $scope.instrument.Constructs[$routeParams.construct_type.capitalizeFirstLetter() + 's'];
          for (i = 0, len = ref.length; i < len; i++) {
            cc = ref[i];
            if (cc.type.pascal_case_to_underscore() === $routeParams.construct_type && cc.id.toString() === $routeParams.construct_id.toString()) {
              $scope.current = angular.copy(cc);
              break;
            }
          }
        }
        return null;
      };
      $scope.build_ru_options = function() {
        var i, len, ref, results, ru;
        $scope.details.ru_options = [];
        ref = $scope.instrument.ResponseUnits;
        results = [];
        for (i = 0, len = ref.length; i < len; i++) {
          ru = ref[i];
          results.push($scope.details.ru_options.push({
            value: ru.id,
            label: ru.label
          }));
        }
        return results;
      };
      $scope.after_instrument_loaded = function() {
        var constructSorter, sortChildren;
        console.time('after instrument');
        constructSorter = function(a, b) {
          return a.position > b.position;
        };
        if (!$scope.instrument.topsequence.resolved) {
          DataManager.resolveConstructs();
          DataManager.resolveQuestions();
          sortChildren = function(parent) {
            var child, i, j, len, len1, ref, ref1, results;
            if (parent.children != null) {
              parent.children.sort(constructSorter);
              ref = parent.children;
              for (i = 0, len = ref.length; i < len; i++) {
                child = ref[i];
                sortChildren(child);
              }
              if (parent.fchildren != null) {
                parent.fchildren.sort(constructSorter);
                ref1 = parent.fchildren;
                results = [];
                for (j = 0, len1 = ref1.length; j < len1; j++) {
                  child = ref1[j];
                  results.push(sortChildren(child));
                }
                return results;
              }
            }
          };
          sortChildren($scope.instrument.topsequence);
        }
        $scope.details = {};
        $scope.details.options = DataManager.getQuestionIDs();
        $scope.build_ru_options();
        console.timeEnd('after instrument');
        return console.timeEnd('end to end');
      };
      $scope.save_ru = function(new_interviewee) {
        DataManager.Data.ResponseUnits.push(new DataManager.ResponseUnits.resource({
          label: new_interviewee.label,
          instrument_id: $routeParams.id
        }));
        return DataManager.Data.ResponseUnits[DataManager.Data.ResponseUnits.length - 1].save({}, function(value, rh) {
          value['instrument_id'] = $scope.instrument.id;
          return $scope.build_ru_options();
        });
      };
      $scope["new"] = function(cc_type) {
        var resource;
        if (cc_type === 'question') {
          resource = DataManager.Constructs.Questions.cc.resource;
        } else {
          resource = DataManager.Constructs[cc_type.capitalizeFirstLetter() + 's'].resource;
        }
        $scope.current = new resource({
          type: cc_type,
          parent: {
            id: $scope.index.parent_id,
            type: $scope.index.parent_type
          },
          branch: $scope.index.branch
        });
        $location.search({
          construct_type: cc_type,
          construct_id: 'new'
        });
        return $scope.editMode = true;
      };
      console.time('load base');
      $controller('BaseBuildController', {
        $scope: $scope,
        $routeParams: $routeParams,
        $location: $location,
        Flash: Flash,
        DataManager: DataManager
      });
      return console.timeEnd('load base');
    }
  ]);

  angular.module('archivist.build').controller('BuildConstructsFirstBranchController', [
    '$scope', function($scope) {
      return $scope.branch = $scope.obj.type === 'condition' ? 0 : null;
    }
  ]);

  angular.module('archivist.build').controller('BuildConstructsSecondBranchController', [
    '$scope', function($scope) {
      return $scope.branch = 1;
    }
  ]);

}).call(this);
(function() {
  angular.module('archivist.build').controller('BuildMenuController', [
    '$scope', '$routeParams', 'DataManager', function($scope, $routeParams, DataManager) {
      $scope.code_lists_url = '/instruments/' + $routeParams.id + '/build/code_lists';
      $scope.response_domains_url = '/instruments/' + $routeParams.id + '/build/response_domains';
      $scope.questions_url = '/instruments/' + $routeParams.id + '/build/questions';
      $scope.constructs_url = '/instruments/' + $routeParams.id + '/build/constructs';
      $scope.summary_url = function(arg) {
        return '/instruments/' + $routeParams.id + '/summary/' + arg;
      };
      $scope.instrumentCore = DataManager.getInstrument($routeParams.id, {}, function() {
        if ($scope.instrumentCore.signed_off) {
          return window.location.href = '/instruments';
        }
      });
      return $scope.instrument = DataManager.getInstrumentStats($routeParams.id, function() {
        $scope.stats = $scope.instrument.stats;
        return $scope.breadcrumbs = [
          {
            label: 'Instruments',
            link: '/instruments',
            active: false
          }, {
            label: $scope.instrument.prefix,
            link: '/instruments/' + $routeParams.id,
            active: false
          }, {
            label: 'Build',
            link: false,
            active: true
          }
        ];
      });
    }
  ]);

}).call(this);
(function() {
  angular.module('archivist.build').controller('BuildQuestionsController', [
    '$controller', '$scope', '$routeParams', '$location', '$timeout', 'Flash', 'DataManager', function($controller, $scope, $routeParams, $location, $timeout, Flash, DataManager) {
      $scope.load_sidebar = function() {
        return $scope.sidebar_objs = $scope.instrument.Questions.Items.concat($scope.instrument.Questions.Grids).sort_by_property();
      };
      $scope.add_rd = function(rd) {
        if ($routeParams.question_type === 'question_items') {
          if ($scope.current.rds == null) {
            $scope.current.rds = [];
          }
          return $scope.current.rds.push(rd);
        } else {
          $scope.current_grid_column.rd = rd;
          jQuery('#add-rd').modal('hide');
          return true;
        }
      };
      $scope.remove_rd = function(rd_or_col) {
        var index;
        if ($routeParams.question_type === 'question_items') {
          index = $scope.current.rds.indexOf(rd_or_col);
          return $scope.current.rds.splice(index, 1);
        } else {
          return rd_or_col.rd = null;
        }
      };
      $scope["delete"] = function() {
        var index, qtype;
        if ($routeParams.question_type === 'question_items') {
          qtype = 'Items';
        } else {
          qtype = 'Grids';
        }
        if (qtype != null) {
          index = $scope.instrument.Questions[qtype].get_index_by_id(parseInt($routeParams.question_id));
          if (index != null) {
            return $scope.instrument.Questions[qtype][index].$delete({}, function() {
              $scope.instrument.Questions[qtype].splice(index, 1);
              $scope.load_sidebar();
              return $timeout(function() {
                if ($scope.instrument.Questions[qtype].length > 0) {
                  return $scope.change_panel($scope.instrument.Questions[qtype][0]);
                } else {
                  return $scope.change_panel({
                    type: $routeParams.question_type,
                    id: 'new'
                  });
                }
              }, 0);
            });
          }
        }
      };
      $scope.select_x_axis = function() {
        return $scope.current.cols = angular.copy($scope.instrument.CodeLists.select_resource_by_id($scope.current.horizontal_code_list_id).codes);
      };
      $scope.set_grid_column = function(col) {
        return $scope.current_grid_column = col;
      };
      $scope.save = function() {
        var index, qtype;
        if ($routeParams.question_type === 'question_items') {
          qtype = 'Items';
        } else {
          qtype = 'Grids';
        }
        if (qtype != null) {
          if ($routeParams.question_id === 'new') {
            $scope.instrument.Questions[qtype].push($scope.current);
            index = $scope.instrument.Questions[qtype].length - 1;
            $scope.instrument.Questions[qtype][index].instrument_id = $routeParams.id;
          } else {
            angular.copy($scope.current, $scope.instrument.Questions[qtype].select_resource_by_id(parseInt($routeParams.question_id)));
            index = $scope.instrument.Questions[qtype].get_index_by_id(parseInt($routeParams.question_id));
          }
          return $scope.instrument.Questions[qtype][index].save({}, function(value, rh) {
            value['instrument_id'] = $scope.instrument.id;
            Flash.add('success', 'Question updated successfully!');
            window.location.href = "/instruments/" + $scope.current.instrument_id + "/build/questions/" + $routeParams.question_type + "/" + value['id'];
            $scope.reset();
            return $scope.load_sidebar();
          }, function(value, rh) {
            $scope.errors = value.data;
            return console.log("error");
          });
        }
      };
      $scope.title = 'Questions';
      $scope.extra_url_parameters = ['questions'];
      $scope.instrument_options = {
        questions: true,
        rds: true,
        codes: true
      };
      $scope.reset = function() {
        console.log("reset called");
        if ($routeParams.question_type != null) {
          if ($routeParams.question_type === 'question_items') {
            $scope.current = angular.copy($scope.instrument.Questions.Items.select_resource_by_id(parseInt($routeParams.question_id)));
            $scope.title = 'Question Item';
          } else {
            $scope.current = angular.copy($scope.instrument.Questions.Grids.select_resource_by_id(parseInt($routeParams.question_id)));
            $scope.title = 'Question Grid';
          }
          $scope.editMode = false;
          $scope.fragmentFormMode = false;
          $scope.errors = void 0;
          if ($routeParams.question_id === 'new') {
            $scope.editMode = true;
            if ($routeParams.question_type === 'question_items') {
              $scope.current = new DataManager.Constructs.Questions.item.resource({});
              $scope.current.type = 'QuestionItem';
            } else if ($routeParams.question_type === 'question_grids') {
              $scope.current = new DataManager.Constructs.Questions.grid.resource({});
              $scope.current.type = 'QuestionGrid';
            }
          }
        }
        return null;
      };
      $scope["new"] = function(type) {
        if (type == null) {
          type = false;
        }
        if (type === false) {
          jQuery('#new-question').modal('show');
        } else {
          $timeout(function() {
            return $scope.change_panel({
              type: type,
              id: 'new'
            });
          }, 0);
        }
        return null;
      };
      $scope.after_instrument_loaded = function() {
        $scope.load_sidebar();
        DataManager.resolveCodes();
        return console.log($scope.sidebar_objs);
      };
      return $controller('BaseBuildController', {
        $scope: $scope,
        $routeParams: $routeParams,
        $location: $location,
        $timeout: $timeout,
        Flash: Flash,
        DataManager: DataManager
      });
    }
  ]);

}).call(this);
(function() {
  angular.module('archivist.build').controller('BuildResponseDomainsController', [
    '$controller', '$scope', '$routeParams', '$location', '$filter', '$timeout', 'Flash', 'DataManager', 'Map', function($controller, $scope, $routeParams, $location, $filter, $timeout, Flash, DataManager, Map) {
      $scope.load_sidebar = function() {
        return $scope.sidebar_objs = $filter('excludeRDC')($scope.instrument.ResponseDomains).sort_by_property();
      };
      $scope.title = 'Response Domains';
      $scope.extra_url_parameters = ['response_domains'];
      $scope.instrument_options = {
        rds: true
      };
      $scope["delete"] = function() {
        var index, rd_type;
        switch ($routeParams.response_domain_type) {
          case 'response_domain_texts':
            rd_type = 'ResponseDomainText';
            break;
          case 'response_domain_datetimes':
            rd_type = 'ResponseDomainDatetime';
            break;
          case 'response_domain_numerics':
            rd_type = 'ResponseDomainNumeric';
            break;
          default:
            rd_type = false;
        }
        if (rd_type != null) {
          index = $scope.instrument.ResponseDomains.get_index_by_id_and_type(parseInt($routeParams.response_domain_id), rd_type);
          if (index != null) {
            return $scope.instrument.ResponseDomains[index].$delete({}, function() {
              $scope.instrument.ResponseDomains.splice(index, 1);
              $scope.load_sidebar();
              return $timeout(function() {
                if ($scope.instrument.ResponseDomains.length > 0) {
                  return $scope.change_panel($scope.instrument.ResponseDomains[0]);
                } else {
                  return $scope.change_panel({
                    type: rd_type,
                    id: 'new'
                  });
                }
              }, 0);
            });
          }
        }
      };
      $scope.save = function() {
        var arr, index, key, rd_type, res;
        switch ($routeParams.response_domain_type) {
          case 'response_domain_texts':
            rd_type = 'ResponseDomainText';
            break;
          case 'response_domain_datetimes':
            rd_type = 'ResponseDomainDatetime';
            break;
          case 'response_domain_numerics':
            rd_type = 'ResponseDomainNumeric';
            break;
          case 'new':
            rd_type = 'new';
            break;
          default:
            rd_type = false;
        }
        if (rd_type) {
          if (rd_type === 'new') {
            res = Map.find(DataManager, $scope.current.type);
            arr = Map.find(DataManager.Data, $scope.current.type);
            console.log(arr);
            arr.push(new res.resource());
            index = arr.length - 1;
            for (key in $scope.current) {
              arr[index][key] = $scope.current[key];
            }
            arr[index]['instrument_id'] = $routeParams.id;
          } else {
            arr = $scope.instrument.ResponseDomains;
            index = arr.get_index_by_id_and_type(parseInt($routeParams.response_domain_id), rd_type);
            angular.copy($scope.current, arr[index]);
          }
          return arr[index].save({}, function(value, rh) {
            value['instrument_id'] = $scope.instrument.id;
            Flash.add('success', 'Response Domain updated successfully!');
            DataManager.groupResponseDomains();
            $scope.reset();
            return $scope.load_sidebar();
          }, function() {
            return console.log("error");
          });
        }
      };
      $scope.reset = function() {
        var i, len, rd, ref;
        if (($routeParams.response_domain_type != null) && ($routeParams.response_domain_id != null)) {
          ref = $scope.instrument.ResponseDomains;
          for (i = 0, len = ref.length; i < len; i++) {
            rd = ref[i];
            if (rd.type.pascal_case_to_underscore() + 's' === $routeParams.response_domain_type && rd.id.toString() === $routeParams.response_domain_id) {
              $scope.current = angular.copy(rd);
              $scope.editMode = false;
              break;
            }
          }
        }
        if ($routeParams.response_domain_type === 'new') {
          $scope.editMode = true;
          $scope.current = {};
        }
        return null;
      };
      $scope["new"] = function() {
        $timeout(function() {
          return $scope.change_panel({
            type: null,
            id: 'new'
          });
        }, 0);
        return null;
      };
      $scope.after_instrument_loaded = function() {
        return $scope.load_sidebar();
      };
      return $controller('BaseBuildController', {
        $scope: $scope,
        $routeParams: $routeParams,
        $location: $location,
        $timeout: $timeout,
        Flash: Flash,
        DataManager: DataManager
      });
    }
  ]);

}).call(this);
(function() {
  angular.module('archivist.build').directive('resumeScroll', [
    '$timeout', function($timeout) {
      return {
        scope: {
          key: '@'
        },
        link: {
          postLink: function(scope, iElement, iAttrs) {
            $timeout(function() {
              console.log(scope);
              iElement.scrollTop = localStorage.getItem('sidebar-scroll-top');
              return localStorage.removeItem('sidebar-scroll-top');
            });
            return scope.$on('$destroy', function() {
              return localStorage.setItem('sidebar-scroll-top', iElement.scrollTop);
            });
          }
        }
      };
    }
  ]);

}).call(this);
(function() {
  angular.module('archivist.build').directive('strip', [
    function() {
      return {
        scope: {
          key: '@'
        },
        link: {
          postLink: function(scope, iElement, iAttrs) {
            return iElement.text = iElement.text.replaceAll('ResponseDomain', '');
          }
        }
      };
    }
  ]);

}).call(this);
(function() {
  angular.module('archivist.build').filter('excludeRDC', function() {
    return function(items) {
      var output;
      output = [];
      angular.forEach(items, function(item) {
        if (item.type !== 'ResponseDomainCode') {
          return output.push(item);
        }
      });
      return output;
    };
  });

}).call(this);
(function() {
  angular.module('archivist.build').filter('stripRD', function() {
    return function(item) {
      return item.replace('ResponseDomain', '');
    };
  });

}).call(this);
(function() {
  var build;

  build = angular.module('archivist.summary', ['templates', 'ngRoute']);

  build.config([
    '$routeProvider', function($routeProvider) {
      return $routeProvider.when('/instruments/:id/summary', {
        templateUrl: 'partials/summary/index.html',
        controller: 'SummaryIndexController'
      }).when('/instruments/:id/summary/:object_type', {
        templateUrl: 'partials/summary/show.html',
        controller: 'SummaryShowController'
      });
    }
  ]);

}).call(this);
(function() {
  angular.module('archivist.summary').controller('SummaryShowController', [
    '$scope', '$routeParams', '$filter', 'DataManager', 'Map', function($scope, $routeParams, $filter, DataManager, Map) {
      var k, options, v;
      $scope.object_type = $routeParams.object_type.underscore_to_pascal_case();
      options = Object.lower_everything(Map.map[$scope.object_type]);
      for (k in options) {
        v = options[k];
        options[k] = {};
        options[k][v] = true;
      }
      options['topsequence'] = false;
      return $scope.instrument = DataManager.getInstrument($routeParams.id, options, function() {
        var accepted_columns, data, i, index, j, key, len, obj, row;
        accepted_columns = ['id', 'label', 'literal', 'base_label', 'response_unit_label', 'logic'];
        data = Map.find(DataManager.Data, $scope.object_type);
        $scope.data = [];
        for (index = j = 0, len = data.length; j < len; index = ++j) {
          row = data[index];
          obj = {};
          for (i in row) {
            if (accepted_columns.indexOf(i) !== -1) {
              obj[i] = row[i];
            }
          }
          $scope.data.push(obj);
        }
        $scope.cols = (function() {
          var results;
          results = [];
          for (key in $scope.data[0]) {
            results.push(key);
          }
          return results;
        })();
        $scope.breadcrumbs = [
          {
            label: 'Instruments',
            link: '/instruments',
            active: false
          }, {
            label: $scope.instrument.prefix,
            link: '/instruments/' + $scope.instrument.prefix,
            active: false
          }, {
            label: 'Summary',
            link: false,
            active: false
          }, {
            label: $scope.object_type,
            link: false,
            active: true
          }
        ];
        return console.log($scope);
      });
    }
  ]);

}).call(this);
(function() {


}).call(this);
(function() {
  var mapping;

  mapping = angular.module('archivist.mapping', ['ngRoute', 'archivist.flash', 'archivist.data_manager']);

  mapping.config([
    '$routeProvider', function($routeProvider) {
      return $routeProvider.when('/instruments/:id/map', {
        templateUrl: 'partials/instruments/map.html',
        controller: 'MappingController'
      });
    }
  ]);

  mapping.controller('MappingController', [
    '$scope', '$routeParams', 'DataManager', function($scope, $routeParams, DataManager) {
      var pushVariable;
      $scope.instrument = DataManager.getInstrument($routeParams.id, {
        constructs: true,
        questions: true,
        variables: true
      }, function() {
        if ($scope.instrument.signed_off) {
          return window.location.href = '/instruments';
        } else {
          DataManager.resolveConstructs();
          return DataManager.resolveQuestions();
        }
      });
      $scope.tags = {};
      $scope.variable = {};
      $scope.addVariable = function(item, question_id) {
        $scope.tags[question_id] = $scope.tags[question_id] || [];
        return $scope.tags[question_id] = pushVariable($scope.tags[question_id], item, question_id);
      };
      $scope.deleteVariable = function(question_id, idx) {
        return $scope.tags[question_id].splice(idx, 1);
      };
      $scope.detectKey = function(event, question, x, y) {
        var variables;
        if (x == null) {
          x = null;
        }
        if (y == null) {
          y = null;
        }
        if (event.keyCode === 13) {
          variables = event.target.value.split(',');
          DataManager.addVariables(question, variables).then(function() {
            return $scope.model.orig_topic = $scope.model.topic;
          }, function(reason) {
            return question.errors = reason.data.message;
          });
        }
        return console.log(question);
      };
      pushVariable = function(array, item, question_id) {
        var index;
        console.log(array);
        index = array.map(function(x) {
          return x.id;
        }).indexOf(item.id);
        if (index === -1) {
          array.push(item);
        }
        $scope.variable.added[question_id] = null;
        return array;
      };
      console.log('Controller scope');
      console.log($scope);
      return $scope.split_mapping = function(question, variable_id, x, y) {
        if (x == null) {
          x = null;
        }
        if (y == null) {
          y = null;
        }
        return question.$split_mapping({
          variable_id: variable_id,
          x: x,
          y: y
        });
      };
    }
  ]);

  mapping.directive('aTopics', [
    '$compile', 'bsLoadingOverlayService', 'DataManager', 'Flash', function($compile, bsLoadingOverlayService, DataManager, Flash) {
      var nestedOptions;
      nestedOptions = function(scope) {
        console.log(scope);
        return '<select class="form-control" data-ng-model="model.topic.id" data-ng-init="model.topic.id = model.topic.id || model.ancestral_topic.id" style="width: 100%; ' + 'max-width:600px;" convert-to-number data-ng-change="updateTopic()" data-ng-if="model.topic || !model.strand">' + '<option value=""><em>Clear</em></option>' + '<option ' + 'data-ng-repeat="topic in topics" ' + 'data-ng-selected="topic.id == model.topic.id" ' + 'data-a-topic-indent="{{topic.level}}" ' + 'class="a-topic-level-{{topic.level}}" ' + 'value="{{topic.id}}">{{topic.name}}</option>' + '</select>' + '<span class="a-topic" data-ng-if="!model.topic && model.strand">{{model.strand.topic.name}}</span>';
      };
      return {
        restrict: 'E',
        require: 'ngModel',
        scope: {
          model: '=ngModel'
        },
        link: {
          post: function($scope, iElement, iAttrs, ngModel) {
            var init;
            init = function() {
              var el;
              console.log('a topic init');
              $scope.model.orig_topic = $scope.model.topic;
              $scope.topics = DataManager.getTopics({
                flattened: true
              });
              el = $compile(nestedOptions($scope))($scope);
              return iElement.replaceWith(el);
            };
            $scope.updateTopic = function() {
              bsLoadingOverlayService.start();
              return DataManager.updateTopic($scope.model, $scope.model.topic.id).then(function() {
                return $scope.model.orig_topic = $scope.model.topic;
              }, function(reason) {
                $scope.model.topic = $scope.model.orig_topic;
                return $scope.model.errors = reason.data.message;
              })["finally"](function() {
                return bsLoadingOverlayService.stop();
              });
            };
            return init();
          }
        }
      };
    }
  ]);

  mapping.directive('aTopicIndent', [
    function() {
      return {
        restrict: 'A',
        scope: {},
        link: {
          post: function($scope, iElement, iAttrs, con) {
            return $scope.$watch('topic', function() {
              return iElement.text("--".repeat(parseInt(iAttrs.aTopicIndent) - 1) + iElement.text());
            });
          }
        }
      };
    }
  ]);

}).call(this);
(function() {
  var topics;

  topics = angular.module('archivist.topics', ['ngRoute', 'archivist.data_manager']);

  topics.config([
    '$routeProvider', function($routeProvider) {
      return $routeProvider.when('/topics', {
        templateUrl: 'partials/topics/index.html',
        controller: 'TopicsIndexController'
      });
    }
  ]);

  topics.controller('TopicsIndexController', [
    '$scope', '$routeParams', 'DataManager', 'Topics', function($scope, $routeParams, DataManager, Topics) {
      $scope.data = DataManager.getTopics({
        nested: true
      });
      $scope.treeOptions = {
        dirSelectable: false
      };
      $scope.showSelected = function(node, selected) {
        if (!selected) {
          $scope.node = null;
          return $scope.quesiton_stats = $scope.variable_stats = $scope.node = null;
        } else {
          $scope.node = node;
          $scope.quesiton_stats = $scope.variable_stats = null;
          console.log(node);
          console.log(Topics);
          $scope.question_stats = Topics.questionStatistics({
            id: node.id
          });
          return $scope.variable_stats = Topics.variableStatistics({
            id: node.id
          });
        }
      };
      return console.log($scope);
    }
  ]);

}).call(this);
(function() {


}).call(this);

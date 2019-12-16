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

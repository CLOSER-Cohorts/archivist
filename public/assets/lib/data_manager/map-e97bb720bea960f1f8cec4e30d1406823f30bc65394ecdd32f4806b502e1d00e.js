(function() {
  var map;

  map = angular.module('archivist.data_manager.map', []);

  map.factory('Map', [
    function() {
      var service;
      service = {};
      service.map = {
        Instrument: 'Instruments',
        CcCondition: {
          Constructs: 'Conditions'
        },
        CcLoop: {
          Constructs: 'Loops'
        },
        CcQuestion: {
          Constructs: 'Questions'
        },
        CcSequence: {
          Constructs: 'Sequences'
        },
        CcStatement: {
          Constructs: 'Statements'
        },
        QuestionItem: {
          Questions: 'Items'
        },
        QuestionGrid: {
          Questions: 'Grids'
        },
        ResponseDomainText: {
          ResponseDomains: 'Texts'
        },
        ResponseDomainNumeric: {
          ResponseDomains: 'Numerics'
        },
        ResponseDomainDatetime: {
          ResponseDomains: 'Datetimes'
        },
        Variable: 'Variables'
      };
      service.find = function(obj, ident) {
        var dig;
        dig = function(obj, lookup) {
          var k, output, v;
          output = obj;
          if (typeof lookup === "object") {
            for (k in lookup) {
              v = lookup[k];
              if (lookup.hasOwnProperty(k)) {
                output = dig(output[k], v);
              }
            }
          } else {
            output = output[lookup];
          }
          return output;
        };
        return dig(obj, service.map[ident]);
      };
      service.translate = function(ident) {
        var dig;
        dig = function(lookup) {
          if (typeof lookup === "object") {
            return dig(lookup[Object.keys(lookup)[0]]);
          } else {
            return lookup;
          }
        };
        return dig(service.map[ident]);
      };
      return service;
    }
  ]);

}).call(this);

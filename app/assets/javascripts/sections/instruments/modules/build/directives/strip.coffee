angular.module('archivist.build').directive(
  'strip',
  [
    ->
      {
      scope:
        key: '@'

      link:
        postLink: (scope, iElement, iAttrs)->
          iElement.text = iElement.text.replaceAll 'ResponseDomain', ''
      }
  ]
)
angular.module('archivist.build').directive(
  'resumeScroll',
  [
    '$timeout',
    ($timeout)->
      {
      scope:
        key: '@'

      link:
        postLink: (scope, iElement, iAttrs)->
          $timeout ()->
            console.log(scope)
            iElement.scrollTop = localStorage.getItem 'sidebar-scroll-top'
            localStorage.removeItem 'sidebar-scroll-top'

          scope.$on '$destroy', ()->
            localStorage.setItem 'sidebar-scroll-top', iElement.scrollTop
      }
  ]
)
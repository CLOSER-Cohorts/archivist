declare var require: any;

// tslint:disable-next-line
require('script!./../node_modules/spin.js/spin.js');
// tslint:disable-next-line
require('script!./../node_modules/angular-spinner/angular-spinner.js');

export default angular.module('bsLoadingOverlaySpinJs', ['angularSpinner'])
    .run([
        '$templateCache',
        ($templateCache: ng.ITemplateCacheService) =>
            $templateCache.put(
                'bsLoadingOverlaySpinJs',
                '<div us-spinner="{{bsLoadingOverlayTemplateOptions}}"></div>'
            )
    ]);

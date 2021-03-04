import { include } from 'named-urls'

export default {
    login : '/login',
    datasets: include('/datasets', {
      all: ''
    }),
    admin: include('/admin/', {
      import: 'import',
      imports: 'imports',
      instruments: include('instruments/', {
        all: '',
        importMappings: ':instrumentId/imports'
      }),
      datasets: include('datasets/', {
        all: '',
        importMappings: ':datasetId/imports'
      }),
    }),
    instruments: include('/instruments', {
      all: '',
      instrument: include(':instrument_id/', {
        show: '',
         map: include('map/', {
            show: ''
        }),
        build: include('build/', {
            show: '',
            constructs: include('constructs/', {
                show: ''
            }),
            codeLists: include('code_lists/', {
              all: '',
              show: ':codeListId',
              new: 'new'
            }),
            questionItems: include('question_items/', {
              all: '',
              show: ':questionItemId',
              new: 'new'
            }),
            questionGrids: include('question_grids/', {
              all: '',
              show: ':questionGridId',
              new: 'new'
            }),
            responseDomains: include('response_domains/', {
              all: '',
              new: 'new',
              show: ':responseDomainType/:responseDomainId',
            })
        })
      })
   })
}

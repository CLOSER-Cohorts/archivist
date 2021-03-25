import { include } from 'named-urls'

export default {
    login : '/login',
    datasets: include('/datasets', {
      all: ''
    }),
    admin: include('/admin/', {
      import: 'import',
      imports: include('imports/', {
        all: '',
        show: ':importId'
      }),
      instruments: include('instruments/', {
        all: '',
        exports: 'exports',
        importMappings: ':instrumentId/imports',
        importMapping: ':instrumentId/imports/:id'
      }),
      datasets: include('datasets/', {
        all: '',
        importMappings: ':datasetId/imports',
        importMapping: ':datasetId/imports/:id'
      }),
    }),
    instruments: include('/instruments', {
      all: '',
      new: 'new',
      instrument: include(':instrument_id/', {
        show: '',
        edit: 'edit',
         map: include('map/', {
            show: ''
        }),
        build: include('build/', {
            show: '',
            ccConditions: 'ccConditions',
            ccLoops: 'ccLoops',
            ccQuestions: 'ccQuestions',
            ccSequences: 'ccSequences',
            ccStatements: 'ccStatements',
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

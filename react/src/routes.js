import { include } from 'named-urls'

export default {
   login : '/login',
   instruments: include('/instruments', {
      all: '',
      instrument: include(':instrument_id/', {
         map: include('map/', {
            show: ''
        }),
        build: include('build/', {
            show: '',
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

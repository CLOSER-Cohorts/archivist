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
              show: ':codeListId'
            })
        })
      })
   })
}

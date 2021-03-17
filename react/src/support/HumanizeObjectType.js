export const HumanizeObjectType = (type) => {
   switch (type){
      case 'statement':
      case 'CcStatement':
         return 'Statement'
      case 'loop':
      case 'CcLoop':
         return 'Loop'
      case 'question':
      case 'CcQuestion':
         return 'Question'
      case 'sequence':
      case 'CcSequence':
         return 'Sequence'
      case 'condition':
      case 'CcCondition':
         return 'Condition'
      default:
         return ''
   }
}

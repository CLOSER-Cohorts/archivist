export const ConstructTypeFromObjectType = (type) => {
   switch (type){
      case 'statement':
        return 'CcStatement'
      case 'loop':
        return 'CcLoop'
      case 'question':
        return 'CcQuestion'
      case 'sequence':
        return 'CcSequence'
      case 'condition':
        return 'CcCondition'
      default:
         return type
   }
}

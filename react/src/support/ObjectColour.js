export const ObjectColour = (type) => {
   switch (type){
      case 'statement':
      case 'CcSequence':
         return '652d90' // Purple;
      case 'loop':
      case 'CcLoop':
         return '37b34a' // Green;
      case 'question':
      case 'CcQuestion':
         return '00adee' // Pale Blue;
      case 'sequence':
      case 'CcSequence':
         return 'faaf40' // Orange;
      case 'condition':
      case 'CcCondition':
         return 'f1003a' // Red;
      default:
         return 'd3d3d3' // Light Grey
   }
}

//652d90 Purple
// eb008b Pink
// faaf40 Orange
// f1003a Red
// 37b34a Green
// 00adee Pale Blue
// 2e008b Dark Purple
// 1f801e Dark Green

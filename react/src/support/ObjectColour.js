export const ObjectColour = (type) => {
   switch (type){
      case 'statement':
         return '652d90' // Purple;
      case 'loop':
         return '37b34a' // Green;
      case 'question':
         return '00adee' // Pale Blue;
      case 'sequence':
         return 'faaf40' // Orange;
      case 'condition':
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

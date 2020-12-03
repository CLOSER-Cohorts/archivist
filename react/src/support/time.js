const convertToHHMM = (decimal) => {
  let total = decimal % 1
  if (total > 0) {
    var hrs = parseInt(Number(decimal));
    var min = Math.round((Number(decimal)-hrs) * 60);
    return hrs+'h '+min+'m ';
  } else {
    return decimal +'h '
  }
};

export default convertToHHMM;


bool areEqualLists(List? a, List? b) {

  if((a == null || a.isEmpty) && (b == null || b.isEmpty) ){
    return true;
  }
  if(a == null || b == null ){
    return false;
  }
  if(a.length != b.length){
    return false;
  }
  if(a.isEmpty && b.isEmpty){
    return true;
  }
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

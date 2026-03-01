String? verifyEmail(String? email){
  if(email == null){
    return 'email is required';
  }
  if(email.isEmpty){
    return 'email is required';
  }
  if(!email.contains('@')){
    return 'email is not valid';
  }
  if(email.length < 6){
    return 'email is not valid';
  }
  if(email.length > 50){
    return 'email is not valid';
  }
  return null;
}
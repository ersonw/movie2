class RequestApi {
  static const test = '/api/test/{text}';

  static const searchMovie = '/api/search/movie/{text}';
  static const searchMovieCancel  = '/api/search/movie/cancel/{id}';
  static const searchMovieResult = '/api/search/result/{page}/{id}';

  static const checkDeviceId = '/api/device/check/{deviceId}';

  static const userLogin  = '/api/user/login';
  static const userRegister = '/api/user/register';
  static const userRegisterSms = '/api/user/register/sms/{phone}';
}
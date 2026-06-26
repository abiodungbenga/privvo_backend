class GoogleSignInModel {
  factory GoogleSignInModel.fromJson(Map<String, dynamic> json) {
    return GoogleSignInModel(
      iss: json["iss"] as String?,
      azp: json["azp"] as String?,
      aud: json["aud"] as String?,
      sub: json["sub"] as String?,
      email: json["email"] as String?,
      emailVerified: json["email_verified"] as String?,
      atHash: json["at_hash"] as String?,
      name: json["name"] as String?,
      picture: json["picture"] as String?,
      givenName: json["given_name"] as String?,
      iat: json["iat"] as String?,
      exp: json["exp"] as String?,
      alg: json["alg"] as String?,
      kid: json["kid"] as String?,
      typ: json["typ"] as String?,
    );
  }
  GoogleSignInModel({
    required this.iss,
    required this.azp,
    required this.aud,
    required this.sub,
    required this.email,
    required this.emailVerified,
    required this.atHash,
    required this.name,
    required this.picture,
    required this.givenName,
    required this.iat,
    required this.exp,
    required this.alg,
    required this.kid,
    required this.typ,
  });

  final String? iss;
  final String? azp;
  final String? aud;
  final String? sub;
  final String? email;
  final String? emailVerified;
  final String? atHash;
  final String? name;
  final String? picture;
  final String? givenName;
  final String? iat;
  final String? exp;
  final String? alg;
  final String? kid;
  final String? typ;

  Map<String, dynamic> toJson() => {
        'iss': iss,
        'azp': azp,
        'aud': aud,
        'sub': sub,
        'email': email,
        'email_verified': emailVerified,
        'at_hash': atHash,
        'name': name,
        'picture': picture,
        'given_name': givenName,
        'iat': iat,
        'exp': exp,
        'alg': alg,
        'kid': kid,
        'typ': typ,
      };
}

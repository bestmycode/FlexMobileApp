import 'dart:convert';

import 'package:co/utils/basedata.dart';
import 'package:flutter/cupertino.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart' as http;

class Token {
  getClientToken() async {
    Uri url = Uri.parse('${BaseData.BASE_URL}/oauth/token');

    var data = {
      "client_id": BaseData.CLIENT_ID,
      "client_secret": BaseData.CLIENT_SECRET,
      "audience": BaseData.AUDIENCE,
      "grant_type": "client_credentials"
    };

    var tokenResponse = await http.post(url,
        headers: {"Content-Type": "application/json"}, body: json.encode(data));

    var body = json.decode(tokenResponse.body);
    var token = body["access_token"];
    return token;
  }

  getLink(token) {
    final HttpLink httpLink =
        HttpLink("https://gql.staging.fxr.one/v1/graphql");

    final AuthLink authLink = AuthLink(getToken: () async => "${token}");
    final Link link = authLink.concat(httpLink);

    ValueNotifier<GraphQLClient> client = ValueNotifier(
      GraphQLClient(
        link: link,
        cache: GraphQLCache(
          store: InMemoryStore(),
        ),
      ),
    );
    return client;
  }

  getFinaxarToken() async {
    Uri url = Uri.parse('${BaseData.BASE_URL}/oauth/token');

    var data = {
      "client_id": BaseData.CLIENT_ID,
      "client_secret": BaseData.CLIENT_SECRET,
      "audience": BaseData.FINAXAR_GQL_URL,
      "grant_type": "client_credentials"
    };

    var tokenResponse = await http.post(url,
        headers: {"Content-Type": "application/json"}, body: json.encode(data));

    var body = json.decode(tokenResponse.body);
    var token = body["access_token"];
    return token;
  }
}

import 'dart:developer';

import 'package:co/models/mcd_card_data.model.dart';
import 'package:flutter/services.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:localstorage/localstorage.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class McdCardService {
  const McdCardService();
  static final LocalStorage storage = LocalStorage('token');
  static const _platform = MethodChannel('flexnow.co/card');

  /// Return the graphql client for fxr API
  Future<GraphQLClient> _getClient() async {
    String accessToken = storage.getItem("jwt_token");
    final httpLink = HttpLink("https://gql.staging.fxr.one/v1/graphql");
    final AuthLink authLink = AuthLink(getToken: () async => accessToken);
    final Link link = authLink.concat(httpLink);
    return GraphQLClient(link: link, cache: GraphQLCache());
  }

  /// Request [cardSecret] from `GraphQL` api
  Future<String?> _requestCardData(String cardId) async {
    final client = await _getClient();
    const queryDoc = r'''
    query ($financeAccountId:String!){
      getMeaSecret(financeAccountId:$financeAccountId){
        secret
      }
    }
    ''';
    final options = QueryOptions(
      document: gql(queryDoc),
      variables: {"financeAccountId": cardId},
    );
    try {
      final result = await client.query(options);
      if (result.hasException) {
        throw 'Could not fetch card secret';
      }

      return result.data!['getMeaSecret']['secret'];
    } catch (error) {
      print("===== Error : Get Mea Secret =====");
      print(error);
      await Sentry.captureException(error);
      return null;
    }
  }

  /// Takes `cardId` (financeAccountId)
  /// And `publicToken` to fetch secret from fxr api
  /// And call sdk for card details
  Future<McdCardData?> getCardData({
    required String cardId,
    required String publicToken,
  }) async {
    final secret = await _requestCardData(cardId);
    if (secret != null) {
      final result = await _platform.invokeMethod(
        'getCardData',
        {
          "cardId": publicToken,
          "secret": secret,
        },
      );
      if (result is Map && result['cvv'] != null) {
        return McdCardData(cvv: result["cvv"], pan: result['pan']);
      }
    }

    return McdCardData(cvv: '', pan: '');
  }
}

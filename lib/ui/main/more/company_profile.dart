import 'package:co/ui/main/more/company_profile_main.dart';
import 'package:co/utils/queries.dart';
import 'package:co/utils/token.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:co/utils/scale.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:localstorage/localstorage.dart';

class CompanyProfile extends StatefulWidget {
  const CompanyProfile({Key? key}) : super(key: key);
  @override
  CompanyProfileState createState() => CompanyProfileState();
}

class CompanyProfileState extends State<CompanyProfile> {
  hScale(double scale) {
    return Scale().hScale(context, scale);
  }

  wScale(double scale) {
    return Scale().wScale(context, scale);
  }

  fSize(double size) {
    return Scale().fSize(context, size);
  }

  final LocalStorage storage = LocalStorage('token');
  final LocalStorage userStorage = LocalStorage('user_info');
  String getCompanySettingQuery = Queries.QUERY_GET_COMPANY_SETTING;
  String getCountryQuery = Queries.QUERY_GET_COUNTRY;
  String listCompanyTypeQuery = Queries.QUERY_LIST_COMPANY_TYPE;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String accessToken = storage.getItem("jwt_token");
    return GraphQLProvider(client: Token().getLink(accessToken), child: home());
  }

  Widget home() {
    var orgId = userStorage.getItem('orgId');
    return Query(
        options: QueryOptions(
          document: gql(getCompanySettingQuery),
          variables: {'orgId': orgId},
        ),
        builder: (QueryResult result,
            {VoidCallback? refetch, FetchMore? fetchMore}) {
          if (result.hasException) {
            return Text(result.exception.toString());
          }

          if (result.isLoading) {
            return Container(
                alignment: Alignment.center,
                child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF60C094))));
          }
          var companyProfile = result.data!['organization'];

          return Query(
              options: QueryOptions(
                document: gql(getCountryQuery),
                variables: {"countryId": companyProfile['country']},
              ),
              builder: (QueryResult countryResult,
                  {VoidCallback? refetch, FetchMore? fetchMore}) {
                if (countryResult.hasException) {
                  return Text(countryResult.exception.toString());
                }

                if (countryResult.isLoading) {
                  return Container(
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF60C094))));
                }
                var countryInfo = countryResult.data!['country'];

                return Query(
                    options: QueryOptions(
                      document: gql(listCompanyTypeQuery),
                      variables: {},
                    ),
                    builder: (QueryResult comapanyResult,
                        {VoidCallback? refetch, FetchMore? fetchMore}) {
                      if (comapanyResult.hasException) {
                        return Text(comapanyResult.exception.toString());
                      }

                      if (comapanyResult.isLoading) {
                        return Container(
                            alignment: Alignment.center,
                            child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF60C094))));
                      }
                      var listCompany =
                          comapanyResult.data!['LIST_COMPANY_TYPES'];
                      return SingleChildScrollView(
                          child: CompanyProfileMain(
                              companyProfile: companyProfile,
                              countryInfo: countryInfo,
                              listCompany: listCompany));
                    });
              });
        });
  }
}
